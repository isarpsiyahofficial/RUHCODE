import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';
import 'package:ruh_code/src/entitlements/local_entitlement_snapshot_store.dart';
import 'package:ruh_code/src/entitlements/local_entitlement_time_anchor.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class _WallClock implements EntitlementWallClock {
  _WallClock(this.value);
  DateTime value;

  @override
  DateTime nowUtc() => value;
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('Free to PRO to Free changes only dedicated entitlement rows', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    const domainFixtures = <String, Map<String, Map<String, Object?>>>{
      'profiles': {
        'profile-1': <String, Object?>{
          'displayName': 'İbrahim',
          'localDateIso': '2002-06-23',
        },
      },
      'clients': {
        'client-1': <String, Object?>{
          'displayName': 'Danışan',
          'profileId': 'profile-1',
        },
      },
      'notes': {
        'note-1': <String, Object?>{
          'text': 'Bu kayıt entitlement değişiminde aynen kalmalı.',
        },
      },
      'calculations': {
        'calc-1': <String, Object?>{
          'engineVersion': 'test-engine-v1',
          'snapshotDigest': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        },
      },
    };

    for (final tableEntry in domainFixtures.entries) {
      for (final recordEntry in tableEntry.value.entries) {
        await db.transaction(
          (tx) => tx.put(
            table: tableEntry.key,
            id: recordEntry.key,
            value: recordEntry.value,
          ),
        );
      }
    }

    Future<Map<String, Map<String, Map<String, Object?>>>> snapshotDomain() async {
      final result = <String, Map<String, Map<String, Object?>>>{};
      for (final table in domainFixtures.keys) {
        result[table] = await db.transaction((tx) => tx.readTable(table));
      }
      return result;
    }

    final before = await snapshotDomain();
    final store = LocalEntitlementSnapshotStore(db);

    expect((await store.load()).hasPro, isFalse);
    await store.save(const EntitlementSnapshot(hasPro: true));
    expect((await store.load()).hasPro, isTrue);
    expect(await snapshotDomain(), before);

    await store.save(const EntitlementSnapshot(hasPro: false));
    expect((await store.load()).hasPro, isFalse);
    expect(await snapshotDomain(), before);
  });

  test('persistent time anchor cannot change user data in production SQLite adapter', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    await db.transaction(
      (tx) => tx.put(
        table: 'consultations',
        id: 'consultation-1',
        value: const <String, Object?>{
          'clientId': 'client-1',
          'notes': 'korunacak',
        },
      ),
    );
    final before = await db.transaction((tx) => tx.readTable('consultations'));

    final wall = _WallClock(DateTime.utc(2026, 8, 20, 14));
    final clock = LocalRollbackResistantEntitlementClock(
      database: db,
      wallClock: wall,
    );
    expect(await clock.nowUtc(), DateTime.utc(2026, 8, 20, 14));

    wall.value = DateTime.utc(2026, 8, 20, 8);
    expect(await clock.nowUtc(), DateTime.utc(2026, 8, 20, 14));

    final after = await db.transaction((tx) => tx.readTable('consultations'));
    expect(after, before);
  });

  test('stored PRO snapshot and rollback-resistant time combine offline', () async {
    final db = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    await db.open();
    addTearDown(db.close);

    final store = LocalEntitlementSnapshotStore(db);
    final wall = _WallClock(DateTime.utc(2026, 8, 20, 12));
    final clock = LocalRollbackResistantEntitlementClock(
      database: db,
      wallClock: wall,
    );
    final service = PolicyEntitlementService(
      snapshotProvider: store,
      clock: clock,
    );

    await store.save(
      EntitlementSnapshot(
        hasPro: false,
        temporaryGrants: <TemporaryFeatureGrant>[
          TemporaryFeatureGrant(
            featureId: RuhFeatureIds.pdfProfessionalExport,
            validUntilUtc: DateTime.utc(2026, 8, 20, 13),
          ),
        ],
      ),
    );
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isTrue);

    wall.value = DateTime.utc(2026, 8, 20, 14);
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isFalse);

    // Rolling the wall clock back cannot resurrect the expired grant.
    wall.value = DateTime.utc(2026, 8, 20, 10);
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isFalse);

    await store.save(const EntitlementSnapshot(hasPro: true));
    expect(await service.canUse(RuhFeatureIds.pdfProfessionalExport), isTrue);
  });
}
