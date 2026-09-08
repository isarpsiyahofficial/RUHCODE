import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_release_boundary.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  PdfReportPlan plan({String locale = 'tr'}) => PdfReportPlan(
        kind: PdfReportKind.western,
        dataOrigin: PdfDataOrigin.user,
        localeTag: locale,
        coverStyle: PdfCoverStyle.professional,
        sectionIds: const <String>[PdfSectionIds.cover, PdfSectionIds.summary],
        branding: const PdfBranding(),
        pageSpec: PdfPageSpec.a4,
        typography: const PdfTypographyTokens(),
      );

  test('production boundary is local, non-recomputing and screenshot-free', () {
    expect(
      () => const PdfReleaseBoundary().validate(plan: plan()),
      returnsNormally,
    );
  });

  test('off-device PDF generation is rejected', () {
    expect(
      () => const PdfReleaseBoundary(onDeviceOnly: false).validate(plan: plan()),
      throwsFormatException,
    );
    expect(
      () => const PdfReleaseBoundary(sendsPersonalDataOffDevice: true).validate(plan: plan()),
      throwsFormatException,
    );
  });

  test('recalculation and screen-capture based PDF generation are rejected', () {
    expect(
      () => const PdfReleaseBoundary(recomputesCalculations: true).validate(plan: plan()),
      throwsFormatException,
    );
    expect(
      () => const PdfReleaseBoundary(capturesApplicationScreens: true).validate(plan: plan()),
      throwsFormatException,
    );
    expect(
      () => const PdfReleaseBoundary(usesLowResolutionChartJpeg: true).validate(plan: plan()),
      throwsFormatException,
    );
  });

  test('PDF release boundary permits only TR/EN and real A4 geometry', () {
    expect(
      () => const PdfReleaseBoundary().validate(plan: plan(locale: 'en')),
      returnsNormally,
    );
    expect(
      () => const PdfReleaseBoundary().validate(plan: plan(locale: 'de')),
      throwsFormatException,
    );
  });

  test('filename sanitizer preserves Turkish letters and removes reserved characters', () {
    final name = PdfReportFileName.build(
      subjectName: 'İbrahim: Özlem / Danışan?*',
      kind: PdfReportKind.combined,
      generatedAtUtc: DateTime.utc(2026, 9, 8),
    );
    expect(name, 'İbrahim_Özlem_Danışan_combined_2026-09-08.pdf');
    expect(name, isNot(contains(':')));
    expect(name, isNot(contains('/')));
    expect(name, isNot(contains('?')));
  });
}
