import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/backup/local_database_backup_import_store.dart';
import 'package:ruh_code/src/backup/portable_zip_backup_codec.dart';
import 'package:ruh_code/src/data/local/core_model_codecs.dart';
import 'package:ruh_code/src/data/local/core_repositories.dart';
import 'package:ruh_code/src/data/local/sqflite_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _profileId = '10000000-0000-4000-8000-000000000001';
const _clientId = '10000000-0000-4000-8000-000000000002';
const _consultationId = '10000000-0000-4000-8000-000000000003';
const _noteId = '10000000-0000-4000-8000-000000000004';
const _manifestId = '10000000-0000-4000-8000-000000000005';
const _calculationId = '10000000-0000-4000-8000-000000000006';
const _journalId = '10000000-0000-4000-8000-000000000007';
const _goalId = '10000000-0000-4000-8000-000000000008';
const _habitId = '10000000-0000-4000-8000-000000000009';
const _tarotId = '10000000-0000-4000-8000-000000000010';
const _presetId = '10000000-0000-4000-8000-000000000011';
const _templateId = '10000000-0000-4000-8000-000000000012';
const _favoriteId = '10000000-0000-4000-8000-000000000013';
const _tarotCardId = '10000000-0000-4000-8000-000000000014';

void main() {
  sqfliteFfiInit();

  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ruh_code_backup_all_tables_');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('all 15 logical tables are non-empty and survive portable replace restore', () async {
    final source = await _openDatabase('${root.path}/all_tables_source.db');
    final target = await _openDatabase('${root.path}/all_tables_target.db');
    addTearDown(source.close);
    addTearDown(target.close);

    await _seedAllTables(source);
    final expected = await _snapshotRegisteredTables(source);

    expect(expected.length, BackupSchemaRegistry.tables.length);
    for (final schema in BackupSchemaRegistry.tables) {
      final table = _logicalTableName(schema.fileName);
      expect(expected[table], isNotEmpty, reason: '${schema.fileName} fixture must be non-empty.');
    }

    final package = await LocalDatabaseBackupExporter(database: source).exportPackage(
      appVersion: '0.1.0+1',
      engineVersion: 'backup-all-tables-test',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 20, 4),
    );
    const zipCodec = PortableZipBackupCodec();
    final preview = const BackupPackageReader().preview(
      zipCodec.decode(zipCodec.encode(package)),
    );
    expect(preview.valid, isTrue, reason: _issueSummary(preview));
    expect(preview.recordCounts.length, 15);
    for (final count in preview.recordCounts.values) {
      expect(count, greaterThan(0));
    }

    await BackupImportCoordinator(
      store: LocalDatabaseBackupImportStore(
        database: target,
        snapshotDirectory: Directory('${root.path}/all_tables_target_snapshots'),
      ),
    ).apply(preview: preview, mode: BackupImportMode.replace);

    expect(await _snapshotRegisteredTables(target), expected);
  });

  test('export -> erase -> restore preserves domain objects and raw registered tables', () async {
    final database = await _openDatabase('${root.path}/erase_restore.db');
    addTearDown(database.close);

    await _seedAllTables(database);
    final expectedRaw = await _snapshotRegisteredTables(database);
    final expectedDomain = await _domainSnapshot(database);

    final package = await LocalDatabaseBackupExporter(database: database).exportPackage(
      appVersion: '0.1.0+1',
      engineVersion: 'backup-erase-restore-test',
      localeTag: 'en',
      exportedAtUtc: DateTime.utc(2026, 8, 20, 5),
    );
    const zipCodec = PortableZipBackupCodec();
    final preview = const BackupPackageReader().preview(
      zipCodec.decode(zipCodec.encode(package)),
    );
    expect(preview.valid, isTrue, reason: _issueSummary(preview));

    await database.transaction<void>((tx) async {
      for (final schema in BackupSchemaRegistry.tables) {
        await tx.clearTable(_logicalTableName(schema.fileName));
      }
    });
    final erased = await _snapshotRegisteredTables(database);
    for (final table in erased.values) {
      expect(table, isEmpty);
    }

    await BackupImportCoordinator(
      store: LocalDatabaseBackupImportStore(
        database: database,
        snapshotDirectory: Directory('${root.path}/erase_restore_snapshots'),
      ),
    ).apply(preview: preview, mode: BackupImportMode.replace);

    expect(await _snapshotRegisteredTables(database), expectedRaw);
    expect(await _domainSnapshot(database), expectedDomain);
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

Future<void> _seedAllTables(SqfliteLocalDatabase database) {
  const created = '2026-08-20T01:00:00.000Z';
  const updated = '2026-08-20T01:30:00.000Z';
  return database.transaction<void>((tx) async {
    await tx.put(
      table: 'profiles',
      id: _profileId,
      value: <String, Object?>{
        'id': _profileId,
        'displayName': 'İbrahim Yeşilyurt',
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
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'clients',
      id: _clientId,
      value: <String, Object?>{
        'id': _clientId,
        'displayName': 'Zehra Örnek',
        'birthData': <String, Object?>{
          'localDateIso': '1999-08-20',
          'timeKnowledge': 'unknown',
          'localTime': null,
          'location': <String, Object?>{
            'label': 'İzmir, Türkiye',
            'countryCode': 'TR',
            'latitude': 38.4237,
            'longitude': 27.1428,
            'ianaTimeZoneId': 'Europe/Istanbul',
          },
        },
        'tags': <String>['vedik', 'öncelikli'],
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'consultations',
      id: _consultationId,
      value: const <String, Object?>{
        'id': _consultationId,
        'clientId': _clientId,
        'startedAtUtc': '2026-08-20T02:00:00.000Z',
        'endedAtUtc': '2026-08-20T03:00:00.000Z',
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'notes',
      id: _noteId,
      value: const <String, Object?>{
        'id': _noteId,
        'ownerEntityId': _consultationId,
        'text': 'Çok satırlı not, virgül ve “tırnak” içerir.\nİkinci satır.',
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'calculation_manifests',
      id: _manifestId,
      value: <String, Object?>{
        'id': _manifestId,
        'engineId': 'western_natal',
        'engineVersion': '1.0.0',
        'algorithmVersion': '1',
        'dataVersion': 'test-data-v1',
        'timezoneDatabaseVersion': '2026a',
        'localDateTime': '2002-06-23T12:34:00.000',
        'utcDateTime': '2002-06-23T09:34:00.000Z',
        'location': <String, Object?>{
          'label': 'Antalya, Türkiye',
          'countryCode': 'TR',
          'latitude': 36.8969,
          'longitude': 30.7133,
          'ianaTimeZoneId': 'Europe/Istanbul',
        },
        'validity': 'valid',
        'houseSystemId': 'whole_sign',
        'zodiacSystemId': 'tropical',
        'ayanamshaId': null,
        'nodeModeId': 'true_node',
      },
    );
    await tx.put(
      table: 'calculations',
      id: _calculationId,
      value: <String, Object?>{
        'id': _calculationId,
        'manifestId': _manifestId,
        'ownerEntityId': _profileId,
        'calculationType': 'western_natal',
        'payloadJson': <String, Object?>{'sunLongitude': 91.25, 'moonLongitude': 224.5},
        'createdAtUtc': created,
      },
    );
    await tx.put(
      table: 'journal_entries',
      id: _journalId,
      value: const <String, Object?>{
        'id': _journalId,
        'profileId': _profileId,
        'localDateIso': '2026-08-20',
        'text': 'Bugünkü gözlem ✨',
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'goals',
      id: _goalId,
      value: const <String, Object?>{
        'id': _goalId,
        'profileId': _profileId,
        'title': 'Haftalık değerlendirme',
        'completed': false,
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'habits',
      id: _habitId,
      value: const <String, Object?>{
        'id': _habitId,
        'profileId': _profileId,
        'title': 'Sabah notu',
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'tarot_sessions',
      id: _tarotId,
      value: <String, Object?>{
        'id': _tarotId,
        'clientId': _clientId,
        'spreadId': 'three_card',
        'cardIds': <String>['star', 'hermit', 'sun'],
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'tarot_cards',
      id: _tarotCardId,
      value: const <String, Object?>{
        'id': _tarotCardId,
        'sessionId': _tarotId,
        'positionIndex': 0,
        'cardId': 'star',
        'orientation': 'upright',
      },
    );
    await tx.put(
      table: 'professional_presets',
      id: _presetId,
      value: <String, Object?>{
        'id': _presetId,
        'name': 'Danışmanlık Preseti',
        'systemId': 'western',
        'settings': <String, String>{'houseSystem': 'whole_sign', 'orbProfile': 'standard'},
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'interpretation_templates',
      id: _templateId,
      value: const <String, Object?>{
        'id': _templateId,
        'systemId': 'western',
        'ruleId': 'sun_taurus',
        'localeTag': 'tr',
        'text': 'Güneş Boğa yorumu.',
        'createdAtUtc': created,
        'updatedAtUtc': updated,
      },
    );
    await tx.put(
      table: 'settings',
      id: 'language',
      value: const <String, Object?>{'key': 'language', 'value': 'tr'},
    );
    await tx.put(
      table: 'favorites',
      id: _favoriteId,
      value: const <String, Object?>{
        'id': _favoriteId,
        'ownerEntityId': _profileId,
        'targetType': 'calculation',
        'targetId': _calculationId,
        'createdAtUtc': created,
      },
    );
  });
}

Future<Map<String, Map<String, Map<String, Object?>>>> _snapshotRegisteredTables(
  SqfliteLocalDatabase database,
) {
  return database.transaction<Map<String, Map<String, Map<String, Object?>>>>((tx) async {
    final result = <String, Map<String, Map<String, Object?>>>{};
    for (final schema in BackupSchemaRegistry.tables) {
      result[_logicalTableName(schema.fileName)] = await tx.readTable(
        _logicalTableName(schema.fileName),
      );
    }
    return result;
  });
}

Future<Map<String, Object?>> _domainSnapshot(SqfliteLocalDatabase database) async {
  final repositories = CoreRepositories(database);
  final profile = await repositories.profiles.findById(_profileId);
  final client = await repositories.clients.findById(_clientId);
  final consultation = await repositories.consultations.findById(_consultationId);
  final note = await repositories.notes.findById(_noteId);
  final manifest = await repositories.calculationManifests.findById(_manifestId);
  final journal = await repositories.journalEntries.findById(_journalId);
  final goal = await repositories.goals.findById(_goalId);
  final habit = await repositories.habits.findById(_habitId);
  final tarot = await repositories.tarotSessions.findById(_tarotId);
  final preset = await repositories.professionalPresets.findById(_presetId);
  final template = await repositories.interpretationTemplates.findById(_templateId);

  expect(profile, isNotNull);
  expect(client, isNotNull);
  expect(consultation, isNotNull);
  expect(note, isNotNull);
  expect(manifest, isNotNull);
  expect(journal, isNotNull);
  expect(goal, isNotNull);
  expect(habit, isNotNull);
  expect(tarot, isNotNull);
  expect(preset, isNotNull);
  expect(template, isNotNull);

  return <String, Object?>{
    'profile': CoreModelCodecs.profileToMap(profile!),
    'client': CoreModelCodecs.clientToMap(client!),
    'consultation': CoreModelCodecs.consultationToMap(consultation!),
    'note': CoreModelCodecs.noteToMap(note!),
    'manifest': CoreModelCodecs.calculationManifestToMap(manifest!),
    'journal': CoreModelCodecs.journalEntryToMap(journal!),
    'goal': CoreModelCodecs.goalToMap(goal!),
    'habit': CoreModelCodecs.habitToMap(habit!),
    'tarot': CoreModelCodecs.tarotSessionToMap(tarot!),
    'preset': CoreModelCodecs.professionalPresetToMap(preset!),
    'template': CoreModelCodecs.interpretationTemplateToMap(template!),
  };
}

String _logicalTableName(String fileName) => fileName.substring(0, fileName.length - 4);

String _issueSummary(BackupImportPreview preview) {
  return preview.issues.map((issue) => issue.toString()).join('\n');
}
