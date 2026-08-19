import 'dart:convert';

import 'backup_package_manifest.dart';
import 'backup_schema.dart';
import 'backup_schema_validator.dart';
import 'csv_codec.dart';

final class BackupPackageBytes {
  const BackupPackageBytes({required this.files});

  /// Logical package members keyed by portable file name.
  ///
  /// `manifest.json` is mandatory. CSV members are UTF-8 bytes. This class is
  /// intentionally archive-format agnostic so ZIP/file-system adapters can be
  /// added without changing backup validation semantics.
  final Map<String, List<int>> files;

  List<int> file(String name) {
    final value = files[name];
    if (value == null) throw FormatException('Backup package member is missing: $name');
    return value;
  }
}

final class BackupImportPreview {
  const BackupImportPreview({
    required this.manifest,
    required this.rowsByTable,
    required this.recordCounts,
    required this.issues,
  });

  final BackupPackageManifestV1 manifest;
  final Map<String, List<List<String?>>> rowsByTable;
  final Map<String, int> recordCounts;
  final List<BackupValidationIssue> issues;

  bool get valid => issues.isEmpty;
  int get totalRecords => recordCounts.values.fold(0, (sum, value) => sum + value);
}

final class BackupPackageWriter {
  const BackupPackageWriter({
    this.csvCodec = const RuhCsvDocumentCodec(),
    this.manifestBuilder = const BackupPackageManifestBuilder(),
  });

  final RuhCsvDocumentCodec csvCodec;
  final BackupPackageManifestBuilder manifestBuilder;

  BackupPackageBytes write({
    required Map<String, List<List<String?>>> rowsByTable,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) {
    final members = <String, List<int>>{};
    final entries = <BackupFileManifestEntry>[];

    for (final schema in BackupSchemaRegistry.tables) {
      final rows = rowsByTable[schema.fileName] ?? const <List<String?>>[];
      final header = schema.columns.map((column) => column.name).toList(growable: false);
      final document = csvCodec.encode(<List<String?>>[header, ...rows]);
      final bytes = utf8.encode(document);
      members[schema.fileName] = List<int>.unmodifiable(bytes);
      entries.add(manifestBuilder.fileEntry(
        fileName: schema.fileName,
        utf8Bytes: bytes,
        recordCount: rows.length,
      ));
    }

    final manifest = manifestBuilder.build(
      schemaVersion: BackupSchemaRegistry.schemaVersion,
      appVersion: appVersion,
      engineVersion: engineVersion,
      exportedAtUtc: exportedAtUtc,
      localeTag: localeTag,
      files: entries,
    );
    members['manifest.json'] = List<int>.unmodifiable(utf8.encode(manifest.toCanonicalJson()));

    final sortedKeys = members.keys.toList()..sort();
    return BackupPackageBytes(
      files: Map.unmodifiable(<String, List<int>>{
        for (final key in sortedKeys) key: members[key]!,
      }),
    );
  }
}

final class BackupPackageReader {
  const BackupPackageReader({
    this.csvCodec = const RuhCsvDocumentCodec(),
    this.manifestBuilder = const BackupPackageManifestBuilder(),
    this.schemaValidator = const BackupSchemaValidator(),
  });

  final RuhCsvDocumentCodec csvCodec;
  final BackupPackageManifestBuilder manifestBuilder;
  final BackupSchemaValidator schemaValidator;

  BackupImportPreview preview(BackupPackageBytes package) {
    final issues = <BackupValidationIssue>[];
    final manifestBytes = package.files['manifest.json'];
    if (manifestBytes == null) {
      throw const FormatException('Backup package manifest.json is missing.');
    }

    final manifest = BackupPackageManifestV1.parse(_decodeUtf8Strict(manifestBytes, 'manifest.json'));
    if (manifest.schemaVersion != BackupSchemaRegistry.schemaVersion) {
      throw FormatException(
        'Unsupported backup schema version ${manifest.schemaVersion}; expected ${BackupSchemaRegistry.schemaVersion}.',
      );
    }

    final expectedTableNames = BackupSchemaRegistry.tables.map((table) => table.fileName).toSet();
    final manifestNames = manifest.files.map((file) => file.fileName).toSet();
    final unexpected = manifestNames.difference(expectedTableNames);
    final missing = expectedTableNames.difference(manifestNames);
    if (unexpected.isNotEmpty) {
      throw FormatException('Backup manifest contains unexpected files: ${unexpected.toList()..sort()}.');
    }
    if (missing.isNotEmpty) {
      throw FormatException('Backup manifest is missing required files: ${missing.toList()..sort()}.');
    }

    final packagePayloadNames = package.files.keys.where((name) => name != 'manifest.json').toSet();
    final unmanifested = packagePayloadNames.difference(manifestNames);
    if (unmanifested.isNotEmpty) {
      throw FormatException('Backup package contains unmanifested payload files: ${unmanifested.toList()..sort()}.');
    }

    final rowsByTable = <String, List<List<String?>>>{};
    final recordCounts = <String, int>{};

    for (final entry in manifest.files) {
      final bytes = package.files[entry.fileName];
      if (bytes == null) {
        throw FormatException('Backup package member is missing: ${entry.fileName}.');
      }
      if (!manifestBuilder.verifyFile(entry, bytes)) {
        throw FormatException('Backup checksum/byte-length verification failed: ${entry.fileName}.');
      }

      final decoded = csvCodec.decode(_decodeUtf8Strict(bytes, entry.fileName));
      if (decoded.isEmpty) {
        throw FormatException('Backup CSV has no header: ${entry.fileName}.');
      }
      final rawHeader = decoded.first;
      if (rawHeader.any((value) => value == null)) {
        throw FormatException('Backup CSV header contains null: ${entry.fileName}.');
      }
      final header = rawHeader.cast<String>();
      final rows = decoded.skip(1).map((row) => List<String?>.unmodifiable(row)).toList(growable: false);
      if (rows.length != entry.recordCount) {
        throw FormatException(
          'Backup record-count mismatch for ${entry.fileName}: manifest=${entry.recordCount}, actual=${rows.length}.',
        );
      }

      final schema = BackupSchemaRegistry.table(entry.fileName);
      final tableResult = schemaValidator.validateTable(schema: schema, header: header, rows: rows);
      issues.addAll(tableResult.issues);
      rowsByTable[entry.fileName] = List<List<String?>>.unmodifiable(rows);
      recordCounts[entry.fileName] = rows.length;
    }

    issues.addAll(schemaValidator.validateForeignKeys(rowsByTable: rowsByTable));

    return BackupImportPreview(
      manifest: manifest,
      rowsByTable: Map.unmodifiable(rowsByTable),
      recordCounts: Map.unmodifiable(recordCounts),
      issues: List.unmodifiable(issues),
    );
  }

  String _decodeUtf8Strict(List<int> bytes, String fileName) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      throw FormatException('Backup member is not valid UTF-8: $fileName.');
    }
  }
}
