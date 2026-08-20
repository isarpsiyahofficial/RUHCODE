import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  const planner = PdfReportPlanner();

  test('A4 geometry and typography hierarchy are deterministic', () {
    expect(PdfPageSpec.a4.widthMm, 210);
    expect(PdfPageSpec.a4.heightMm, 297);
    expect(PdfPageSpec.a4.contentWidthMm, 178);
    expect(PdfPageSpec.a4.contentHeightMm, 263);
    expect(() => const PdfTypographyTokens().validate(), returnsNormally);
  });

  test('requested section order is preserved while empty sections are suppressed', () {
    final plan = planner.build(
      request: const PdfReportRequest(
        kind: PdfReportKind.western,
        dataOrigin: PdfDataOrigin.user,
        localeTag: 'tr',
        coverStyle: PdfCoverStyle.clientFriendly,
        requestedSectionIds: [
          PdfSectionIds.interpretation,
          PdfSectionIds.chart,
          PdfSectionIds.houses,
        ],
      ),
      availableSections: const [
        PdfSectionInput(id: PdfSectionIds.cover, hasContent: true),
        PdfSectionInput(id: PdfSectionIds.interpretation, hasContent: true),
        PdfSectionInput(id: PdfSectionIds.chart, hasContent: true),
        PdfSectionInput(id: PdfSectionIds.houses, hasContent: false),
      ],
    );

    expect(
      plan.sectionIds,
      [PdfSectionIds.cover, PdfSectionIds.interpretation, PdfSectionIds.chart],
    );
  });

  test('sample PDF cannot accidentally receive real user data origin', () {
    expect(
      () => planner.build(
        request: const PdfReportRequest(
          kind: PdfReportKind.sample,
          dataOrigin: PdfDataOrigin.user,
          localeTag: 'tr',
          coverStyle: PdfCoverStyle.clientFriendly,
          requestedSectionIds: [PdfSectionIds.summary],
        ),
        availableSections: const [
          PdfSectionInput(id: PdfSectionIds.summary, hasContent: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('real report cannot accidentally use demo data origin', () {
    expect(
      () => planner.build(
        request: const PdfReportRequest(
          kind: PdfReportKind.vedic,
          dataOrigin: PdfDataOrigin.demo,
          localeTag: 'en',
          coverStyle: PdfCoverStyle.professional,
          requestedSectionIds: [PdfSectionIds.vedicCharts],
        ),
        availableSections: const [
          PdfSectionInput(id: PdfSectionIds.vedicCharts, hasContent: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('TR and EN are accepted but arbitrary fallback locale is rejected', () {
    for (final locale in ['tr', 'en']) {
      expect(
        () => planner.build(
          request: PdfReportRequest(
            kind: PdfReportKind.numerology,
            dataOrigin: PdfDataOrigin.user,
            localeTag: locale,
            coverStyle: PdfCoverStyle.clientFriendly,
            requestedSectionIds: const [PdfSectionIds.numerology],
          ),
          availableSections: const [
            PdfSectionInput(id: PdfSectionIds.numerology, hasContent: true),
          ],
        ),
        returnsNormally,
      );
    }

    expect(
      () => planner.build(
        request: const PdfReportRequest(
          kind: PdfReportKind.numerology,
          dataOrigin: PdfDataOrigin.user,
          localeTag: 'de',
          coverStyle: PdfCoverStyle.clientFriendly,
          requestedSectionIds: [PdfSectionIds.numerology],
        ),
        availableSections: const [
          PdfSectionInput(id: PdfSectionIds.numerology, hasContent: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('duplicate requested sections are rejected instead of silently reordered', () {
    expect(
      () => planner.build(
        request: const PdfReportRequest(
          kind: PdfReportKind.combined,
          dataOrigin: PdfDataOrigin.user,
          localeTag: 'tr',
          coverStyle: PdfCoverStyle.professional,
          requestedSectionIds: [PdfSectionIds.summary, PdfSectionIds.summary],
        ),
        availableSections: const [
          PdfSectionInput(id: PdfSectionIds.summary, hasContent: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('report with no non-empty content cannot be generated', () {
    expect(
      () => planner.build(
        request: const PdfReportRequest(
          kind: PdfReportKind.western,
          dataOrigin: PdfDataOrigin.user,
          localeTag: 'en',
          coverStyle: PdfCoverStyle.professional,
          requestedSectionIds: [PdfSectionIds.houses],
        ),
        availableSections: const [
          PdfSectionInput(id: PdfSectionIds.cover, hasContent: true),
          PdfSectionInput(id: PdfSectionIds.houses, hasContent: false),
        ],
      ),
      throwsFormatException,
    );
  });
}
