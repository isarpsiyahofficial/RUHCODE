import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_document_layout_safety.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/pdf_table_layout.dart';

void main() {
  PdfReportPlan plan({PdfPageSpec pageSpec = PdfPageSpec.a4}) => PdfReportPlan(
        kind: PdfReportKind.combined,
        dataOrigin: PdfDataOrigin.user,
        localeTag: 'tr',
        coverStyle: PdfCoverStyle.professional,
        sectionIds: const <String>[PdfSectionIds.cover, PdfSectionIds.summary],
        branding: const PdfBranding(),
        pageSpec: pageSpec,
        typography: const PdfTypographyTokens(),
      );

  test('professional layout uses A4 with safe physical margins', () {
    expect(
      () => const PdfDocumentLayoutSafety().validate(plan()),
      returnsNormally,
    );
    expect(PdfPageSpec.a4.contentWidthMm, 178);
    expect(PdfPageSpec.a4.contentHeightMm, 263);
  });

  test('unsafe margins fail closed', () {
    const unsafe = PdfPageSpec(
      widthMm: 210,
      heightMm: 297,
      marginTopMm: 4,
      marginRightMm: 16,
      marginBottomMm: 18,
      marginLeftMm: 16,
    );
    expect(
      () => const PdfDocumentLayoutSafety().validate(plan(pageSpec: unsafe)),
      throwsFormatException,
    );
  });

  test('long Turkish and English headings remain Unicode and are not truncated', () {
    const safety = PdfDocumentLayoutSafety();
    const tr = 'Çok Uzun Danışan Adı ŞĞİÖÜ Çalışma Başlığı ve Profesyonel Rapor Açıklaması';
    const en = 'Very Long Professional Consultation Report Heading With Multiple Descriptive Terms';
    expect(safety.preserveWrappingText(tr), tr);
    expect(safety.preserveWrappingText(en), en);
  });

  test('table chunking repeats headers and creates safe page-break opportunities', () {
    final rows = <List<String>>[
      const <String>['Başlık', 'Değer'],
      for (var i = 0; i < 61; i++) <String>['Satır $i', 'Değer $i'],
    ];
    final chunks = const PdfTableLayout(maxBodyRowsPerChunk: 24).chunk(rows);
    expect(chunks.length, 3);
    for (final chunk in chunks) {
      expect(chunk.rows.first, const <String>['Başlık', 'Değer']);
      expect(chunk.rows.length, lessThanOrEqualTo(25));
    }
  });
}
