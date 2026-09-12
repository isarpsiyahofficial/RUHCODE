import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_combined_report.dart';
import 'package:ruh_code/src/pdf/pdf_font_release_manifest.dart';
import 'package:ruh_code/src/pdf/production_combined_pdf_service.dart';
import 'package:ruh_code/src/pdf/unavailable_pdf_service.dart';

void main() {
  group('production combined PDF composition', () {
    test('remains fail-closed while canonical font manifest is not ready', () {
      expect(PdfFontReleaseManifest.isReleaseReady, isFalse);

      final service = createProductionCombinedPdfService(bundle: rootBundle);

      expect(
        service,
        isA<UnavailablePdfService<PdfCombinedReportProjection>>(),
      );
    });

    test('keeps the release blocker owned by the canonical manifest', () {
      expect(PdfFontReleaseManifest.blockingReason, isNotEmpty);
      expect(
        PdfFontReleaseManifest.blockingReason,
        contains('font binaries are not packaged'),
      );
    });
  });
}
