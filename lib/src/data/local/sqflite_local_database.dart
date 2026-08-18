import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'local_database.dart';

final class SqfliteLocalDatabase implements LocalDatabase {
  SqfliteLocalDatabase({
    DatabaseFactory? databaseFactory,
    String? databasePath,
    this.targetSchemaVersion = 1,
  })  : _databaseFactory = databaseFactory ?? databaseFactorySqflitePlugin,
        _databasePath = databasePath;

  final DatabaseFactory _databaseFactory;
  final String? _databasePath;
  final int targetSchemaVersion;
  Database? _database;

  Database get _db {
    final db = _database;
    if (db == null) {
      throw StateError('Database is not open.');
    }
    return db;
  }

  @override
  int get schemaVersion => targetSchemaVersion;

  @override
  Future<void> open() async {
    if (_database != null) return;
    final resolvedPath = _databasePath ??
        p.join(await _databaseFactory.getDatabasesPath(), 'ruh_code.db');
    _database = await _databaseFactory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: targetSchemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await _createSchemaV1(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _migrateDatabase(db, oldVersion, newVersion);
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  @override
  Future<IntegrityCheckResult> integrityCheck() async {
    final rows = await _db.rawQuery('PRAGMA integrity_check');
    final details = rows
        .map((row) => row.values.isEmpty ? '' : '${row.values.first}')
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final ok = details.length == 1 && details.single.toLowerCase() == 'ok';
    return IntegrityCheckResult(ok: ok, details: details);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(LocalDatabaseTransaction tx) action,
  ) {
    return _db.transaction((txn) async {
      return action(_SqfliteTransaction(txn));
    });
  }

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {
    if (fromVersion < 1 ||
        toVersion < fromVersion ||
        toVersion > targetSchemaVersion) {
      throw ArgumentError('Unsupported migration $fromVersion -> $toVersion');
    }
    if (fromVersion == toVersion) return;
    await _db.transaction(
      (txn) => _migrateDatabase(txn, fromVersion, toVersion),
    );
  }

  static Future<void> _createSchemaV1(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS app_meta (
  key TEXT PRIMARY KEY NOT NULL,
  value TEXT NOT NULL
)
''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS records (
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  PRIMARY KEY (table_name, record_id)
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_records_table_name ON records(table_name)',
    );
    await db.insert(
      'app_meta',
      {'key': 'schema_version', 'value': '1'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _migrateDatabase(
    DatabaseExecutor db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 1) {
      await _createSchemaV1(db);
    }
    if (newVersion > 1) {
      throw StateError('No migration registered beyond schema v1.');
    }
  }
}

final class _SqfliteTransaction implements LocalDatabaseTransaction {
  const _SqfliteTransaction(this._txn);

  final Transaction _txn;

  @override
  Future<void> put({
    required String table,
    required String id,
    required Map<String, Object?> value,
  }) async {
    if (table.trim().isEmpty || id.trim().isEmpty) {
      throw ArgumentError('table and id must not be empty');
    }
    await _txn.insert(
      'records',
      {
        'table_name': table,
        'record_id': id,
        'payload_json': jsonEncode(value),
        'updated_at_utc': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, Object?>?> get({
    required String table,
    required String id,
  }) async {
    final rows = await _txn.query(
      'records',
      columns: const ['payload_json'],
      where: 'table_name = ? AND record_id = ?',
      whereArgs: [table, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.single['payload_json']! as String);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stored payload is not a JSON object.');
    }
    return Map<String, Object?>.from(decoded);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    await _txn.delete(
      'records',
      where: 'table_name = ? AND record_id = ?',
      whereArgs: [table, id],
    );
  }
}
