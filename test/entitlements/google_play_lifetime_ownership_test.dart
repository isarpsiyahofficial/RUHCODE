import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/google_play_lifetime_ownership.dart';

void main() {
  test('successful owned query is cached and exposed as offline PRO', () async {
    final database = _MemoryDatabase();
    final cache = GooglePlayOwnershipCache(database);
    final sync = GooglePlayLifetimeOwnershipSynchronizer(
      query: const _FixedOwnershipQuery(
        StoreOwnershipCheck(
          status: StoreOwnershipStatus.owned,
          verificationFingerprint: 'abc123',
        ),
      ),
      cache: cache,
      clock: _FixedClock(DateTime.utc(2026, 8, 20, 15)),
    );

    final result = await sync.synchronize();
    expect(result.status, StoreOwnershipStatus.owned);
    expect(result.cacheChanged, isTrue);

    final composite = CompositeEntitlementSnapshotProvider(
      localProvider: const _FixedSnapshotProvider(
        EntitlementSnapshot(hasPro: false),
      ),
      googlePlayCache: cache,
    );
    expect((await composite.load()).hasPro, isTrue);
  });

  test('store outage never revokes previously confirmed ownership', () async {
    final database = _MemoryDatabase();
    final cache = GooglePlayOwnershipCache(database);
    await cache.save(
      CachedStoreOwnership(
        owned: true,
        checkedAtUtc: DateTime.utc(2026, 8, 20, 12),
        verificationFingerprint: 'owned-fingerprint',
      ),
    );

    final sync = GooglePlayLifetimeOwnershipSynchronizer(
      query: const _FixedOwnershipQuery(
        StoreOwnershipCheck(status: StoreOwnershipStatus.unavailable),
      ),
      cache: cache,
      clock: _FixedClock(DateTime.utc(2026, 8, 20, 16)),
    );
    final result = await sync.synchronize();

    expect(result.status, StoreOwnershipStatus.unavailable);
    expect(result.cacheChanged, isFalse);
    final cached = await cache.load();
    expect(cached?.owned, isTrue);
    expect(cached?.verificationFingerprint, 'owned-fingerprint');
    expect(cached?.checkedAtUtc, DateTime.utc(2026, 8, 20, 12));
  });

  test('successful not-owned query clears only Google Play ownership cache', () async {
    final database = _MemoryDatabase();
    final cache = GooglePlayOwnershipCache(database);
    await cache.save(
      CachedStoreOwnership(
        owned: true,
        checkedAtUtc: DateTime.utc(2026, 8, 20, 12),
        verificationFingerprint: 'old',
      ),
    );

    final sync = GooglePlayLifetimeOwnershipSynchronizer(
      query: const _FixedOwnershipQuery(
        StoreOwnershipCheck(status: StoreOwnershipStatus.notOwned),
      ),
      cache: cache,
      clock: _FixedClock(DateTime.utc(2026, 8, 20, 17)),
    );
    await sync.synchronize();

    final cached = await cache.load();
    expect(cached?.owned, isFalse);
    expect(cached?.verificationFingerprint, isNull);

    final composite = CompositeEntitlementSnapshotProvider(
      localProvider: const _FixedSnapshotProvider(
        EntitlementSnapshot(hasPro: true),
      ),
      googlePlayCache: cache,
    );
    // Non-store PRO state remains independent and cannot be erased by a
    // successful Play query that returns no lifetime purchase.
    expect((await composite.load()).hasPro, isTrue);
  });

  test('owned cache requires fingerprint and UTC timestamp', () async {
    final cache = GooglePlayOwnershipCache(_MemoryDatabase());
    await expectLater(
      cache.save(
        CachedStoreOwnership(
          owned: true,
          checkedAtUtc: DateTime.utc(2026, 8, 20),
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}

final class _FixedOwnershipQuery implements LifetimeOwnershipQuery {
  const _FixedOwnershipQuery(this.result);
  final StoreOwnershipCheck result;

  @override
  Future<StoreOwnershipCheck> query(String productId) async => result;
}

final class _FixedClock implements EntitlementClock {
  const _FixedClock(this.value);
  final DateTime value;

  @override
  Future<DateTime> nowUtc() async => value;
}

final class _FixedSnapshotProvider implements EntitlementSnapshotProvider {
  const _FixedSnapshotProvider(this.value);
  final EntitlementSnapshot value;

  @override
  Future<EntitlementSnapshot> load() async => value;
}

final class _MemoryDatabase implements LocalDatabase, LocalDatabaseTransaction {
  final Map<String, Map<String, Map<String, Object?>>> _tables =
      <String, Map<String, Map<String, Object?>>>{};

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async =>
      const IntegrityCheckResult(ok: true);

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) =>
      action(this);

  @override
  Future<void> put({
    required String table,
    required String id,
    required Map<String, Object?> value,
  }) async {
    (_tables[table] ??= <String, Map<String, Object?>>{})[id] =
        Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = _tables[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    _tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.fromEntries(
        (_tables[table] ?? const <String, Map<String, Object?>>{}).entries.map(
              (entry) => MapEntry(
                entry.key,
                Map<String, Object?>.from(entry.value),
              ),
            ),
      );

  @override
  Future<void> clearTable(String table) async {
    _tables.remove(table);
  }
}
