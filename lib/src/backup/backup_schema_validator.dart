import 'dart:convert';

import 'backup_schema.dart';

final class BackupValidationIssue {
  const BackupValidationIssue({required this.table, required this.message, this.rowIndex});
  final String table;
  final int? rowIndex;
  final String message;
}

final class BackupTableValidationResult {
  const BackupTableValidationResult({required this.valid, required this.issues});
  final bool valid;
  final List<BackupValidationIssue> issues;
}

final class BackupSchemaValidator {
  const BackupSchemaValidator();

  BackupTableValidationResult validateTable({
    required BackupTableSchema schema,
    required List<String> header,
    required List<List<String?>> rows,
  }) {
    final issues = <BackupValidationIssue>[];
    final expected = schema.columns.map((column) => column.name).toList(growable: false);
    if (!_sameList(header, expected)) {
      issues.add(BackupValidationIssue(
        table: schema.fileName,
        message: 'Header mismatch. Expected ${expected.join(',')}, got ${header.join(',')}.',
      ));
      return BackupTableValidationResult(valid: false, issues: issues);
    }

    final primaryKeyIndex = expected.indexOf(schema.primaryKey);
    if (primaryKeyIndex < 0) {
      issues.add(BackupValidationIssue(table: schema.fileName, message: 'Primary key column ${schema.primaryKey} is missing.'));
      return BackupTableValidationResult(valid: false, issues: issues);
    }

    final primaryKeys = <String>{};
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.length != schema.columns.length) {
        issues.add(BackupValidationIssue(
          table: schema.fileName,
          rowIndex: rowIndex,
          message: 'Column count mismatch: expected ${schema.columns.length}, got ${row.length}.',
        ));
        continue;
      }

      for (var columnIndex = 0; columnIndex < schema.columns.length; columnIndex++) {
        final column = schema.columns[columnIndex];
        final value = row[columnIndex];
        final error = _validateValue(column, value);
        if (error != null) {
          issues.add(BackupValidationIssue(table: schema.fileName, rowIndex: rowIndex, message: '${column.name}: $error'));
        }
      }

      final primaryKey = row[primaryKeyIndex];
      if (primaryKey == null || primaryKey.isEmpty) {
        issues.add(BackupValidationIssue(table: schema.fileName, rowIndex: rowIndex, message: 'Primary key is null or empty.'));
      } else if (!primaryKeys.add(primaryKey)) {
        issues.add(BackupValidationIssue(table: schema.fileName, rowIndex: rowIndex, message: 'Duplicate primary key: $primaryKey.'));
      }
    }

    return BackupTableValidationResult(valid: issues.isEmpty, issues: List.unmodifiable(issues));
  }

  List<BackupValidationIssue> validateForeignKeys({
    required Map<String, List<List<String?>>> rowsByTable,
  }) {
    final issues = <BackupValidationIssue>[];
    final keySets = <String, Set<String>>{};

    for (final schema in BackupSchemaRegistry.tables) {
      final rows = rowsByTable[schema.fileName] ?? const <List<String?>>[];
      final pkIndex = schema.columns.indexWhere((column) => column.name == schema.primaryKey);
      if (pkIndex < 0) continue;
      keySets[schema.fileName] = rows
          .where((row) => row.length > pkIndex && row[pkIndex] != null && row[pkIndex]!.isNotEmpty)
          .map((row) => row[pkIndex]!)
          .toSet();
    }

    for (final schema in BackupSchemaRegistry.tables) {
      final rows = rowsByTable[schema.fileName] ?? const <List<String?>>[];
      for (var columnIndex = 0; columnIndex < schema.columns.length; columnIndex++) {
        final column = schema.columns[columnIndex];
        final fk = column.foreignKey;
        if (fk == null) continue;
        final targetKeys = keySets[fk.table] ?? const <String>{};
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
          final row = rows[rowIndex];
          if (row.length <= columnIndex) continue;
          final value = row[columnIndex];
          if (value == null || value.isEmpty) {
            if (!column.nullable) {
              issues.add(BackupValidationIssue(table: schema.fileName, rowIndex: rowIndex, message: '${column.name}: required foreign key is missing.'));
            }
            continue;
          }
          if (!targetKeys.contains(value)) {
            issues.add(BackupValidationIssue(
              table: schema.fileName,
              rowIndex: rowIndex,
              message: '${column.name}: unresolved foreign key $value -> ${fk.table}.${fk.column}.',
            ));
          }
        }
      }
    }

    return List.unmodifiable(issues);
  }

  String? _validateValue(BackupColumnSchema column, String? value) {
    if (value == null) return column.nullable ? null : 'value is required';
    if (value.isEmpty && !column.nullable && column.type != BackupColumnType.text) {
      return 'empty value is not allowed';
    }

    switch (column.type) {
      case BackupColumnType.text:
        return null;
      case BackupColumnType.integer:
        return int.tryParse(value) == null ? 'invalid integer' : null;
      case BackupColumnType.decimal:
        final parsed = double.tryParse(value);
        return parsed == null || !parsed.isFinite ? 'invalid decimal' : null;
      case BackupColumnType.booleanValue:
        return value == 'true' || value == 'false' ? null : 'boolean must be true or false';
      case BackupColumnType.isoDate:
        return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) && DateTime.tryParse(value) != null ? null : 'invalid ISO date';
      case BackupColumnType.isoDateTimeUtc:
        final parsed = DateTime.tryParse(value);
        return parsed != null && parsed.isUtc && value.endsWith('Z') ? null : 'datetime must be UTC ISO-8601 ending in Z';
      case BackupColumnType.enumId:
        return column.enumValues.contains(value) ? null : 'unknown enum id';
      case BackupColumnType.jsonText:
        try {
          jsonDecode(value);
          return null;
        } on FormatException {
          return 'invalid JSON';
        }
    }
  }

  bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
