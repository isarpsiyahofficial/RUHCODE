import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/csv_codec.dart';
import 'package:ruh_code/src/backup/legacy_backup_v0_migrator.dart';
import 'package:ruh_code/src/backup/local_database_backup_import_store.dart';
import 'package:ruh_code/src/data/local/core_model_codecs.dart';
import 'package:ruh_code/src/data/local/core_repositories.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  const csv = RuhCsvDocumentCodec();
  const migrator = LegacyBackupV0Migrator();

  test('legacy v0 exact birth time adopts current schema without invented records', () async {
    final root = await Directory.systemTemp.createTemp('ruh_code_legacy_v0_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    final legacy = <String, List<int>>{
      'profiles.csv': utf8.encode(csv.encode(<List<String?>>[
        LegacyBackupV0Migrator.legacyProfileHeader,
        <String?>[
          '20000000-0000-4000-8000-000000000001',
          'İbrahim',
          '2002-06-23',
          '12:34:00',
          'Antalya, Türkiye',
          'TR',
          '36.8969',
          '30.7133',
          'Europe/Istanbul',
          '2026-01-01T00:00:00.000Z',
          '2026-01-02T00:00:00.000Z',
        ],
      ])),
      'settings.csv': utf8.encode(csv.encode(<List<String?>>[
        LegacyBackupV0Migrator.legacySettingsHeader,
        <String?>['language', 'tr'],
      ])),
    };

    final migrated = migrator.migrate(
      legacyFiles: legacy,
      appVersion: '0.1.0+1',
      engineVersion: 'legacy-v0-migration-test',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 20, 6),
    );
    final preview = const BackupPackageReader().preview(migrated);
    expect(preview.valid, isTrue, reason: preview.issues.join('\n'));
    expect(preview.recordCounts['profiles.csv'], 1);
    expect(preview.recordCounts['settings.csv'], 1);
    for (final entry in preview.recordCounts.entries) {
      if (entry.key != 'profiles.csv' && entry.key != 'settings.csv') {
        expect(entry.value, 0, reason: 'Legacy migration must not invent ${entry.key} records.');
      }
    }

    final profileRow = preview.rowsByTable['profiles.csv']!.single;
    expect(profileRow[3], 'exact');

    final database = SqfliteLocalDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${root.path}/legacy_target.db',
    );
    await database.open();
    addTearDown(database.close);

    await BackupImportCoordinator(
      store: LocalDatabaseBackupImportStore(
        database: database,
        snapshotDirectory: Directory('${root.path}/snapshots'),
      ),
    ).apply(preview: preview, mode: BackupImportMode.replace);

    final profile = await CoreRepositories(database).profiles.findById(
      '20000000-0000-4000-8000-000000000001',
    );
    expect(profile, isNotNull);
    final map = CoreModelCodecs.profileToMap(profile!);
    expect(map['displayName'], 'İbrahim');
    final birthData = map['birthData']! as Map<String, Object?>;
    expect(birthData['timeKnowledge'], 'exact');
    expect(birthData['localTime'], '12:34:00');
  });

  test('legacy v0 missing birth time becomes unknown, never midnight', () {
    final legacy = <String, List<int>>{
      'profiles.csv': utf8.encode(csv.encode(<List<String?>>[
        LegacyBackupV0Migrator.legacyProfileHeader,
        <String?>[
          '20000000-0000-4000-8000-000000000002',
          'Saat Bilinmiyor',
          '1999-08-20',
          null,
          'İzmir, Türkiye',
          'TR',
          '38.4237',
          '27.1428',
          'Europe/Istanbul',
          '2026-01-01T00:00:00.000Z',
          '2026-01-02T00:00:00.000Z',
        ],
      ])),
    };

    final preview = const BackupPackageReader().preview(
      migrator.migrate(
        legacyFiles: legacy,
        appVersion: '0.1.0+1',
        engineVersion: 'legacy-v0-migration-test',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20, 7),
      ),
    );
    expect(preview.valid, isTrue, reason: preview.issues.join('\n'));
    final row = preview.rowsByTable['profiles.csv']!.single;
    expect(row[3], 'unknown');
    expect(row[4], isNull);
    expect(row[4], isNot('00:00:00'));
  });

  test('legacy v0 rejects unknown files and incompatible headers', () {
    expect(
      () => migrator.migrate(
        legacyFiles: <String, List<int>>{
          'profiles.csv': utf8.encode('id,name\n1,A'),
          'mystery.csv': utf8.encode('x\ny'),
        },
        appVersion: '0.1.0+1',
        engineVersion: 'test',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      ),
      throwsFormatException,
    );

    expect(
      () => migrator.migrate(
        legacyFiles: <String, List<int>>{
          'profiles.csv': utf8.encode('id,name\n1,A'),
        },
        appVersion: '0.1.0+1',
        engineVersion: 'test',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      ),
      throwsFormatException,
    );
  });
}
