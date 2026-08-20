import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/json_record_repository.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/entitlements/guarded_record_repository.dart';

void main() {
  test('locked professional repository cannot read or mutate delegate', () async {
    final database = _MemoryDatabase();
    final delegate = _stringRepository(database);
    final entitlements = _StaticEntitlementService(false);
    final guarded = GuardedRecordRepository<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      featureId: RuhFeatureIds.professionalClients,
      delegate: delegate,
    );

    await expectLater(guarded.save('client-a'), throwsA(isA<FeatureAccessDeniedException>()));
    await expectLater(guarded.findById('client-a'), throwsA(isA<FeatureAccessDeniedException>()));
    await expectLater(guarded.deleteById('client-a'), throwsA(isA<FeatureAccessDeniedException>()));

    expect(database.transactionCount, 0);
    expect(database.records, isEmpty);
  });

  test('PRO professional repository executes through delegate', () async {
    final database = _MemoryDatabase();
    final delegate = _stringRepository(database);
    final entitlements = _StaticEntitlementService(true);
    final guarded = GuardedRecordRepository<String>(
      featureAccess: FeatureAccessGuard(entitlements: entitlements),
      featureId: RuhFeatureIds.professionalClients,
      delegate: delegate,
    );

    await guarded.save('client-a');
    expect(await guarded.findById('client-a'), 'client-a');
    await guarded.replaceAtomically(oldValue: 'client-a', newValue: 'client-b');
    expect(await guarded.findById('client-a'), isNull);
    expect(await guarded.findById('client-b'), 'client-b');
    await guarded.deleteById('client-b');
    expect(await guarded.findById('client-b'), isNull);

    expect(database.transactionCount, 7);
  });
}

JsonRecordRepository<String> _stringRepository(LocalDatabase database) {
  return JsonRecordRepository<String>(
    database: database,
    table: 'clients',
    idOf: (value) => value,
    encode: (value) => <String, Object?>{'value': value},
    decode: (value) => value['value']! as String,
  );
}

final class _StaticEntitlementService implements EntitlementService {
  _StaticEntitlementService(this.allowed);
  final bool allowed;

  @override
  Future<bool> canUse(String featureId) async => allowed;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async => FeatureEntitlement(
        featureId: featureId,
        tier: allowed ? EntitlementTier.pro : EntitlementTier.free,
      );
}

final class _MemoryDatabase implements LocalDatabase, LocalDatabaseTransaction {
  final Map<String, Map<String, Map<String, Object?>>> records =
      <String, Map<String, Map<String, Object?>>>{};
  int transactionCount = 0;

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
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) async {
    transactionCount += 1;
    return action(this);
  }

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    records.putIfAbsent(table, () => <String, Map<String, Object?>>{})[id] =
        Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = records[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    records[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(records[table] ?? const <String, Map<String, Object?>>{});

  @override
  Future<void> clearTable(String table) async {
    records[table]?.clear();
  }
}
