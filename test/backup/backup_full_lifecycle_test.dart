import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/backup/local_database_backup_import_store.dart';
import 'package:ruh_code/src/backup/portable_zip_backup_codec.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ruh_code_backup_lifecycle_');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test(
    'SQLite export -> ZIP -> preview -> import preserves all registered tables and is idempotent',
    () async {
      final source = await _openDatabase('${root.path}/source.db');
      final target = await _openDatabase('${root.path}/target.db');
      addTearDown(source.close);
      addTearDown(target.close);

      await _seedRepresentativeData(source);
      final expected = await _snapshotRegisteredTables(source);

      final package = await LocalDatabaseBackupExporter(database: source).exportPackage(
        appVersion: '0.1.0+1',
        engineVersion: 'backup-lifecycle-test',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20, 1),
      );

      const zipCodec = PortableZipBackupCodec();
      final zipBytes = zipCodec.encode(package);
      expect(zipBytes, isNotEmpty);

      final decodedPackage = zipCodec.decode(zipBytes);
      final preview = const BackupPackageReader().preview(decodedPackage);
      expect(preview.valid, isTrue, reason: _issueSummary(preview));
      expect(preview.recordCounts.length, BackupSchemaRegistry.tables.length);

      final importStore = LocalDatabaseBackupImportStore(
        database: target,
        snapshotDirectory: Directory('${root.path}/target_snapshots'),
      );
      final coordinator = BackupImportCoordinator(store: importStore);

      await coordinator.apply(preview: preview, mode: BackupImportMode.merge);
      expect(await _snapshotRegisteredTables(target), expected);

      // Importing exactly the same portable backup twice must not create
      // duplicates or mutate canonical machine data.
      await coordinator.apply(preview: preview, mode: BackupImportMode.merge);
      expect(await _snapshotRegisteredTables(target), expected);
    },
  );

  test('TR and EN export metadata restore to identical machine storage', () async {
    final source = await _openDatabase('${root.path}/locale_source.db');
    final trTarget = await _openDatabase('${root.path}/tr_target.db');
    final enTarget = await _openDatabase('${root.path}/en_target.db');
    addTearDown(source.close);
    addTearDown(trTarget.close);
    addTearDown(enTarget.close);

    await _seedRepresentativeData(source);
    final expected = await _snapshotRegisteredTables(source);
    final exporter = LocalDatabaseBackupExporter(database: source);

    for (final entry in <(String, SqfliteLocalDatabase)>[
      ('tr', trTarget),
      ('en', enTarget),
    ]) {
      final package = await exporter.exportPackage(
        appVersion: '0.1.0+1',
        engineVersion: 'backup-locale-test',
        localeTag: entry.$1,
        exportedAtUtc: DateTime.utc(2026, 8, 20, 2),
      );
      final portable = const PortableZipBackupCodec().decode(
        const PortableZipBackupCodec().encode(package),
      );
      final preview = const BackupPackageReader().preview(portable);
      expect(preview.valid, isTrue, reason: _issueSummary(preview));

      await BackupImportCoordinator(
        store: LocalDatabaseBackupImportStore(
          database: entry.$2,
          snapshotDirectory: Directory('${root.path}/${entry.$1}_snapshots'),
        ),
      ).apply(preview: preview, mode: BackupImportMode.merge);

      expect(await _snapshotRegisteredTables(entry.$2), expected);
    }

    expect(
      await _snapshotRegisteredTables(trTarget),
      await _snapshotRegisteredTables(enTarget),
    );
  });

  test('portable restore preserves 2500 deterministic records without loss', () async {
    final source = await _openDatabase('${root.path}/stress_source.db');
    final target = await _openDatabase('${root.path}/stress_target.db');
    addTearDown(source.close);
    addTearDown(target.close);

    await source.transaction<void>((tx) async {
      for (var index = 0; index < 2500; index++) {
        final key = 'stress_${index.toString().padLeft(4, '0')}';
        await tx.put(
          table: 'settings',
          id: key,
          value: <String, Object?>{'key': key, 'value': 'değer-$index-İÜşğ'},
        );
      }
    });

    final expected = await _snapshotRegisteredTables(source);
    final package = await LocalDatabaseBackupExporter(database: source).exportPackage(
      appVersion: '0.1.0+1',
      engineVersion: 'backup-stress-test',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 20, 3),
    );
    const zipCodec = PortableZipBackupCodec();
    final preview = const BackupPackageReader().preview(
      zipCodec.decode(zipCodec.encode(package)),
    );
    expect(preview.valid, isTrue, reason: _issueSummary(preview));
    expect(preview.recordCounts['settings.csv'], 2500);

    await BackupImportCoordinator(
      store: LocalDatabaseBackupImportStore(
        database: target,
        snapshotDirectory: Directory('${root.path}/stress_snapshots'),
      ),
    ).apply(preview: preview, mode: BackupImportMode.replace);

    expect(await _snapshotRegisteredTables(target), expected);
  });
}

Future<SqfliteLocalDatabase> _openDatabase(String path) async {
  final database = SqfliteLocalDatabase(
    databaseFactory: databaseFactoryFfi,
    databasePath: path,
  );
  await database.open();
  return database;
}

Future<void> _seedRepresentativeData(SqfliteLocalDatabase database) {
  return database.transaction<void>((tx) async {
    await tx.put(
      table: 'profiles',
      id: '11111111-1111-4111-8111-111111111111',
      value: <String, Object?>{
        'id': '11111111-1111-4111-8111-111111111111',
        'displayName': 'İbrahim',
        'birthData': <String, Object?>{
          'localDateIso': '2002-06-23',
          'timeKnowledge': 'exact',
          'localTime': '12:34:00',
          'location': <String, Object?>{
            'label': 'Antalya, Türkiye',
            'countryCode': 'TR',
            'latitude': 36.8969,
            'longitude': 30.7133,
            'ianaTimeZoneId': 'Europe/Istanbul',
          },
        },
        'createdAtUtc': '2026-08-20T00:00:00.000Z',
        'updatedAtUtc': '2026-08-20T00:01:00.000Z',
      },
    );

    await tx.put(
      table: 'settings',
      id: 'language',
      value: const <String, Object?>{'key': 'language', 'value': 'tr'},
    );
  });
}

Future<Map<String, Map<String, Map<String, Object?>>>> _snapshotRegisteredTables(
  SqfliteLocalDatabase database,
) {
  return database.transaction<Map<String, Map<String, Map<String, Object?>>>>((tx) async {
    final result = <String, Map<String, Map<String, Object?>>>{};
    for (final schema in BackupSchemaRegistry.tables) {
      final table = schema.fileName.substring(0, schema.fileName.length - 4);
      result[table] = await tx.readTable(table);
    }
    return result;
  });
}

String _issueSummary(BackupImportPreview preview) {
  return preview.issues.map((issue) => issue.toString()).join('\n');
}
