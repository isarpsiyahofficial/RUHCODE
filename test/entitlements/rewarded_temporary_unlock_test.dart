import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/entitlements/local_entitlement_snapshot_store.dart';
import 'package:ruh_code/src/entitlements/rewarded_temporary_unlock.dart';

void main() {
  test('cancelled rewarded ad is a strict entitlement no-op', () async {
    final database = _MemoryDatabase();
    final store = LocalEntitlementSnapshotStore(database);
    await store.save(
      EntitlementSnapshot(
        hasPro: false,
        temporaryGrants: <TemporaryFeatureGrant>[
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.vedicAdvanced,
            validUntilUtc: DateTime.utc(2026, 8, 21),
          ),
        ],
      ),
    );
    final before = await database.readTable(LocalEntitlementSnapshotStore.tableName);
    final coordinator = RewardedTemporaryUnlockCoordinator(
      store: store,
      clock: _FixedClock(DateTime.utc(2026, 8, 20, 16)),
    );

    final result = await coordinator.apply(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      outcome: RewardedAdOutcome.cancelled,
      duration: const Duration(days: 1),
    );

    expect(result.stateChanged, isFalse);
    expect(
      await database.readTable(LocalEntitlementSnapshotStore.tableName),
      before,
    );
  });

  test('failed rewarded ad is a strict entitlement no-op', () async {
    final database = _MemoryDatabase();
    final store = LocalEntitlementSnapshotStore(database);
    await store.save(const EntitlementSnapshot(hasPro: false));
    final before = await database.readTable(LocalEntitlementSnapshotStore.tableName);
    final coordinator = RewardedTemporaryUnlockCoordinator(
      store: store,
      clock: _FixedClock(DateTime.utc(2026, 8, 20, 16)),
    );

    final result = await coordinator.apply(
      featureId: RuhFeatureIds.westernAdvanced,
      outcome: RewardedAdOutcome.failed,
      duration: const Duration(days: 1),
    );

    expect(result.stateChanged, isFalse);
    expect(
      await database.readTable(LocalEntitlementSnapshotStore.tableName),
      before,
    );
  });

  test('verified reward adds only the requested eligible temporary feature', () async {
    final database = _MemoryDatabase();
    final store = LocalEntitlementSnapshotStore(database);
    await store.save(
      const EntitlementSnapshot(hasPro: false),
    );
    final now = DateTime.utc(2026, 8, 20, 16);
    final coordinator = RewardedTemporaryUnlockCoordinator(
      store: store,
      clock: _FixedClock(now),
    );

    final result = await coordinator.apply(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      outcome: RewardedAdOutcome.rewarded,
      duration: const Duration(days: 1),
    );
    final snapshot = await store.load();

    expect(result.stateChanged, isTrue);
    expect(result.validUntilUtc, DateTime.utc(2026, 8, 21, 16));
    expect(snapshot.hasPro, isFalse);
    expect(snapshot.temporaryGrants, hasLength(1));
    expect(snapshot.temporaryGrants.single.featureId, RuhFeatureIds.pdfProfessionalExport);
    expect(snapshot.temporaryGrants.single.validUntilUtc, result.validUntilUtc);
  });

  test('reward never shortens an already longer active grant', () async {
    final database = _MemoryDatabase();
    final store = LocalEntitlementSnapshotStore(database);
    final existingExpiry = DateTime.utc(2026, 8, 25);
    await store.save(
      EntitlementSnapshot(
        hasPro: false,
        temporaryGrants: <TemporaryFeatureGrant>[
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.westernAdvanced,
            validUntilUtc: existingExpiry,
          ),
        ],
      ),
    );
    final coordinator = RewardedTemporaryUnlockCoordinator(
      store: store,
      clock: _FixedClock(DateTime.utc(2026, 8, 20)),
    );

    await coordinator.apply(
      featureId: RuhFeatureIds.westernAdvanced,
      outcome: RewardedAdOutcome.rewarded,
      duration: const Duration(days: 1),
    );

    final snapshot = await store.load();
    expect(snapshot.temporaryGrants.single.validUntilUtc, existingExpiry);
  });

  test('professional-only feature cannot be unlocked by rewarded ad', () async {
    final coordinator = RewardedTemporaryUnlockCoordinator(
      store: LocalEntitlementSnapshotStore(_MemoryDatabase()),
      clock: _FixedClock(DateTime.utc(2026, 8, 20)),
    );

    await expectLater(
      coordinator.apply(
        featureId: RuhFeatureIds.professionalClients,
        outcome: RewardedAdOutcome.rewarded,
        duration: const Duration(days: 1),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

final class _FixedClock implements EntitlementClock {
  const _FixedClock(this.value);
  final DateTime value;

  @override
  Future<DateTime> nowUtc() async => value;
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
              (entry) => MapEntry(entry.key, Map<String, Object?>.from(entry.value)),
            ),
      );

  @override
  Future<void> clearTable(String table) async {
    _tables.remove(table);
  }
}
