import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ruh_code/src/pdf/pdf_release_validation.dart';

void main() {
  Future<Uint8List> samplePdf({int pages = 1}) async {
    final document = pw.Document();
    for (var i = 0; i < pages; i += 1) {
      document.addPage(pw.Page(build: (_) => pw.Text('Ruh Code page ${i + 1}')));
    }
    return Uint8List.fromList(await document.save());
  }

  PdfExpectedReportIdentity expected({bool chart = true}) =>
      PdfExpectedReportIdentity(
        reportId: 'report-001',
        subjectId: 'client-001',
        subjectDisplayName: 'İbrahim Şahin',
        requiredTextFragments: const <String>{
          'İbrahim Şahin',
          'Doğum Haritası',
        },
        requiresChart: chart,
      );

  PdfParsedContentEvidence parsed({
    String reportId = 'report-001',
    String subjectId = 'client-001',
    int charts = 1,
    String text = 'İbrahim Şahin — Doğum Haritası',
  }) =>
      PdfParsedContentEvidence(
        reportId: reportId,
        subjectId: subjectId,
        extractedText: text,
        chartObjectCount: charts,
      );

  List<PdfRenderedPageEvidence> pages(int count) => List.generate(
        count,
        (i) => PdfRenderedPageEvidence(
          pageNumber: i + 1,
          widthPx: 1240,
          heightPx: 1754,
          textOverflowPixels: 0,
          chartClipPixels: 0,
          brokenSymbolCount: 0,
          missingTurkishGlyphCount: 0,
        ),
      );

  test('valid parsed/rendered PDF evidence passes release validation', () async {
    const policy = PdfReleaseValidationPolicy();
    final bytes = await samplePdf(pages: 2);
    final result = policy.validate(
      pdfBytes: bytes,
      expected: expected(),
      parsed: parsed(),
      renderedPages: pages(2),
      visualRegression: const PdfVisualRegressionEvidence(
        referenceId: 'pdf-tr-western-reference',
        referenceVersion: '1',
        meanLayoutShiftRatio: 0.01,
        maximumLayoutShiftRatio: 0.03,
        changedPixelRatio: 0.42,
      ),
    );
    expect(result.pageObjectCount, 2);
  });

  test('missing required text is a hard failure', () async {
    final bytes = await samplePdf();
    expect(
      () => const PdfReleaseValidationPolicy().validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(text: 'İbrahim Şahin'),
        renderedPages: pages(1),
      ),
      throwsStateError,
    );
  });

  test('required chart must be present in parsed PDF evidence', () async {
    final bytes = await samplePdf();
    expect(
      () => const PdfReleaseValidationPolicy().validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(charts: 0),
        renderedPages: pages(1),
      ),
      throwsStateError,
    );
  });

  test('page count must match actual rendered pages', () async {
    final bytes = await samplePdf(pages: 2);
    expect(
      () => const PdfReleaseValidationPolicy().validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(),
        renderedPages: pages(1),
      ),
      throwsStateError,
    );
  });

  test('text overflow, chart clipping, broken symbol and Turkish glyph loss are hard failures', () async {
    final bytes = await samplePdf();
    for (final bad in <PdfRenderedPageEvidence>[
      const PdfRenderedPageEvidence(
        pageNumber: 1,
        widthPx: 1240,
        heightPx: 1754,
        textOverflowPixels: 1,
        chartClipPixels: 0,
        brokenSymbolCount: 0,
        missingTurkishGlyphCount: 0,
      ),
      const PdfRenderedPageEvidence(
        pageNumber: 1,
        widthPx: 1240,
        heightPx: 1754,
        textOverflowPixels: 0,
        chartClipPixels: 2,
        brokenSymbolCount: 0,
        missingTurkishGlyphCount: 0,
      ),
      const PdfRenderedPageEvidence(
        pageNumber: 1,
        widthPx: 1240,
        heightPx: 1754,
        textOverflowPixels: 0,
        chartClipPixels: 0,
        brokenSymbolCount: 1,
        missingTurkishGlyphCount: 0,
      ),
      const PdfRenderedPageEvidence(
        pageNumber: 1,
        widthPx: 1240,
        heightPx: 1754,
        textOverflowPixels: 0,
        chartClipPixels: 0,
        brokenSymbolCount: 0,
        missingTurkishGlyphCount: 1,
      ),
    ]) {
      expect(
        () => const PdfReleaseValidationPolicy().validate(
          pdfBytes: bytes,
          expected: expected(),
          parsed: parsed(),
          renderedPages: <PdfRenderedPageEvidence>[bad],
        ),
        throwsStateError,
      );
    }
  });

  test('different subject identity is a critical fail-closed condition', () async {
    final bytes = await samplePdf();
    expect(
      () => const PdfReleaseValidationPolicy().validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(subjectId: 'client-OTHER'),
        renderedPages: pages(1),
      ),
      throwsStateError,
    );
  });

  test('large layout shifts fail but raw pixel difference alone does not', () async {
    final bytes = await samplePdf();
    const policy = PdfReleaseValidationPolicy();

    expect(
      () => policy.validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(),
        renderedPages: pages(1),
        visualRegression: const PdfVisualRegressionEvidence(
          referenceId: 'ref',
          referenceVersion: '1',
          meanLayoutShiftRatio: 0.01,
          maximumLayoutShiftRatio: 0.03,
          changedPixelRatio: 0.95,
        ),
      ),
      returnsNormally,
    );

    expect(
      () => policy.validate(
        pdfBytes: bytes,
        expected: expected(),
        parsed: parsed(),
        renderedPages: pages(1),
        visualRegression: const PdfVisualRegressionEvidence(
          referenceId: 'ref',
          referenceVersion: '1',
          meanLayoutShiftRatio: 0.04,
          maximumLayoutShiftRatio: 0.09,
          changedPixelRatio: 0.05,
        ),
      ),
      throwsStateError,
    );
  });
}
