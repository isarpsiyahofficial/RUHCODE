import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/local_database_backup_import_store.dart';
import 'package:ruh_code/src/data/local/core_repositories.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory tempDirectory;
  late SqfliteLocalDatabase database;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('ruh_code_backup_store_');
    database = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${tempDirectory.path}/ruh_code.db',
    );
    await database.open();
  });

  tearDown(() async {
    await database.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('merge import writes canonical profile payload readable by repositories', () async {
    final writer = BackupPackageWriter();
    final package = writer.write(
      rowsByTable: <String, List<List<String?>>>{
        'profiles.csv': <List<String?>>[
          <String?>[
            '11111111-1111-4111-8111-111111111111',
            'Ayşe Yılmaz',
            '1992-04-24',
            'exact',
            '07:35',
            'İstanbul',
            'TR',
            '41.0082',
            '28.9784',
            'Europe/Istanbul',
            '2026-08-19T20:00:00.000Z',
            '2026-08-19T20:00:00.000Z',
          ],
        ],
      },
      appVersion: 'test',
      engineVersion: 'test',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 19, 20),
    );
    final preview = const BackupPackageReader().preview(package);
    expect(preview.valid, isTrue);

    final store = LocalDatabaseBackupImportStore(
      database: database,
      snapshotDirectory: Directory('${tempDirectory.path}/snapshots'),
    );
    await BackupImportCoordinator(store: store).apply(
      preview: preview,
      mode: BackupImportMode.merge,
    );

    final profile = await CoreRepositories(database).profiles.findById(
      '11111111-1111-4111-8111-111111111111',
    );
    expect(profile, isNotNull);
    expect(profile!.displayName, 'Ayşe Yılmaz');
    expect(profile.birthData.localDateIso, '1992-04-24');
    expect(profile.birthData.localTime, '07:35');
    expect(profile.birthData.location.ianaTimeZoneId, 'Europe/Istanbul');
    expect(profile.birthData.location.latitude, closeTo(41.0082, 0.000001));
  });

  test('durable safety snapshot restores records after destructive mutation', () async {
    const table = 'settings';
    await database.transaction<void>((tx) async {
      await tx.put(
        table: table,
        id: 'language',
        value: const <String, Object?>{'key': 'language', 'value': 'tr'},
      );
    });

    final snapshotDirectory = Directory('${tempDirectory.path}/snapshots');
    final store = LocalDatabaseBackupImportStore(
      database: database,
      snapshotDirectory: snapshotDirectory,
    );
    final token = await store.createSafetySnapshot();
    final snapshotFiles = await snapshotDirectory
        .list()
        .where((entity) => entity is File)
        .toList();
    expect(snapshotFiles, hasLength(1));

    await database.transaction<void>((tx) async {
      await tx.clearTable(table);
      await tx.put(
        table: table,
        id: 'language',
        value: const <String, Object?>{'key': 'language', 'value': 'en'},
      );
    });

    await store.restoreSafetySnapshot(token);

    final restored = await database.transaction<Map<String, Object?>?>((tx) {
      return tx.get(table: table, id: 'language');
    });
    expect(restored, const <String, Object?>{'key': 'language', 'value': 'tr'});
  });
}
