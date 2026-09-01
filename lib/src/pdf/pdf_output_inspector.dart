import 'dart:convert';
import 'dart:typed_data';

/// Lightweight structural inspection for locally generated PDF bytes.
///
/// This is intentionally not a replacement for a full PDF parser. It catches
/// truncated/non-PDF output and broken cross-reference/catalog/page-tree links
/// before the application presents or shares a file.
final class PdfOutputInspection {
  const PdfOutputInspection({
    required this.byteLength,
    required this.hasHeader,
    required this.hasEofMarker,
    required this.hasCatalog,
    required this.hasPagesTree,
    required this.pageObjectCount,
    required this.declaredPageCount,
    required this.pageParentsPresent,
    required this.pageParentsResolveToPages,
    required this.hasStartXref,
    required this.startXrefOffset,
    required this.startXrefTargetRecognized,
    required this.xrefHasRootReference,
    required this.rootReferenceResolvesToCatalog,
    required this.catalogPagesReferenceResolves,
  });

  final int byteLength;
  final bool hasHeader;
  final bool hasEofMarker;
  final bool hasCatalog;
  final bool hasPagesTree;
  final int pageObjectCount;
  final int? declaredPageCount;
  final bool pageParentsPresent;
  final bool pageParentsResolveToPages;
  final bool hasStartXref;
  final int? startXrefOffset;
  final bool startXrefTargetRecognized;
  final bool xrefHasRootReference;
  final bool rootReferenceResolvesToCatalog;
  final bool catalogPagesReferenceResolves;

  bool get pageTreeCountConsistent =>
      declaredPageCount != null && declaredPageCount == pageObjectCount;

  bool get pageParentLinksValid =>
      pageObjectCount > 0 && pageParentsPresent && pageParentsResolveToPages;

  bool get structurallyUsable =>
      byteLength >= 64 &&
      hasHeader &&
      hasEofMarker &&
      hasCatalog &&
      hasPagesTree &&
      pageObjectCount > 0 &&
      pageTreeCountConsistent &&
      pageParentLinksValid &&
      hasStartXref &&
      startXrefOffset != null &&
      startXrefTargetRecognized &&
      xrefHasRootReference &&
      rootReferenceResolvesToCatalog &&
      catalogPagesReferenceResolves;
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

    // latin1 preserves a one-code-unit-per-byte mapping, so startxref's byte
    // offset can be validated directly against String indices here.
    final text = latin1.decode(bytes, allowInvalid: true);
    final pageObjects = _pageObjects(text);
    final pageObjectCount = pageObjects.length;
    final pageParentStatus = _pageParentStatus(text, pageObjects);
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
    final rootReference = startXrefOffset != null && startXrefTargetRecognized
        ? _rootReference(text, startXrefOffset)
        : null;
    final xrefHasRootReference = rootReference != null;
    final rootReferenceResolvesToCatalog = rootReference != null &&
        _objectHasType(text, rootReference.$1, rootReference.$2, 'Catalog');
    final catalogPagesReference = rootReferenceResolvesToCatalog
        ? _catalogPagesReference(text, rootReference.$1, rootReference.$2)
        : null;
    final catalogPagesReferenceResolves = catalogPagesReference != null &&
        _objectHasType(
          text,
          catalogPagesReference.$1,
          catalogPagesReference.$2,
          'Pages',
        );

