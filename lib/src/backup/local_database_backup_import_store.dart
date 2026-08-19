import 'dart:convert';
import 'dart:io';

import '../data/local/local_database.dart';
import 'backup_import_coordinator.dart';
import 'backup_schema.dart';

/// Production adapter between the validated CSV backup contract and the
/// offline LocalDatabase record store.
///
/// All destructive writes happen through [LocalDatabase.transaction]. Safety
/// snapshots are durable JSON files written before replace-mode mutation, so a
/// process failure cannot reduce the rollback source to an in-memory object.
final class LocalDatabaseBackupImportStore implements BackupImportStore {
  LocalDatabaseBackupImportStore({
    required this.database,
    required this.snapshotDirectory,
  });

  final LocalDatabase database;
  final Directory snapshotDirectory;

  @override
  Future<T> transaction<T>(
    Future<T> Function(BackupImportTransaction transaction) action,
  ) {
    return database.transaction<T>((tx) => action(_LocalBackupImportTransaction(tx)));
  }

  @override
  Future<Object> createSafetySnapshot() async {
    final tables = await database.transaction<Map<String, Object?>>((tx) async {
      final tableData = <String, Object?>{};
      for (final schema in BackupSchemaRegistry.tables) {
        final logicalTable = _logicalTableName(schema.fileName);
        final rows = await tx.readTable(logicalTable);
        tableData[logicalTable] = rows;
      }
      return <String, Object?>{
        'snapshotVersion': 1,
        'databaseSchemaVersion': database.schemaVersion,
        'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
        'tables': tableData,
      };
    });

    await snapshotDirectory.create(recursive: true);
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final finalFile = File('${snapshotDirectory.path}/pre_replace_$stamp.json');
    final temporaryFile = File('${finalFile.path}.tmp');
    await temporaryFile.writeAsString(jsonEncode(tables), flush: true);
    await temporaryFile.rename(finalFile.path);
    return _SafetySnapshotToken(finalFile.path);
  }

