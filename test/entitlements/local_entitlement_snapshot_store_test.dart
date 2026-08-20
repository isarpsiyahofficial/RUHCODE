import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/entitlements/local_entitlement_snapshot_store.dart';

final class _MemoryDatabase implements LocalDatabase {
  final Map<String, Map<String, Map<String, Object?>>> tables = {};

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async => const IntegrityCheckResult(ok: true);

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) =>
      action(_MemoryTransaction(tables));
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  _MemoryTransaction(this.tables);
  final Map<String, Map<String, Map<String, Object?>>> tables;

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    tables.putIfAbsent(table, () => {})[id] = Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = tables[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(tables[table] ?? {});

  @override
  Future<void> clearTable(String table) async => tables.remove(table);
}

void main() {
  test('missing local entitlement state defaults to Free without mutating user tables', () async {
    final db = _MemoryDatabase();
    db.tables['profiles'] = {
      'p1': <String, Object?>{'displayName': 'İbrahim'},
    };
    final before = Map<String, Map<String, Object?>>.from(db.tables['profiles']!);
    final store = LocalEntitlementSnapshotStore(db);

    final snapshot = await store.load();

    expect(snapshot.hasPro, isFalse);
    expect(snapshot.temporaryGrants, isEmpty);
    expect(db.tables['profiles'], before);
  });

  test('PRO and temporary grants round trip in dedicated system table only', () async {
    final db = _MemoryDatabase();
    db.tables['clients'] = {
      'c1': <String, Object?>{'displayName': 'Client'},
    };
    final store = LocalEntitlementSnapshotStore(db);
    final expiry = DateTime.utc(2026, 8, 21, 10);

    await store.save(
      EntitlementSnapshot(
        hasPro: true,
        temporaryGrants: <TemporaryFeatureGrant>[
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.pdfProfessionalExport,
            validUntilUtc: expiry,
          ),
        ],
      ),
    );
    final loaded = await store.load();

    expect(loaded.hasPro, isTrue);
    expect(loaded.temporaryGrants, hasLength(1));
    expect(loaded.temporaryGrants.single.featureId, RuhFeatureIds.pdfProfessionalExport);
    expect(loaded.temporaryGrants.single.validUntilUtc, expiry);
    expect(db.tables['clients']?['c1']?['displayName'], 'Client');
    expect(db.tables.keys, contains(LocalEntitlementSnapshotStore.tableName));
  });

  test('clear removes entitlement state without clearing domain data', () async {
    final db = _MemoryDatabase();
    db.tables['notes'] = {
      'n1': <String, Object?>{'text': 'keep me'},
    };
    final store = LocalEntitlementSnapshotStore(db);
    await store.save(const EntitlementSnapshot(hasPro: true));

    await store.clear();

    expect((await store.load()).hasPro, isFalse);
    expect(db.tables['notes']?['n1']?['text'], 'keep me');
  });

  test('non UTC temporary grant cannot be persisted', () async {
    final store = LocalEntitlementSnapshotStore(_MemoryDatabase());
    await expectLater(
      store.save(
        EntitlementSnapshot(
          hasPro: false,
          temporaryGrants: <TemporaryFeatureGrant>[
            TemporaryFeatureGrant(
              featureId: RuhFeatureIds.pdfProfessionalExport,
              validUntilUtc: DateTime(2026, 8, 21),
            ),
          ],
        ),
      ),
      throwsFormatException,
    );
  });
}
