/// Strict UTF-8 CSV value/document codec for Ruh Code portable backups.
///
/// The CSV document layer follows RFC-4180 style quoting rules while the value
/// layer preserves the distinction between null and an empty string.
///
/// Value convention:
/// - `\\N` represents null.
/// - A literal string beginning with `\\` is escaped with one extra leading
///   backslash before CSV quoting. Therefore the literal text `\\N` is encoded
///   as `\\\\N` and round-trips without being mistaken for null.
/// - Numbers must be serialized by callers using locale-independent machine
///   representations (for example `double.toString()`).
final class RuhCsvValueCodec {
  const RuhCsvValueCodec();

  static const String nullSentinel = r'\N';

  String encodeNullable(String? value) {
    if (value == null) return nullSentinel;
    if (value.startsWith(r'\')) return r'\' + value;
    return value;
  }

  String? decodeNullable(String encoded) {
    if (encoded == nullSentinel) return null;
    if (encoded.startsWith(r'\\')) return encoded.substring(1);
    return encoded;
  }
}

final class RuhCsvDocumentCodec {
  const RuhCsvDocumentCodec({this.valueCodec = const RuhCsvValueCodec()});

  final RuhCsvValueCodec valueCodec;

  /// Encodes rows with CRLF separators and no locale-sensitive formatting.
  String encode(List<List<String?>> rows) {
    return rows.map(_encodeRow).join('\r\n');
  }

  String _encodeRow(List<String?> row) {
    return row.map((value) => _quote(valueCodec.encodeNullable(value))).join(',');
  }

  String _quote(String value) {
    final needsQuotes = value.contains(',') ||
        value.contains('"') ||
        value.contains('\r') ||
        value.contains('\n');
    if (!needsQuotes) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  /// Decodes a CSV document while preserving quoted commas, quotes and newlines.
  ///
  /// A final trailing record separator does not create a spurious empty row.
  List<List<String?>> decode(String input) {
    if (input.isEmpty) return const <List<String?>>[];

    final rows = <List<String?>>[];
    var row = <String?>[];
    final field = StringBuffer();
    var inQuotes = false;
    var quotedField = false;

    void finishField() {
      row.add(valueCodec.decodeNullable(field.toString()));
      field.clear();
      quotedField = false;
    }

    void finishRow() {
      finishField();
      rows.add(row);
      row = <String?>[];
    }

    var i = 0;
    while (i < input.length) {
      final ch = input[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            field.write('"');
            i += 2;
            continue;
          }
          inQuotes = false;
          i++;
          continue;
        }
        field.write(ch);
        i++;
        continue;
      }

      if (ch == '"') {
        if (field.isNotEmpty || quotedField) {
          throw const FormatException('Unexpected quote inside unquoted CSV field.');
        }
        inQuotes = true;
        quotedField = true;
        i++;
        continue;
      }
      if (ch == ',') {
        finishField();
        i++;
        continue;
      }
      if (ch == '\r' || ch == '\n') {
        if (ch == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        finishRow();
        i++;
        continue;
      }
      field.write(ch);
      i++;
    }

    if (inQuotes) {
      throw const FormatException('Unterminated quoted CSV field.');
    }

    final endedWithRecordSeparator = input.endsWith('\n') || input.endsWith('\r');
    if (!endedWithRecordSeparator || field.isNotEmpty || row.isNotEmpty) {
      finishRow();
    }
    return rows;
  }
}
