import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/csv_codec.dart';
import 'package:ruh_code/src/backup/local_database_backup_exporter.dart';
import 'package:ruh_code/src/backup/single_table_csv_exporter.dart';
import 'package:ruh_code/src/data/local/local_database.dart';

void main() {
  test('exports exactly one canonical table as UTF-8 CSV with header', () async {
    final database = _FakeDatabase(<String, Map<String, Map<String, Object?>>>{
      'settings': <String, Map<String, Object?>>{
        'greeting': <String, Object?>{
          'key': 'greeting',
          'value': 'Merhaba, İstanbul\n"Ruh Code"',
        },
        'nullable': <String, Object?>{
          'key': 'nullable',
          'value': null,
        },
      },
    });
    final exporter = SingleTableCsvExporter(
      databaseExporter: LocalDatabaseBackupExporter(database: database),
    );

    final result = await exporter.export('settings.csv');

    expect(result.fileName, 'settings.csv');
    expect(result.recordCount, 2);
    final text = utf8.decode(result.bytes);
    final rows = const RuhCsvDocumentCodec().decode(text);
    expect(rows.first, <String?>['key', 'value']);
    expect(rows.length, 3);
    expect(rows[1], <String?>['greeting', 'Merhaba, İstanbul\n"Ruh Code"']);
    expect(rows[2], <String?>['nullable', null]);
    expect(text, isNot(contains('profiles.csv')));
  });

  test('rejects an unknown table instead of inventing a CSV schema', () async {
    final exporter = SingleTableCsvExporter(
      databaseExporter: LocalDatabaseBackupExporter(database: _FakeDatabase(const {})),
    );

    await expectLater(
      exporter.export('made_up.csv'),
      throwsA(isA<ArgumentError>()),
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
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) =>
      action(_FakeTransaction(tables));
}

final class _FakeTransaction implements LocalDatabaseTransaction {
  _FakeTransaction(this.tables);

  final Map<String, Map<String, Map<String, Object?>>> tables;

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(tables[table] ?? const {});

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async =>
      tables[table]?[id];

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    (tables[table] ??= <String, Map<String, Object?>>{})[id] = value;
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    tables[table]?.remove(id);
  }

  @override
  Future<void> clearTable(String table) async {
    tables[table]?.clear();
  }
}
