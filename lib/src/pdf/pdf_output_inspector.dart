import 'dart:convert';
import 'dart:typed_data';

/// Lightweight structural inspection for locally generated PDF bytes.
///
/// This is intentionally not a replacement for a full PDF parser. It catches
/// truncated/non-PDF output and broken cross-reference trailers before the
/// application presents or shares a file.
final class PdfOutputInspection {
  const PdfOutputInspection({
    required this.byteLength,
    required this.hasHeader,
    required this.hasEofMarker,
    required this.hasCatalog,
    required this.hasPagesTree,
    required this.pageObjectCount,
    required this.declaredPageCount,
    required this.hasStartXref,
    required this.startXrefOffset,
    required this.startXrefTargetRecognized,
  });

  final int byteLength;
  final bool hasHeader;
  final bool hasEofMarker;
  final bool hasCatalog;
  final bool hasPagesTree;
  final int pageObjectCount;
  final int? declaredPageCount;
  final bool hasStartXref;
  final int? startXrefOffset;
  final bool startXrefTargetRecognized;

  bool get pageTreeCountConsistent =>
      declaredPageCount != null && declaredPageCount == pageObjectCount;

  bool get structurallyUsable =>
      byteLength >= 64 &&
      hasHeader &&
      hasEofMarker &&
      hasCatalog &&
      hasPagesTree &&
      pageObjectCount > 0 &&
      pageTreeCountConsistent &&
      hasStartXref &&
      startXrefOffset != null &&
      startXrefTargetRecognized;
}

final class PdfOutputInspector {
  const PdfOutputInspector();

  PdfOutputInspection inspect(Uint8List bytes) {
    final hasHeader = bytes.length >= 5 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46 &&
        bytes[4] == 0x2D;

    final text = latin1.decode(bytes, allowInvalid: true);
    final pageObjectCount = RegExp(r'/Type\s*/Page(?!s)\b').allMatches(text).length;
    final pagesTreeMatch = RegExp(
      r'/Type\s*/Pages\b(?:(?!endobj).)*?/Count\s+(\d+)',
      dotAll: true,
    ).firstMatch(text);
    final declaredPageCount = pagesTreeMatch == null
        ? null
        : int.tryParse(pagesTreeMatch.group(1)!);

    final eofMatch = RegExp(r'%%EOF\s*$').firstMatch(text);
    final startXrefMatch = RegExp(
      r'startxref\s+(\d+)\s+%%EOF\s*$',
    ).firstMatch(text);
    final startXrefOffset = startXrefMatch == null
        ? null
        : int.tryParse(startXrefMatch.group(1)!);
    final startXrefTargetRecognized = startXrefOffset != null &&
        _pointsToRecognizedXref(text, startXrefOffset);

    return PdfOutputInspection(
      byteLength: bytes.length,
      hasHeader: hasHeader,
      hasEofMarker: eofMatch != null,
      hasCatalog: RegExp(r'/Type\s*/Catalog\b').hasMatch(text),
      hasPagesTree: RegExp(r'/Type\s*/Pages\b').hasMatch(text),
      pageObjectCount: pageObjectCount,
      declaredPageCount: declaredPageCount,
      hasStartXref: startXrefMatch != null,
      startXrefOffset: startXrefOffset,
      startXrefTargetRecognized: startXrefTargetRecognized,
    );
  }

  bool _pointsToRecognizedXref(String text, int offset) {
    if (offset < 0 || offset >= text.length) {
      return false;
    }
    final tail = text.substring(offset);
    if (RegExp(r'^xref\b').hasMatch(tail)) {
      return true;
    }
    return RegExp(
      r'^\d+\s+\d+\s+obj\b(?:(?!endobj).)*?/Type\s*/XRef\b',
      dotAll: true,
    ).hasMatch(tail);
  }

  PdfOutputInspection requireUsable(Uint8List bytes) {
    final inspection = inspect(bytes);
    if (!inspection.structurallyUsable) {
      throw StateError(
        'Generated PDF failed structural inspection: '
        'bytes=${inspection.byteLength}, header=${inspection.hasHeader}, '
        'eof=${inspection.hasEofMarker}, catalog=${inspection.hasCatalog}, '
        'pagesTree=${inspection.hasPagesTree}, pages=${inspection.pageObjectCount}, '
        'declaredPages=${inspection.declaredPageCount}, '
        'pageCountConsistent=${inspection.pageTreeCountConsistent}, '
        'startXref=${inspection.hasStartXref}, '
        'startXrefOffset=${inspection.startXrefOffset}, '
        'xrefTarget=${inspection.startXrefTargetRecognized}.',
      );
    }
    return inspection;
  }

  /// Enforces an explicit page-count contract after structural validation.
  ///
  /// This is used by 5/25/50+ report regression fixtures so a renderer cannot
  /// silently drop pages while still returning superficially valid PDF bytes.
  PdfOutputInspection requirePageCount(
    Uint8List bytes, {
    int? exact,
    int? minimum,
    int? maximum,
  }) {
    if (exact != null && (minimum != null || maximum != null)) {
      throw ArgumentError('exact page count cannot be combined with min/max.');
    }
    if (exact != null && exact <= 0) {
      throw ArgumentError.value(exact, 'exact', 'Page count must be positive.');
    }
    if (minimum != null && minimum <= 0) {
      throw ArgumentError.value(minimum, 'minimum', 'Minimum must be positive.');
    }
    if (maximum != null && maximum <= 0) {
      throw ArgumentError.value(maximum, 'maximum', 'Maximum must be positive.');
    }
    if (minimum != null && maximum != null && minimum > maximum) {
      throw ArgumentError('minimum page count cannot exceed maximum.');
    }

    final inspection = requireUsable(bytes);
    final pages = inspection.pageObjectCount;
    if (exact != null && pages != exact) {
      throw StateError('Generated PDF page count mismatch: expected=$exact actual=$pages.');
    }
    if (minimum != null && pages < minimum) {
      throw StateError('Generated PDF has too few pages: minimum=$minimum actual=$pages.');
    }
    if (maximum != null && pages > maximum) {
      throw StateError('Generated PDF has too many pages: maximum=$maximum actual=$pages.');
    }
    return inspection;
  }
}
