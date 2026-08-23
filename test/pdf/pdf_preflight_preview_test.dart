import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_preflight_preview.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  const builder = PdfPreflightPreviewBuilder();

  PdfReportPlan plan({List<String>? sections}) => PdfReportPlan(
        kind: PdfReportKind.western,
        dataOrigin: PdfDataOrigin.user,
        localeTag: 'tr-TR',
        coverStyle: PdfCoverStyle.professional,
        sectionIds: sections ?? const [PdfSectionIds.cover, PdfSectionIds.chart, PdfSectionIds.placements],
        branding: const PdfBranding(professionalName: 'Uzman'),
        pageSpec: PdfPageSpec.a4,
        typography: const PdfTypographyTokens(),
      );

  test('preview preserves exact planned section order and layout metadata', () {
    final preview = builder.fromPlan(plan());
    expect(preview.kind, PdfReportKind.western);
    expect(preview.localeTag, 'tr-TR');
    expect(preview.coverStyle, PdfCoverStyle.professional);
    expect(preview.sectionIds, [PdfSectionIds.cover, PdfSectionIds.chart, PdfSectionIds.placements]);
    expect(preview.pageSpec.widthMm, 210);
    expect(preview.pageSpec.heightMm, 297);
    expect(preview.hasBranding, isTrue);
  });

  test('preview section list is immutable', () {
    final preview = builder.fromPlan(plan());
    expect(() => preview.sectionIds.add(PdfSectionIds.aspects), throwsUnsupportedError);
  });

  test('empty plan fails closed instead of showing a fake preview', () {
    expect(() => builder.fromPlan(plan(sections: const [])), throwsFormatException);
  });

  test('duplicate sections fail closed', () {
    expect(
      () => builder.fromPlan(plan(sections: const [PdfSectionIds.chart, PdfSectionIds.chart])),
      throwsFormatException,
    );
  });
}
