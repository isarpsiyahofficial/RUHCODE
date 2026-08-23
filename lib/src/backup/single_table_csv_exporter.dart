import 'dart:convert';
import 'dart:typed_data';

import 'backup_schema.dart';
import 'csv_codec.dart';
import 'local_database_backup_exporter.dart';

/// Human-readable/exportable CSV for exactly one canonical Ruh Code table.
///
/// This is intentionally separate from the full `.ruhcode.zip` backup path.
/// It satisfies the requirement that a user can export a specific table as a
/// standalone UTF-8 CSV without pretending that the CSV alone is a full
/// restorable application backup.
final class SingleTableCsvExport {
  const SingleTableCsvExport({
    required this.fileName,
    required this.bytes,
    required this.recordCount,
  });

  final String fileName;
  final Uint8List bytes;
  final int recordCount;
}

final class SingleTableCsvExporter {
  const SingleTableCsvExporter({
    required this.databaseExporter,
    this.codec = const RuhCsvDocumentCodec(),
  });

  final LocalDatabaseBackupExporter databaseExporter;
  final RuhCsvDocumentCodec codec;

  Future<SingleTableCsvExport> export(String fileName) async {
    final schema = _schema(fileName);
    final allRows = await databaseExporter.exportRows();
    final rows = allRows[fileName];
    if (rows == null) {
      throw StateError('Canonical backup exporter did not return $fileName.');
    }

    final document = <List<String?>>[
      <String?>[for (final column in schema.columns) column.name],
      ...rows,
    ];
    final encoded = utf8.encode(codec.encode(document));
    return SingleTableCsvExport(
      fileName: fileName,
      bytes: Uint8List.fromList(encoded),
      recordCount: rows.length,
    );
  }

  BackupTableSchema _schema(String fileName) {
    try {
      return BackupSchemaRegistry.table(fileName);
    } on StateError {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'Unknown canonical backup table.',
      );
    }
  }
}
