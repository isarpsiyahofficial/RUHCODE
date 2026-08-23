import 'dart:convert';
import 'dart:typed_data';

final class PdfPageGeometryInspection {
  const PdfPageGeometryInspection({
    required this.mediaBoxCount,
    required this.allPositive,
    required this.allMatchExpected,
  });

  final int mediaBoxCount;
  final bool allPositive;
  final bool allMatchExpected;

  bool get usable => mediaBoxCount > 0 && allPositive && allMatchExpected;
}

/// Lightweight geometry gate for locally generated PDF pages.
///
/// The production renderer receives an explicit [PdfPageSpec]. This inspector
/// verifies that the serialized PDF carries matching `/MediaBox` dimensions so
/// an accidental page-format drift cannot pass unnoticed.
final class PdfPageGeometryInspector {
  const PdfPageGeometryInspector();

  PdfPageGeometryInspection inspect(
    Uint8List bytes, {
    required double expectedWidthPt,
    required double expectedHeightPt,
    double tolerancePt = 0.75,
  }) {
    if (!expectedWidthPt.isFinite ||
        !expectedHeightPt.isFinite ||
        expectedWidthPt <= 0 ||
        expectedHeightPt <= 0) {
      throw ArgumentError('Expected PDF page dimensions must be finite and positive.');
    }
    if (!tolerancePt.isFinite || tolerancePt < 0) {
      throw ArgumentError.value(tolerancePt, 'tolerancePt', 'Tolerance must be finite and non-negative.');
    }

    final text = latin1.decode(bytes, allowInvalid: true);
    final matches = RegExp(
      r'/MediaBox\s*\[\s*([-+]?\d+(?:\.\d+)?)\s+([-+]?\d+(?:\.\d+)?)\s+([-+]?\d+(?:\.\d+)?)\s+([-+]?\d+(?:\.\d+)?)\s*\]',
    ).allMatches(text).toList(growable: false);

    var allPositive = true;
    var allMatchExpected = true;
    for (final match in matches) {
      final x0 = double.tryParse(match.group(1)!);
      final y0 = double.tryParse(match.group(2)!);
      final x1 = double.tryParse(match.group(3)!);
      final y1 = double.tryParse(match.group(4)!);
      if (x0 == null || y0 == null || x1 == null || y1 == null) {
        allPositive = false;
        allMatchExpected = false;
        continue;
      }
      final width = x1 - x0;
      final height = y1 - y0;
      if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
        allPositive = false;
        allMatchExpected = false;
        continue;
      }
      if ((width - expectedWidthPt).abs() > tolerancePt ||
          (height - expectedHeightPt).abs() > tolerancePt) {
        allMatchExpected = false;
      }
    }

    return PdfPageGeometryInspection(
      mediaBoxCount: matches.length,
      allPositive: allPositive,
      allMatchExpected: allMatchExpected,
    );
  }

  PdfPageGeometryInspection requireExpectedGeometry(
    Uint8List bytes, {
    required double expectedWidthPt,
    required double expectedHeightPt,
    double tolerancePt = 0.75,
  }) {
    final inspection = inspect(
      bytes,
      expectedWidthPt: expectedWidthPt,
      expectedHeightPt: expectedHeightPt,
      tolerancePt: tolerancePt,
    );
    if (!inspection.usable) {
      throw StateError(
        'Generated PDF page geometry mismatch: '
        'mediaBoxes=${inspection.mediaBoxCount}, '
        'positive=${inspection.allPositive}, '
        'matchesExpected=${inspection.allMatchExpected}, '
        'expected=${expectedWidthPt}x$expectedHeightPt pt.',
      );
    }
    return inspection;
  }
}
