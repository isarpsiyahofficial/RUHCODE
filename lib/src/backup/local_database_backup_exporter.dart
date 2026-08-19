import 'dart:convert';

import '../data/local/local_database.dart';
import 'backup_package_codec.dart';
import 'backup_schema.dart';

/// Reads the offline runtime database in one transaction and maps every
/// registered logical table back to the canonical CSV backup schema.
///
/// Import and export intentionally share [BackupSchemaRegistry], so locale,
/// UI labels and translated enum text can never become machine backup keys.
final class LocalDatabaseBackupExporter {
  const LocalDatabaseBackupExporter({required this.database});

  final LocalDatabase database;

  Future<Map<String, List<List<String?>>>> exportRows() {
    return database.transaction<Map<String, List<List<String?>>>>((tx) async {
      final result = <String, List<List<String?>>>{};
      for (final schema in BackupSchemaRegistry.tables) {
        final table = _logicalTableName(schema.fileName);
        final stored = await tx.readTable(table);
        final ids = stored.keys.toList()..sort();
        final rows = <List<String?>>[];
        for (final id in ids) {
          final payload = stored[id]!;
          rows.add(_StoragePayloadExporter.toCsvRow(schema, id, payload));
        }
        result[schema.fileName] = List<List<String?>>.unmodifiable(rows);
      }
      return Map.unmodifiable(result);
    });
  }

  Future<BackupPackageBytes> exportPackage({
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
    BackupPackageWriter writer = const BackupPackageWriter(),
  }) async {
    return writer.write(
      rowsByTable: await exportRows(),
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
  }
}

final class _StoragePayloadExporter {
  const _StoragePayloadExporter._();

  static List<String?> toCsvRow(
    BackupTableSchema schema,
    String recordId,
    Map<String, Object?> payload,
  ) {
    final canonical = _canonicalColumnValues(schema, payload);
    final primaryValue = canonical[schema.primaryKey];
    if (primaryValue == null || primaryValue.toString().isEmpty) {
      canonical[schema.primaryKey] = recordId;
    } else if (primaryValue.toString() != recordId) {
      throw StateError(
        'Stored record id mismatch for ${schema.fileName}: key=$recordId payload=$primaryValue.',
      );
    }

    return List<String?>.unmodifiable(
      schema.columns.map((column) {
        final value = canonical[column.name];
        if (value == null) {
          if (!column.nullable) {
            throw FormatException(
              'Required backup field is missing: ${schema.fileName}.${column.name}.',
            );
          }
          return null;
        }
        return _encodeValue(column, value);
      }),
    );
  }

  static Map<String, Object?> _canonicalColumnValues(
    BackupTableSchema schema,
    Map<String, Object?> payload,
  ) {
    switch (schema.fileName) {
      case 'profiles.csv':
        final birthData = _map(payload['birthData'], 'profiles.birthData');
        final location = _map(birthData['location'], 'profiles.birthData.location');
        return <String, Object?>{
          'id': payload['id'],
          'display_name': payload['displayName'],
          'birth_date': birthData['localDateIso'],
          'birth_time_knowledge': birthData['timeKnowledge'],
          'birth_time': birthData['localTime'],
          'location_label': location['label'],
          'country_code': location['countryCode'],
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'iana_timezone_id': location['ianaTimeZoneId'],
          'created_at_utc': payload['createdAtUtc'],
          'updated_at_utc': payload['updatedAtUtc'],
        };
      case 'clients.csv':
        return <String, Object?>{
          'id': payload['id'],
          'display_name': payload['displayName'],
          'birth_data_json': payload['birthData'],
          'tags_json': payload['tags'],
          'created_at_utc': payload['createdAtUtc'],
          'updated_at_utc': payload['updatedAtUtc'],
        };
      case 'calculation_manifests.csv':
        return <String, Object?>{
          'id': payload['id'],
          'engine_id': payload['engineId'],
          'engine_version': payload['engineVersion'],
          'algorithm_version': payload['algorithmVersion'],
          'data_version': payload['dataVersion'],
          'timezone_database_version': payload['timezoneDatabaseVersion'],
          'local_datetime': payload['localDateTime'],
          'utc_datetime': payload['utcDateTime'],
          'location_json': payload['location'],
          'validity': payload['validity'],
          'house_system_id': payload['houseSystemId'],
          'zodiac_system_id': payload['zodiacSystemId'],
          'ayanamsha_id': payload['ayanamshaId'],
          'node_mode_id': payload['nodeModeId'],
        };
      case 'journal_entries.csv':
        return _snakePayload(
          schema,
          payload,
          overrides: const <String, String>{'local_date': 'localDateIso'},
        );
      case 'tarot_sessions.csv':
        return _snakePayload(
          schema,
          payload,
          overrides: const <String, String>{'card_ids_json': 'cardIds'},
        );
      case 'professional_presets.csv':
        return _snakePayload(
          schema,
          payload,
          overrides: const <String, String>{'settings_json': 'settings'},
        );
      default:
        return _snakePayload(schema, payload);
    }
  }

  static Map<String, Object?> _snakePayload(
    BackupTableSchema schema,
    Map<String, Object?> payload, {
    Map<String, String> overrides = const <String, String>{},
  }) {
    return <String, Object?>{
      for (final column in schema.columns)
        column.name: payload[overrides[column.name] ?? _snakeToCamel(column.name)],
    };
  }

  static String _encodeValue(BackupColumnSchema column, Object value) {
    switch (column.type) {
      case BackupColumnType.integer:
        if (value is! int) {
          throw FormatException('Expected integer for ${column.name}.');
        }
        return value.toString();
      case BackupColumnType.decimal:
        if (value is! num || !value.toDouble().isFinite) {
          throw FormatException('Expected finite decimal for ${column.name}.');
        }
        return value.toString();
      case BackupColumnType.booleanValue:
        if (value is! bool) {
          throw FormatException('Expected boolean for ${column.name}.');
        }
        return value ? 'true' : 'false';
      case BackupColumnType.jsonText:
        return jsonEncode(_canonicalJsonValue(value));
      case BackupColumnType.enumId:
        final text = value.toString();
        if (!column.enumValues.contains(text)) {
          throw FormatException('Invalid enum id for ${column.name}: $text.');
        }
        return text;
      case BackupColumnType.isoDate:
      case BackupColumnType.isoDateTimeUtc:
      case BackupColumnType.text:
        return value.toString();
    }
  }

  static Object? _canonicalJsonValue(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: _canonicalJsonValue(value[key]),
      };
    }
    if (value is Iterable) {
      return value.map(_canonicalJsonValue).toList(growable: false);
    }
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    throw FormatException('Unsupported JSON backup value type: ${value.runtimeType}.');
  }

  static Map<String, Object?> _map(Object? value, String path) {
    if (value is! Map) {
      throw FormatException('Expected map at $path.');
    }
    return value.map((key, value) => MapEntry(key.toString(), value));
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
