enum BackupColumnType { text, integer, decimal, booleanValue, isoDate, isoDateTimeUtc, enumId, jsonText }

final class BackupForeignKey {
  const BackupForeignKey({required this.table, required this.column});
  final String table;
  final String column;
}

final class BackupColumnSchema {
  const BackupColumnSchema({
    required this.name,
    required this.type,
    this.nullable = false,
    this.enumValues = const <String>{},
    this.foreignKey,
  });

  final String name;
  final BackupColumnType type;
  final bool nullable;
  final Set<String> enumValues;
  final BackupForeignKey? foreignKey;
}

final class BackupTableSchema {
  const BackupTableSchema({
    required this.fileName,
    required this.primaryKey,
    required this.columns,
  });

  final String fileName;
  final String primaryKey;
  final List<BackupColumnSchema> columns;

  BackupColumnSchema column(String name) => columns.singleWhere((column) => column.name == name);
}

final class BackupSchemaRegistry {
  const BackupSchemaRegistry._();

  static const int schemaVersion = 1;

  static const List<BackupTableSchema> tables = <BackupTableSchema>[
    BackupTableSchema(fileName: 'profiles.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'display_name', type: BackupColumnType.text),
      BackupColumnSchema(name: 'birth_date', type: BackupColumnType.isoDate),
      BackupColumnSchema(name: 'birth_time_knowledge', type: BackupColumnType.enumId, enumValues: {'exact', 'approximate', 'unknown'}),
      BackupColumnSchema(name: 'birth_time', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'location_label', type: BackupColumnType.text),
      BackupColumnSchema(name: 'country_code', type: BackupColumnType.text),
      BackupColumnSchema(name: 'latitude', type: BackupColumnType.decimal),
      BackupColumnSchema(name: 'longitude', type: BackupColumnType.decimal),
      BackupColumnSchema(name: 'iana_timezone_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'clients.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'display_name', type: BackupColumnType.text),
      BackupColumnSchema(name: 'birth_data_json', type: BackupColumnType.jsonText, nullable: true),
      BackupColumnSchema(name: 'tags_json', type: BackupColumnType.jsonText),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'consultations.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'client_id', type: BackupColumnType.text, foreignKey: BackupForeignKey(table: 'clients.csv', column: 'id')),
      BackupColumnSchema(name: 'started_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'ended_at_utc', type: BackupColumnType.isoDateTimeUtc, nullable: true),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'notes.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'owner_entity_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'text', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'calculation_manifests.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'engine_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'engine_version', type: BackupColumnType.text),
      BackupColumnSchema(name: 'algorithm_version', type: BackupColumnType.text),
      BackupColumnSchema(name: 'data_version', type: BackupColumnType.text),
      BackupColumnSchema(name: 'timezone_database_version', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'local_datetime', type: BackupColumnType.text),
      BackupColumnSchema(name: 'utc_datetime', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'location_json', type: BackupColumnType.jsonText),
      BackupColumnSchema(name: 'validity', type: BackupColumnType.enumId, enumValues: {'valid', 'partial', 'unavailable', 'error'}),
      BackupColumnSchema(name: 'house_system_id', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'zodiac_system_id', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'ayanamsha_id', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'node_mode_id', type: BackupColumnType.text, nullable: true),
    ]),
    BackupTableSchema(fileName: 'calculations.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'manifest_id', type: BackupColumnType.text, foreignKey: BackupForeignKey(table: 'calculation_manifests.csv', column: 'id')),
      BackupColumnSchema(name: 'owner_entity_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'calculation_type', type: BackupColumnType.text),
      BackupColumnSchema(name: 'payload_json', type: BackupColumnType.jsonText),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'journal_entries.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'profile_id', type: BackupColumnType.text, foreignKey: BackupForeignKey(table: 'profiles.csv', column: 'id')),
      BackupColumnSchema(name: 'local_date', type: BackupColumnType.isoDate),
      BackupColumnSchema(name: 'text', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'goals.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'profile_id', type: BackupColumnType.text, foreignKey: BackupForeignKey(table: 'profiles.csv', column: 'id')),
      BackupColumnSchema(name: 'title', type: BackupColumnType.text),
      BackupColumnSchema(name: 'completed', type: BackupColumnType.booleanValue),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'habits.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'profile_id', type: BackupColumnType.text, foreignKey: BackupForeignKey(table: 'profiles.csv', column: 'id')),
      BackupColumnSchema(name: 'title', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'tarot_sessions.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'client_id', type: BackupColumnType.text, nullable: true, foreignKey: BackupForeignKey(table: 'clients.csv', column: 'id')),
      BackupColumnSchema(name: 'spread_id', type: BackupColumnType.text, nullable: true),
      BackupColumnSchema(name: 'card_ids_json', type: BackupColumnType.jsonText),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'professional_presets.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'name', type: BackupColumnType.text),
      BackupColumnSchema(name: 'system_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'settings_json', type: BackupColumnType.jsonText),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'interpretation_templates.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'system_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'rule_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'locale_tag', type: BackupColumnType.text),
      BackupColumnSchema(name: 'text', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
      BackupColumnSchema(name: 'updated_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
    BackupTableSchema(fileName: 'settings.csv', primaryKey: 'key', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'key', type: BackupColumnType.text),
      BackupColumnSchema(name: 'value', type: BackupColumnType.text, nullable: true),
    ]),
    BackupTableSchema(fileName: 'favorites.csv', primaryKey: 'id', columns: <BackupColumnSchema>[
      BackupColumnSchema(name: 'id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'owner_entity_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'target_type', type: BackupColumnType.text),
      BackupColumnSchema(name: 'target_id', type: BackupColumnType.text),
      BackupColumnSchema(name: 'created_at_utc', type: BackupColumnType.isoDateTimeUtc),
    ]),
  ];

  static BackupTableSchema table(String fileName) => tables.singleWhere((table) => table.fileName == fileName);
}
