import 'dart:convert';

import 'backup_package_codec.dart';
import 'backup_schema.dart';
import 'csv_codec.dart';

/// Explicit migration boundary for the pre-schema Ruh Code backup prototype.
///
/// Legacy v0 had no manifest and only exported `profiles.csv` and optionally
/// `settings.csv`. It also had no `birth_time_knowledge` column. This migrator
/// never mutates a current package in-place: it parses the legacy bytes,
/// validates the known v0 headers, infers only the one documented missing
/// state, and emits a complete current-schema package through
/// [BackupPackageWriter]. Every table introduced after v0 is represented as an
/// empty current-schema CSV rather than fabricated data.
final class LegacyBackupV0Migrator {
  const LegacyBackupV0Migrator({
    this.csvCodec = const RuhCsvDocumentCodec(),
    this.writer = const BackupPackageWriter(),
  });

  static const List<String> legacyProfileHeader = <String>[
    'id',
    'display_name',
    'birth_date',
    'birth_time',
    'location_label',
    'country_code',
    'latitude',
    'longitude',
    'iana_timezone_id',
    'created_at_utc',
    'updated_at_utc',
  ];

  static const List<String> legacySettingsHeader = <String>['key', 'value'];

  final RuhCsvDocumentCodec csvCodec;
  final BackupPackageWriter writer;

  BackupPackageBytes migrate({
    required Map<String, List<int>> legacyFiles,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) {
    final allowed = <String>{'profiles.csv', 'settings.csv'};
    final unexpected = legacyFiles.keys.toSet().difference(allowed);
    if (unexpected.isNotEmpty) {
      throw FormatException('Legacy v0 backup contains unexpected files: ${unexpected.toList()..sort()}.');
    }
    final profileBytes = legacyFiles['profiles.csv'];
    if (profileBytes == null) {
      throw const FormatException('Legacy v0 backup profiles.csv is missing.');
    }

    final rowsByTable = <String, List<List<String?>>>{
      for (final schema in BackupSchemaRegistry.tables) schema.fileName: <List<String?>>[],
    };
    rowsByTable['profiles.csv'] = _migrateProfiles(profileBytes);

    final settingsBytes = legacyFiles['settings.csv'];
    if (settingsBytes != null) {
      rowsByTable['settings.csv'] = _readLegacyRows(
        fileName: 'settings.csv',
        bytes: settingsBytes,
        expectedHeader: legacySettingsHeader,
      );
    }

    return writer.write(
      rowsByTable: rowsByTable,
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
  }

  List<List<String?>> _migrateProfiles(List<int> bytes) {
    final legacyRows = _readLegacyRows(
      fileName: 'profiles.csv',
      bytes: bytes,
      expectedHeader: legacyProfileHeader,
    );
    final current = BackupSchemaRegistry.table('profiles.csv');
    final index = <String, int>{
      for (var i = 0; i < legacyProfileHeader.length; i++) legacyProfileHeader[i]: i,
    };

    return legacyRows.map((legacy) {
      final birthTime = legacy[index['birth_time']!];
      final values = <String, String?>{
        for (final name in legacyProfileHeader) name: legacy[index[name]!],
        'birth_time_knowledge': birthTime == null || birthTime.isEmpty ? 'unknown' : 'exact',
      };
      return current.columns.map((column) => values[column.name]).toList(growable: false);
    }).toList(growable: false);
  }

  List<List<String?>> _readLegacyRows({
    required String fileName,
    required List<int> bytes,
    required List<String> expectedHeader,
  }) {
    late final String source;
    try {
      source = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw FormatException('Legacy v0 member is not valid UTF-8: $fileName.');
    }
    final document = csvCodec.decode(source);
    if (document.isEmpty) {
      throw FormatException('Legacy v0 CSV has no header: $fileName.');
    }
    final rawHeader = document.first;
    if (rawHeader.any((value) => value == null)) {
      throw FormatException('Legacy v0 CSV header contains null: $fileName.');
    }
    final header = rawHeader.cast<String>();
    if (!_sameStrings(header, expectedHeader)) {
      throw FormatException('Unsupported legacy v0 header for $fileName: $header.');
    }
    final rows = document.skip(1).map((row) {
      if (row.length != expectedHeader.length) {
        throw FormatException('Legacy v0 row width mismatch for $fileName.');
      }
      return List<String?>.unmodifiable(row);
    }).toList(growable: false);
    return rows;
  }

  bool _sameStrings(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
