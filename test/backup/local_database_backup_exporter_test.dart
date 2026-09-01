import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/persistence/ruh_local_database.dart';

void main() {
  test('exports deterministic schema-backed rows from database records', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'clients': <String, Map<String, Object?>>{
        'b': <String, Object?>{
          'id': 'b',
          'display_name': 'B',
          'birth_data_json': null,
          'tags_json': <Object?>[
            <String, Object?>{'z': 1, 'a': 2},
          ],
          'created_at_utc': '2026-08-20T00:00:00.000Z',
          'updated_at_utc': '2026-08-20T00:00:00.000Z',
        },
        'a': <String, Object?>{
          'id': 'a',
          'display_name': 'A',
          'birth_data_json': null,
          'tags_json': <Object?>[],
          'created_at_utc': '2026-08-20T00:00:00.000Z',
          'updated_at_utc': '2026-08-20T00:00:00.000Z',
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

  test('rejects missing required payload column before package creation', () async {
    final db = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'settings': <String, Map<String, Object?>>{
        'language': <String, Object?>{'key': 'language'},
      },
    });

    await expectLater(
      LocalDatabaseBackupExporter(database: db).exportRows(),
      throwsStateError,
    );
  });
}

final class _FakeDatabase extends RuhLocalDatabase {
  _FakeDatabase(this.records) : super.withDatabaseFactory(() async => throw UnimplementedError());

  final Map<String, Map<String, Map<String, Object?>>> records;

  @override
  Future<List<Map<String, Object?>>> readStoreRecords(String store) async {
    final values = records[store]?.values ?? const Iterable<Map<String, Object?>>.empty();
    return values
        .map(
          (row) => <String, Object?>{
            for (final entry in row.entries)
              entry.key: _storageValue(entry.value),
          },
        )
        .toList(growable: false);
  }

  static Object? _storageValue(Object? value) {
    if (value is Map || value is List) {
      return jsonEncode(value);
    }
    return value;
  }
}
