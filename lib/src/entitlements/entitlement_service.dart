import '../domain/models/core_models.dart';
import 'feature_catalog.dart';

abstract interface class EntitlementService {
  Future<FeatureEntitlement> resolve(String featureId);
  Future<bool> canUse(String featureId);
}

final class TemporaryFeatureGrant {
  const TemporaryFeatureGrant({
    required this.featureId,
    required this.validUntilUtc,
  });

  final String featureId;
  final DateTime validUntilUtc;
}

final class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.hasPro,
    this.temporaryGrants = const <TemporaryFeatureGrant>[],
  });

  final bool hasPro;
  final List<TemporaryFeatureGrant> temporaryGrants;
}

abstract interface class EntitlementSnapshotProvider {
  Future<EntitlementSnapshot> load();
}

abstract interface class EntitlementClock {
  Future<DateTime> nowUtc();
}

final class SystemEntitlementClock implements EntitlementClock {
  const SystemEntitlementClock();

  @override
  Future<DateTime> nowUtc() async => DateTime.now().toUtc();
}

/// Single policy resolver used by UI, routing and services.
///
/// Unknown feature IDs fail closed. Temporary grants can only unlock features
/// explicitly marked temporaryUnlockAllowed in the central catalog.
final class PolicyEntitlementService implements EntitlementService {
  const PolicyEntitlementService({
    required this.snapshotProvider,
    this.clock = const SystemEntitlementClock(),
  });

  final EntitlementSnapshotProvider snapshotProvider;
  final EntitlementClock clock;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async {
    RuhFeatureCatalog.validate();
    final policy = RuhFeatureCatalog.policyFor(featureId);
    final snapshot = await snapshotProvider.load();

    if (snapshot.hasPro) {
      return FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
    }

    if (policy.baseAccess == FeatureBaseAccess.free) {
      return FeatureEntitlement(featureId: featureId, tier: EntitlementTier.free);
    }

    final now = await clock.nowUtc();
    if (!now.isUtc) {
      throw const StateError('Entitlement clock must return UTC.');
    }

    if (policy.temporaryUnlockAllowed) {
      DateTime? furthestValidUntil;
      for (final grant in snapshot.temporaryGrants) {
        if (grant.featureId != featureId) continue;
        if (!grant.validUntilUtc.isUtc) {
          throw const FormatException('Temporary entitlement expiry must be UTC.');
        }
        if (grant.validUntilUtc.isAfter(now) &&
            (furthestValidUntil == null || grant.validUntilUtc.isAfter(furthestValidUntil))) {
          furthestValidUntil = grant.validUntilUtc;
        }
      }
      if (furthestValidUntil != null) {
        return FeatureEntitlement(
          featureId: featureId,
          tier: EntitlementTier.temporary,
          validUntilUtc: furthestValidUntil,
        );
      }
    }

    // A locked PRO feature is represented as free-tier entitlement for the
    // current account; canUse() applies the catalog policy and returns false.
    return FeatureEntitlement(featureId: featureId, tier: EntitlementTier.free);
  }

  @override
  Future<bool> canUse(String featureId) async {
    final policy = RuhFeatureCatalog.policyFor(featureId);
    final entitlement = await resolve(featureId);
    if (entitlement.tier == EntitlementTier.pro || entitlement.tier == EntitlementTier.temporary) {
      return true;
    }
    return policy.baseAccess == FeatureBaseAccess.free;
  }
}
