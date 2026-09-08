import 'dart:typed_data';

import 'pdf_output_inspector.dart';

/// Render-stage evidence produced by a real PDF rasterizer/parser.
///
/// The core deliberately consumes evidence instead of pretending that byte
/// pattern matching proves visual correctness. Platform/CI adapters may use
/// PDFium, Poppler or another deterministic renderer and feed the measured
/// result here.
final class PdfRenderedPageEvidence {
  const PdfRenderedPageEvidence({
    required this.pageNumber,
    required this.widthPx,
    required this.heightPx,
    required this.textOverflowPixels,
    required this.chartClipPixels,
    required this.brokenSymbolCount,
    required this.missingTurkishGlyphCount,
  });

  final int pageNumber;
  final int widthPx;
  final int heightPx;
  final int textOverflowPixels;
  final int chartClipPixels;
  final int brokenSymbolCount;
  final int missingTurkishGlyphCount;

  bool get hasValidCanvas => pageNumber > 0 && widthPx > 0 && heightPx > 0;
}

final class PdfVisualRegressionEvidence {
  const PdfVisualRegressionEvidence({
    required this.referenceId,
    required this.referenceVersion,
    required this.meanLayoutShiftRatio,
    required this.maximumLayoutShiftRatio,
    required this.changedPixelRatio,
  });

  final String referenceId;
  final String referenceVersion;

  /// Structural/layout displacement ratio after alignment, in [0, 1].
  final double meanLayoutShiftRatio;
  final double maximumLayoutShiftRatio;

  /// Informational pixel delta. It is intentionally *not* a hard pass/fail by
  /// itself because RC-0959 explicitly forbids treating every pixel change as
  /// a release failure.
  final double changedPixelRatio;
}

final class PdfExpectedReportIdentity {
  const PdfExpectedReportIdentity({
    required this.reportId,
    required this.subjectId,
    required this.subjectDisplayName,
    required this.requiredTextFragments,
    required this.requiresChart,
  });

  final String reportId;
  final String subjectId;
  final String subjectDisplayName;
  final Set<String> requiredTextFragments;
  final bool requiresChart;
}

final class PdfParsedContentEvidence {
  const PdfParsedContentEvidence({
    required this.reportId,
    required this.subjectId,
    required this.extractedText,
    required this.chartObjectCount,
  });

  final String reportId;
  final String subjectId;
  final String extractedText;
  final int chartObjectCount;
}

final class PdfReleaseValidationPolicy {
  const PdfReleaseValidationPolicy({
    this.maximumMeanLayoutShiftRatio = 0.035,
    this.maximumSinglePageLayoutShiftRatio = 0.08,
    this.inspector = const PdfOutputInspector(),
  });

  final double maximumMeanLayoutShiftRatio;
  final double maximumSinglePageLayoutShiftRatio;
  final PdfOutputInspector inspector;

  PdfOutputInspection validate({
    required Uint8List pdfBytes,
    required PdfExpectedReportIdentity expected,
    required PdfParsedContentEvidence parsed,
    required List<PdfRenderedPageEvidence> renderedPages,
    PdfVisualRegressionEvidence? visualRegression,
  }) {
    final inspection = inspector.requireUsable(pdfBytes);

    if (inspection.pageObjectCount <= 0) {
      throw StateError('Validated PDF must contain at least one page.');
    }
    if (parsed.reportId != expected.reportId) {
      throw StateError('Parsed PDF belongs to a different report.');
    }
    if (parsed.subjectId != expected.subjectId) {
      throw StateError(
        'CRITICAL: PDF subject identity does not match the requested report.',
      );
    }
    if (expected.subjectDisplayName.trim().isEmpty) {
      throw StateError('Expected PDF subject name cannot be empty.');
    }

    final missingText = expected.requiredTextFragments
        .where((fragment) => !parsed.extractedText.contains(fragment))
        .toList(growable: false);
    if (missingText.isNotEmpty) {
      throw StateError('PDF is missing required text fragments: $missingText');
    }

    if (expected.requiresChart && parsed.chartObjectCount <= 0) {
      throw StateError('PDF report requires a chart but none was parsed.');
    }

    if (renderedPages.length != inspection.pageObjectCount) {
      throw StateError(
        'Rendered page evidence count does not match PDF page count: '
        'rendered=${renderedPages.length} pdf=${inspection.pageObjectCount}.',
      );
    }
    for (var index = 0; index < renderedPages.length; index += 1) {
      final page = renderedPages[index];
      if (!page.hasValidCanvas || page.pageNumber != index + 1) {
        throw StateError('Invalid or out-of-order rendered page evidence.');
      }
      if (page.textOverflowPixels != 0) {
        throw StateError(
          'PDF text overflow is a hard release failure on page ${page.pageNumber}.',
        );
      }
      if (page.chartClipPixels != 0) {
        throw StateError(
          'PDF chart clipping is a hard release failure on page ${page.pageNumber}.',
        );
      }
      if (page.brokenSymbolCount != 0) {
        throw StateError(
          'PDF contains broken symbols on page ${page.pageNumber}.',
        );
      }
      if (page.missingTurkishGlyphCount != 0) {
        throw StateError(
          'PDF contains missing Turkish glyphs on page ${page.pageNumber}.',
        );
      }
    }

    if (visualRegression != null) {
      _validateVisualRegression(visualRegression);
    }
    return inspection;
  }

  void _validateVisualRegression(PdfVisualRegressionEvidence evidence) {
    if (evidence.referenceId.trim().isEmpty ||
        evidence.referenceVersion.trim().isEmpty) {
      throw StateError('Visual regression requires a versioned reference PDF.');
    }
    for (final value in <double>[
      evidence.meanLayoutShiftRatio,
      evidence.maximumLayoutShiftRatio,
      evidence.changedPixelRatio,
    ]) {
      if (!value.isFinite || value < 0 || value > 1) {
        throw StateError('Visual regression ratios must be finite values in [0,1].');
      }
    }
    if (evidence.meanLayoutShiftRatio > maximumMeanLayoutShiftRatio ||
        evidence.maximumLayoutShiftRatio > maximumSinglePageLayoutShiftRatio) {
      throw StateError(
        'Meaningful PDF layout regression exceeded release tolerance.',
      );
    }
    // changedPixelRatio is intentionally not thresholded. Anti-aliasing,
    // embedded-font rasterization and metadata can alter pixels without moving
    // layout; RC-0959 requires semantic layout tolerance instead.
  }
}
