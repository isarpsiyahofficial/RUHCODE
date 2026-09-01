import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/data/local/local_database.dart';

void main() {
  test('exports runtime profile payload to canonical CSV schema', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'profiles': <String, Map<String, Object?>>{
        'profile-1': <String, Object?>{
          'id': 'profile-1',
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
      },
    });

    final rows = await LocalDatabaseBackupExporter(database: db).exportRows();
    final profile = rows['profiles.csv']!.single;

    expect(profile, <String?>[
      'profile-1',
      'İbrahim',
      '2002-06-23',
      'exact',
      '12:34:00',
      'Antalya, Türkiye',
      'TR',
      '36.8969',
      '30.7133',
      'Europe/Istanbul',
      '2026-08-20T00:00:00.000Z',
      '2026-08-20T00:01:00.000Z',
    ]);
  });

  test('exports records in stable id order and canonicalizes JSON object keys', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'clients': <String, Map<String, Object?>>{
        'b': <String, Object?>{
          'id': 'b',
          'displayName': 'B',
          'birthData': null,
          'tags': <Object?>[
            <String, Object?>{'z': 1, 'a': 2}
          ],
          'createdAtUtc': '2026-08-20T00:00:00.000Z',
          'updatedAtUtc': '2026-08-20T00:00:00.000Z',
        },
        'a': <String, Object?>{
          'id': 'a',
          'displayName': 'A',
          'birthData': null,
          'tags': <String>[],
          'createdAtUtc': '2026-08-20T00:00:00.000Z',
          'updatedAtUtc': '2026-08-20T00:00:00.000Z',
        },
      },
    });

    final rows = await LocalDatabaseBackupExporter(database: db).exportRows();
    expect(rows['clients.csv']![0][0], 'a');
    expect(rows['clients.csv']![1][0], 'b');
    expect(rows['clients.csv']![1][3], '[{"a":2,"z":1}]');
  });

  test('exportPackage creates a package accepted by strict package preview', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'settings': <String, Map<String, Object?>>{
        'language': <String, Object?>{'key': 'language', 'value': 'tr'},
      },
    });
    final exporter = LocalDatabaseBackupExporter(database: db);

    final package = await exporter.exportPackage(
      appVersion: '0.1.0+1',
      engineVersion: 'test-engine',
      localeTag: 'tr',
      exportedAtUtc: DateTime.utc(2026, 8, 20),
    );
    final preview = const BackupPackageReader().preview(package);

    expect(preview.valid, isTrue);
    expect(preview.recordCounts.length, 15);
    expect(preview.recordCounts['settings.csv'], 1);
    expect(preview.rowsByTable['settings.csv']!.single, <String?>['language', 'tr']);
  });

  test('rejects storage key/payload id mismatch', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'settings': <String, Map<String, Object?>>{
        'language': <String, Object?>{'key': 'different', 'value': 'tr'},
      },
    });

    await expectLater(
      LocalDatabaseBackupExporter(database: db).exportRows(),
      throwsStateError,
    );
  });
}

final class _FakeDatabase implements LocalDatabase {
  _FakeDatabase(this.tables);

  final Map<String, Map<String, Map<String, Object?>>> tables;

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
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) {
    return action(_FakeTransaction(tables));
  }
}

final class _FakeTransaction implements LocalDatabaseTransaction {
  _FakeTransaction(this.tables);

  final Map<String, Map<String, Map<String, Object?>>> tables;

  @override
  Future<void> clearTable(String table) async => tables[table] = {};

  @override
  Future<void> delete({required String table, required String id}) async {
    tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async =>
      tables[table]?[id];

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    (tables[table] ??= <String, Map<String, Object?>>{})[id] = value;
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(
        tables[table] ?? const <String, Map<String, Object?>>{},
      );
}
