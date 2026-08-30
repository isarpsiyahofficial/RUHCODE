import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../data/local/local_database.dart';
import 'entitlement_service.dart';

const ruhCodeLifetimeProductId = 'ruh_code_lifetime_pro';

enum StoreOwnershipStatus { owned, notOwned, unavailable }

final class StoreOwnershipCheck {
  const StoreOwnershipCheck({
    required this.status,
    this.verificationFingerprint,
  });

  final StoreOwnershipStatus status;
  final String? verificationFingerprint;
}

abstract interface class LifetimeOwnershipQuery {
  Future<StoreOwnershipCheck> query(String productId);
}

/// Google Play non-consumable ownership lookup using Flutter's official
/// Android platform addition. A successful empty query means not-owned; a
/// query error means unavailable and must not revoke cached ownership.
final class GooglePlayLifetimeOwnershipQuery implements LifetimeOwnershipQuery {
  const GooglePlayLifetimeOwnershipQuery();

  @override
  Future<StoreOwnershipCheck> query(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError.value(productId, 'productId', 'Product ID cannot be empty.');
    }

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      return const StoreOwnershipCheck(status: StoreOwnershipStatus.unavailable);
    }

    final addition = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) {
      return const StoreOwnershipCheck(status: StoreOwnershipStatus.unavailable);
    }

    for (final purchase in response.pastPurchases) {
      if (purchase.productID != productId) continue;
      if (purchase.status != PurchaseStatus.purchased &&
          purchase.status != PurchaseStatus.restored) {
        continue;
      }
      final verification = purchase.verificationData.serverVerificationData;
      if (verification.trim().isEmpty) {
        // Ownership without verification material is not accepted as a
        // durable lifetime entitlement.
        return const StoreOwnershipCheck(status: StoreOwnershipStatus.unavailable);
      }
      final fingerprint = sha256
          .convert(utf8.encode('$productId\u0000$verification'))
          .toString();
      return StoreOwnershipCheck(
        status: StoreOwnershipStatus.owned,
        verificationFingerprint: fingerprint,
      );
    }

    return const StoreOwnershipCheck(status: StoreOwnershipStatus.notOwned);
  }
}

final class CachedStoreOwnership {
  const CachedStoreOwnership({
    required this.owned,
    required this.checkedAtUtc,
    this.verificationFingerprint,
  });

  final bool owned;
  final DateTime checkedAtUtc;
  final String? verificationFingerprint;
}

final class GooglePlayOwnershipCache {
  const GooglePlayOwnershipCache(this.database);

  static const tableName = 'system_google_play_ownership';
  static const recordId = 'lifetime_pro';

  final LocalDatabase database;

  Future<CachedStoreOwnership?> load() async {
    final value = await database.transaction(
      (tx) => tx.get(table: tableName, id: recordId),
    );
    if (value == null) return null;

    final owned = value['owned'];
    final checkedAtRaw = value['checkedAtUtc'];
    final fingerprint = value['verificationFingerprint'];
    if (owned is! bool || checkedAtRaw is! String) {
      throw const FormatException('Stored Google Play ownership record is invalid.');
    }
    final checkedAt = DateTime.tryParse(checkedAtRaw);
    if (checkedAt == null || !checkedAt.isUtc) {
      throw const FormatException('Google Play ownership checkedAtUtc must be UTC.');
    }
    if (fingerprint != null && fingerprint is! String) {
      throw const FormatException('Google Play ownership fingerprint must be a string.');
    }

    return CachedStoreOwnership(
      owned: owned,
      checkedAtUtc: checkedAt,
      verificationFingerprint: fingerprint as String?,
    );
  }

  Future<void> save(CachedStoreOwnership ownership) async {
    if (!ownership.checkedAtUtc.isUtc) {
      throw const FormatException('Google Play ownership checkedAtUtc must be UTC.');
    }
    if (ownership.owned &&
        (ownership.verificationFingerprint == null ||
            ownership.verificationFingerprint!.trim().isEmpty)) {
      throw const FormatException('Owned Google Play purchase requires a verification fingerprint.');
    }

    await database.transaction(
      (tx) => tx.put(
        table: tableName,
        id: recordId,
        value: <String, Object?>{
          'owned': ownership.owned,
          'checkedAtUtc': ownership.checkedAtUtc.toIso8601String(),
          'verificationFingerprint': ownership.verificationFingerprint,
        },
      ),
    );
  }
}

final class GooglePlayOwnershipSyncResult {
  const GooglePlayOwnershipSyncResult({
    required this.status,
    required this.cacheChanged,
  });

  final StoreOwnershipStatus status;
  final bool cacheChanged;
}

/// Synchronizes Google Play ownership without making online availability a
/// prerequisite for using a previously confirmed lifetime purchase.
final class GooglePlayLifetimeOwnershipSynchronizer {
  const GooglePlayLifetimeOwnershipSynchronizer({
    required this.query,
    required this.cache,
    required this.clock,
    this.productId = ruhCodeLifetimeProductId,
  });

  final LifetimeOwnershipQuery query;
  final GooglePlayOwnershipCache cache;
  final EntitlementClock clock;
  final String productId;

  Future<GooglePlayOwnershipSyncResult> synchronize() async {
    final check = await query.query(productId);
    if (check.status == StoreOwnershipStatus.unavailable) {
      return const GooglePlayOwnershipSyncResult(
        status: StoreOwnershipStatus.unavailable,
        cacheChanged: false,
      );
    }

    final now = await clock.nowUtc();
    if (!now.isUtc) {
      throw StateError('Ownership synchronization clock must return UTC.');
    }
    final previous = await cache.load();
    final next = CachedStoreOwnership(
      owned: check.status == StoreOwnershipStatus.owned,
      checkedAtUtc: now,
      verificationFingerprint: check.status == StoreOwnershipStatus.owned
          ? check.verificationFingerprint
          : null,
    );
    await cache.save(next);

    final changed = previous == null ||
        previous.owned != next.owned ||
        previous.verificationFingerprint != next.verificationFingerprint;
    return GooglePlayOwnershipSyncResult(
      status: check.status,
      cacheChanged: changed,
    );
  }
}

/// Combines local non-store entitlement state (temporary grants, future promo
/// sources) with cached Google Play lifetime ownership. This prevents a store
/// outage from making an already-confirmed lifetime purchase unusable offline.
final class CompositeEntitlementSnapshotProvider implements EntitlementSnapshotProvider {
  const CompositeEntitlementSnapshotProvider({
    required this.localProvider,
    required this.googlePlayCache,
  });

  final EntitlementSnapshotProvider localProvider;
  final GooglePlayOwnershipCache googlePlayCache;

  @override
  Future<EntitlementSnapshot> load() async {
    final local = await localProvider.load();
    final store = await googlePlayCache.load();
    return EntitlementSnapshot(
      hasPro: local.hasPro || (store?.owned ?? false),
      temporaryGrants: local.temporaryGrants,
    );
  }
}
