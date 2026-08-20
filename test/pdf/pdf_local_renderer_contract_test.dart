import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  const digest = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  PdfReportPlan plan() => const PdfReportPlan(
        kind: PdfReportKind.western,
        dataOrigin: PdfDataOrigin.user,
        localeTag: 'tr',
        coverStyle: PdfCoverStyle.professional,
        sectionIds: <String>[PdfSectionIds.cover, PdfSectionIds.summary],
        branding: PdfBranding(),
        pageSpec: PdfPageSpec.a4,
        typography: PdfTypographyTokens(),
      );

  PdfReportDataset dataset() => const PdfReportDataset(
        origin: PdfDataOrigin.user,
        identity: PdfSnapshotIdentity(
          subjectKind: PdfSubjectKind.profile,
          subjectId: 'profile-1',
          snapshotDigest: digest,
          engineVersion: '1',
          algorithmVersion: '1',
          dataVersion: '1',
        ),
        sections: <PdfSectionDataRef>[
          PdfSectionDataRef(sectionId: PdfSectionIds.cover, snapshotDigest: digest, hasContent: true),
          PdfSectionDataRef(sectionId: PdfSectionIds.summary, snapshotDigest: digest, hasContent: true),
        ],
      );

  PdfFontBundle fakeFontBundle() {
    final regular = Uint8List.fromList(utf8.encode('not-a-real-font-regular'));
    final bold = Uint8List.fromList(utf8.encode('not-a-real-font-bold'));
    return PdfFontBundle(
      regularBytes: regular,
      boldBytes: bold,
      regularSha256: sha256.convert(regular).toString(),
      boldSha256: sha256.convert(bold).toString(),
      familyName: 'Contract Test Font',
      licenseId: 'TEST-ONLY',
    );
  }

  test('font bundle rejects a mismatched SHA-256 digest before rendering', () {
    final bytes = Uint8List.fromList(<int>[1, 2, 3]);
    final bundle = PdfFontBundle(
      regularBytes: bytes,
      boldBytes: bytes,
      regularSha256: '0' * 64,
      boldSha256: sha256.convert(bytes).toString(),
      familyName: 'Test',
      licenseId: 'TEST',
    );

    expect(bundle.validate, throwsFormatException);
  });

  test('renderer rejects cross-snapshot render section before parsing fonts', () async {
    final payload = PdfRenderPayload(
      plan: plan(),
      dataset: dataset(),
      documentTitle: 'Doğum Haritası Raporu',
      fonts: fakeFontBundle(),
      sections: const <PdfRenderSection>[
        PdfRenderSection(
          sectionId: PdfSectionIds.cover,
          snapshotDigest: digest,
          title: 'Doğum Haritası Raporu',
          paragraphs: <String>['Ruh Code'],
        ),
        PdfRenderSection(
          sectionId: PdfSectionIds.summary,
          snapshotDigest: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          title: 'Özet',
          paragraphs: <String>['Özet içerik'],
        ),
      ],
    );

    await expectLater(const PdfLocalRenderer().render(payload), throwsFormatException);
  });

  test('renderer rejects a selected section without render payload', () async {
    final payload = PdfRenderPayload(
      plan: plan(),
      dataset: dataset(),
      documentTitle: 'Doğum Haritası Raporu',
      fonts: fakeFontBundle(),
      sections: const <PdfRenderSection>[
        PdfRenderSection(
          sectionId: PdfSectionIds.cover,
          snapshotDigest: digest,
          title: 'Doğum Haritası Raporu',
          paragraphs: <String>['Ruh Code'],
        ),
      ],
    );

    await expectLater(const PdfLocalRenderer().render(payload), throwsFormatException);
  });
}
