import 'dart:convert';
import 'dart:typed_data';

/// Lightweight structural inspection for locally generated PDF bytes.
///
/// This is intentionally not a replacement for a full PDF parser. It catches
/// truncated/non-PDF output before the application presents or shares a file.
final class PdfOutputInspection {
  const PdfOutputInspection({
    required this.byteLength,
    required this.hasHeader,
    required this.hasEofMarker,
    required this.hasCatalog,
    required this.hasPagesTree,
    required this.pageObjectCount,
  });

  final int byteLength;
  final bool hasHeader;
  final bool hasEofMarker;
  final bool hasCatalog;
  final bool hasPagesTree;
  final int pageObjectCount;

  bool get structurallyUsable =>
      byteLength >= 64 &&
      hasHeader &&
      hasEofMarker &&
      hasCatalog &&
      hasPagesTree &&
      pageObjectCount > 0;
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

    return PdfOutputInspection(
      byteLength: bytes.length,
      hasHeader: hasHeader,
      hasEofMarker: text.contains('%%EOF'),
      hasCatalog: RegExp(r'/Type\s*/Catalog\b').hasMatch(text),
      hasPagesTree: RegExp(r'/Type\s*/Pages\b').hasMatch(text),
      pageObjectCount: pageObjectCount,
    );
  }

  PdfOutputInspection requireUsable(Uint8List bytes) {
    final inspection = inspect(bytes);
    if (!inspection.structurallyUsable) {
      throw StateError(
        'Generated PDF failed structural inspection: '
        'bytes=${inspection.byteLength}, header=${inspection.hasHeader}, '
        'eof=${inspection.hasEofMarker}, catalog=${inspection.hasCatalog}, '
        'pagesTree=${inspection.hasPagesTree}, pages=${inspection.pageObjectCount}.',
      );
    }
    return inspection;
  }
}