  @override
  Future<void> restoreSafetySnapshot(Object snapshotToken) async {
    if (snapshotToken is! _SafetySnapshotToken) {
      throw ArgumentError('Unsupported safety snapshot token.');
    }
    final file = File(snapshotToken.path);
    if (!await file.exists()) {
      throw StateError('Safety snapshot is missing: ${snapshotToken.path}');
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic> || decoded['snapshotVersion'] != 1) {
      throw const FormatException('Unsupported safety snapshot format.');
    }
    if (decoded['databaseSchemaVersion'] != database.schemaVersion) {
      throw StateError('Safety snapshot database schema does not match current database.');
    }
    final rawTables = decoded['tables'];
    if (rawTables is! Map) {
      throw const FormatException('Safety snapshot tables are invalid.');
    }

    await database.transaction<void>((tx) async {
      for (final schema in BackupSchemaRegistry.tables) {
        final table = _logicalTableName(schema.fileName);
        await tx.clearTable(table);
        final rawRows = rawTables[table];
        if (rawRows == null) continue;
        if (rawRows is! Map) {
          throw FormatException('Safety snapshot table is invalid: $table');
        }
        final ids = rawRows.keys.map((key) => key.toString()).toList()..sort();
        for (final id in ids) {
          final rawPayload = rawRows[id];
          if (rawPayload is! Map) {
            throw FormatException('Safety snapshot payload is invalid: $table/$id');
          }
          await tx.put(
            table: table,
            id: id,
            value: rawPayload.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
      }
    });
  }
}

final class _LocalBackupImportTransaction implements BackupImportTransaction {
  const _LocalBackupImportTransaction(this.tx);

  final LocalDatabaseTransaction tx;

  @override
  Future<void> replaceTable(String fileName, List<List<String?>> rows) async {
    final schema = BackupSchemaRegistry.table(fileName);
    final table = _logicalTableName(fileName);
    await tx.clearTable(table);
    await _putRows(schema, table, rows);
  }

  @override
  Future<void> upsertTable({
    required String fileName,
    required int primaryKeyIndex,
    required List<List<String?>> rows,
  }) async {
    final schema = BackupSchemaRegistry.table(fileName);
    final actualPrimaryKeyIndex = schema.columns.indexWhere(
      (column) => column.name == schema.primaryKey,
    );
    if (actualPrimaryKeyIndex != primaryKeyIndex) {
      throw StateError('Primary-key index mismatch for $fileName.');
    }
    await _putRows(schema, _logicalTableName(fileName), rows);
  }

  Future<void> _putRows(
    BackupTableSchema schema,
    String table,
    List<List<String?>> rows,
  ) async {
    final primaryKeyIndex = schema.columns.indexWhere(
      (column) => column.name == schema.primaryKey,
    );
    for (final row in rows) {
      if (row.length != schema.columns.length) {
        throw FormatException('Row width mismatch for ${schema.fileName}.');
      }
      final id = row[primaryKeyIndex];
      if (id == null || id.isEmpty) {
        throw FormatException('Missing primary key for ${schema.fileName}.');
      }
      await tx.put(
        table: table,
        id: id,
        value: _BackupPayloadMapper.toStoragePayload(schema, row),
      );
    }
  }
}

final class _BackupPayloadMapper {
  const _BackupPayloadMapper._();

  static Map<String, Object?> toStoragePayload(
    BackupTableSchema schema,
    List<String?> row,
  ) {
    final raw = <String, Object?>{};
    for (var i = 0; i < schema.columns.length; i++) {
      final column = schema.columns[i];
      raw[column.name] = _decodeValue(column, row[i]);
    }

    switch (schema.fileName) {
      case 'profiles.csv':
        return <String, Object?>{
          'id': raw['id'],
          'displayName': raw['display_name'],
          'birthData': <String, Object?>{
            'localDateIso': raw['birth_date'],
            'timeKnowledge': raw['birth_time_knowledge'],
            'localTime': raw['birth_time'],
            'location': <String, Object?>{
              'label': raw['location_label'],
              'countryCode': raw['country_code'],
              'latitude': raw['latitude'],
              'longitude': raw['longitude'],
              'ianaTimeZoneId': raw['iana_timezone_id'],
            },
          },
          'createdAtUtc': raw['created_at_utc'],
          'updatedAtUtc': raw['updated_at_utc'],
        };
      case 'clients.csv':
        return <String, Object?>{
          'id': raw['id'],
          'displayName': raw['display_name'],
          'birthData': raw['birth_data_json'],
          'tags': raw['tags_json'],
          'createdAtUtc': raw['created_at_utc'],
          'updatedAtUtc': raw['updated_at_utc'],
        };
      case 'calculation_manifests.csv':
        return <String, Object?>{
          'id': raw['id'],
          'engineId': raw['engine_id'],
          'engineVersion': raw['engine_version'],
          'algorithmVersion': raw['algorithm_version'],
          'dataVersion': raw['data_version'],
          'timezoneDatabaseVersion': raw['timezone_database_version'],
          'localDateTime': raw['local_datetime'],
          'utcDateTime': raw['utc_datetime'],
          'location': raw['location_json'],
          'validity': raw['validity'],
          'houseSystemId': raw['house_system_id'],
          'zodiacSystemId': raw['zodiac_system_id'],
          'ayanamshaId': raw['ayanamsha_id'],
          'nodeModeId': raw['node_mode_id'],
        };
      case 'journal_entries.csv':
        return _camelPayload(raw, overrides: const {'local_date': 'localDateIso'});
      case 'tarot_sessions.csv':
        return _camelPayload(raw, overrides: const {'card_ids_json': 'cardIds'});
      case 'professional_presets.csv':
        return _camelPayload(raw, overrides: const {'settings_json': 'settings'});
      default:
        return _camelPayload(raw);
    }
  }

  static Object? _decodeValue(BackupColumnSchema column, String? value) {
    if (value == null) return null;
    switch (column.type) {
      case BackupColumnType.integer:
        return int.parse(value);
      case BackupColumnType.decimal:
        return double.parse(value);
      case BackupColumnType.booleanValue:
        if (value == 'true') return true;
        if (value == 'false') return false;
        throw FormatException('Invalid boolean value for ${column.name}.');
      case BackupColumnType.jsonText:
        return jsonDecode(value);
      case BackupColumnType.text:
      case BackupColumnType.isoDate:
      case BackupColumnType.isoDateTimeUtc:
      case BackupColumnType.enumId:
        return value;
    }
  }

  static Map<String, Object?> _camelPayload(
    Map<String, Object?> raw, {
    Map<String, String> overrides = const {},
  }) {
    return raw.map((key, value) {
      final target = overrides[key] ?? _snakeToCamel(key);
      return MapEntry(target, value);
    });
  }

  static String _snakeToCamel(String value) {
    final parts = value.split('_');
    if (parts.length == 1) return value;
    final buffer = StringBuffer(parts.first);
    for (final part in parts.skip(1)) {
      if (part.isEmpty) continue;
      buffer
        ..write(part[0].toUpperCase())
        ..write(part.substring(1));
    }
    return buffer.toString();
  }
}

String _logicalTableName(String fileName) {
  if (!fileName.endsWith('.csv')) {
    throw ArgumentError('Backup table file name must end in .csv: $fileName');
  }
  return fileName.substring(0, fileName.length - 4);
}

final class _SafetySnapshotToken {
  const _SafetySnapshotToken(this.path);
  final String path;
}
