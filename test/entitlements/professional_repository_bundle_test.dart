import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/core_repositories.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/entitlements/professional_repository_bundle.dart';

void main() {
  test('professional repositories use canonical professional feature IDs', () {
    final database = _MemoryDatabase();
    final core = CoreRepositories(database);
    final guard = FeatureAccessGuard(
      entitlements: _AlwaysProEntitlementService(),
    );

    final bundle = ProfessionalRepositoryBundle(
      featureAccess: guard,
      core: core,
    );

    expect(bundle.clients.featureId, RuhFeatureIds.professionalClients);
    expect(bundle.consultations.featureId, RuhFeatureIds.professionalClients);
    expect(bundle.notes.featureId, RuhFeatureIds.professionalClients);
    expect(bundle.presets.featureId, RuhFeatureIds.professionalPresets);
    expect(
      bundle.interpretationTemplates.featureId,
      RuhFeatureIds.professionalPresets,
    );
  });
}

final class _AlwaysProEntitlementService implements EntitlementService {
  @override
  Future<bool> canUse(String featureId) async => true;

  @override
  Future<FeatureEntitlement> resolve(String featureId) async =>
      FeatureEntitlement(featureId: featureId, tier: EntitlementTier.pro);
}

final class _MemoryDatabase implements LocalDatabase {
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
      action(_MemoryTransaction());
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  final Map<String, Map<String, Map<String, Object?>>> _tables = {};

  @override
  Future<void> put({
    required String table,
    required String id,
    required Map<String, Object?> value,
  }) async {
    (_tables[table] ??= {})[id] = Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async =>
      _tables[table]?[id];

  @override
  Future<void> delete({required String table, required String id}) async {
    _tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(_tables[table] ?? const {});

  @override
  Future<void> clearTable(String table) async {
    _tables[table]?.clear();
  }
}