    return PdfOutputInspection(
      byteLength: bytes.length,
      hasHeader: hasHeader,
      hasEofMarker: eofMatch != null,
      hasCatalog: RegExp(r'/Type\s*/Catalog\b').hasMatch(text),
      hasPagesTree: RegExp(r'/Type\s*/Pages\b').hasMatch(text),
      pageObjectCount: pageObjectCount,
      declaredPageCount: declaredPageCount,
      pageParentsPresent: pageParentStatus.$1,
      pageParentsResolveToPages: pageParentStatus.$2,
      hasStartXref: startXrefMatch != null,
      startXrefOffset: startXrefOffset,
      startXrefTargetRecognized: startXrefTargetRecognized,
      xrefHasRootReference: xrefHasRootReference,
      rootReferenceResolvesToCatalog: rootReferenceResolvesToCatalog,
      catalogPagesReferenceResolves: catalogPagesReferenceResolves,
    );
  }

  List<(int, int, String)> _pageObjects(String text) {
    final objects = <(int, int, String)>[];
    final objectPattern = RegExp(
      r'^(\d+)\s+(\d+)\s+obj\b((?:(?!endobj).)*)endobj',
      dotAll: true,
      multiLine: true,
    );
    final pageType = RegExp(r'/Type\s*/Page(?!s)\b');
    for (final match in objectPattern.allMatches(text)) {
      final body = match.group(3)!;
      if (!pageType.hasMatch(body)) {
        continue;
      }
      final objectNumber = int.tryParse(match.group(1)!);
      final generation = int.tryParse(match.group(2)!);
      if (objectNumber == null || generation == null) {
        continue;
      }
      objects.add((objectNumber, generation, body));
    }
    return objects;
  }

  (bool, bool) _pageParentStatus(
    String text,
    List<(int, int, String)> pageObjects,
  ) {
    if (pageObjects.isEmpty) {
      return (false, false);
    }
    var allPresent = true;
    var allResolveToPages = true;
    final parentPattern = RegExp(r'/Parent\s+(\d+)\s+(\d+)\s+R\b');
    for (final page in pageObjects) {
      final parentMatch = parentPattern.firstMatch(page.$3);
      if (parentMatch == null) {
        allPresent = false;
        allResolveToPages = false;
        continue;
      }
      final parentObject = int.tryParse(parentMatch.group(1)!);
      final parentGeneration = int.tryParse(parentMatch.group(2)!);
      if (parentObject == null || parentGeneration == null) {
        allPresent = false;
        allResolveToPages = false;
        continue;
      }
      if (!_objectHasType(text, parentObject, parentGeneration, 'Pages')) {
        allResolveToPages = false;
      }
    }
    return (allPresent, allResolveToPages);
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

  (int, int)? _rootReference(String text, int offset) {
    if (offset < 0 || offset >= text.length) {
      return null;
    }
    final tail = text.substring(offset);
    final Match? match;
    if (RegExp(r'^xref\b').hasMatch(tail)) {
      // A classic trailer may legally contain nested dictionaries (for
      // example /Info metadata). Stopping at the first `>>` therefore rejects
      // otherwise valid PDFs emitted by the production `pdf` package. Bound
      // the search to the trailer section up to startxref instead, then require
      // an explicit indirect /Root reference inside that section.
      final trailerMatch = RegExp(
        r'^xref\b(?:(?!startxref).)*?trailer\b',
        dotAll: true,
      ).firstMatch(tail);
      if (trailerMatch == null) {
        return null;
      }
      final startXrefIndex = tail.indexOf('startxref', trailerMatch.end);
      if (startXrefIndex < 0) {
        return null;
      }
      final trailerSection = tail.substring(trailerMatch.end, startXrefIndex);
      match = RegExp(
        r'/Root\s+(\d+)\s+(\d+)\s+R\b',
      ).firstMatch(trailerSection);
    } else {
      match = RegExp(
        r'^\d+\s+\d+\s+obj\b(?:(?!endobj).)*?/Type\s*/XRef\b(?:(?!endobj).)*?/Root\s+(\d+)\s+(\d+)\s+R\b',
        dotAll: true,
      ).firstMatch(tail);
    }
    if (match == null) {
      return null;
    }
    final objectNumber = int.tryParse(match.group(1)!);
    final generation = int.tryParse(match.group(2)!);
    if (objectNumber == null || generation == null) {
      return null;
    }
    return (objectNumber, generation);
  }

  bool _objectHasType(
    String text,
    int objectNumber,
    int generation,
    String type,
  ) {
    return RegExp(
      '^$objectNumber\\s+$generation\\s+obj\\b(?:(?!endobj).)*?/Type\\s*/$type\\b',
      dotAll: true,
      multiLine: true,
    ).hasMatch(text);
  }

  (int, int)? _catalogPagesReference(
    String text,
    int objectNumber,
    int generation,
  ) {
    final match = RegExp(
      '^$objectNumber\\s+$generation\\s+obj\\b(?:(?!endobj).)*?/Type\\s*/Catalog\\b(?:(?!endobj).)*?/Pages\\s+(\\d+)\\s+(\\d+)\\s+R\\b',
      dotAll: true,
      multiLine: true,
    ).firstMatch(text);
    if (match == null) {
      return null;
    }
    final pagesObject = int.tryParse(match.group(1)!);
    final pagesGeneration = int.tryParse(match.group(2)!);
    if (pagesObject == null || pagesGeneration == null) {
      return null;
    }
    return (pagesObject, pagesGeneration);
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
        'pageParentsPresent=${inspection.pageParentsPresent}, '
        'pageParentsResolveToPages=${inspection.pageParentsResolveToPages}, '
        'startXref=${inspection.hasStartXref}, '
        'startXrefOffset=${inspection.startXrefOffset}, '
        'xrefTarget=${inspection.startXrefTargetRecognized}, '
        'xrefRoot=${inspection.xrefHasRootReference}, '
        'rootCatalog=${inspection.rootReferenceResolvesToCatalog}, '
        'catalogPages=${inspection.catalogPagesReferenceResolves}.',
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
