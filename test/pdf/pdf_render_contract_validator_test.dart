import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  const digest = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  test('verified unselected render payload is allowed but selected subset stays strict', () {
    const validator = PdfRenderContractValidator();
    final payload = _payload(
      selected: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      datasetIds: const [
        PdfSectionIds.cover,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
      renderIds: const [
        PdfSectionIds.cover,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
      digest: digest,
    );

    expect(() => validator.validate(payload), returnsNormally);
  });

  test('selected section without render payload fails closed', () {
    const validator = PdfRenderContractValidator();
    final payload = _payload(
      selected: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      datasetIds: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      renderIds: const [PdfSectionIds.cover],
      digest: digest,
    );

    expect(
      () => validator.validate(payload),
      throwsA(isA<FormatException>().having(
        (error) => error.message,
        'message',
        contains('has no render payload'),
      )),
    );
  });

  test('render payload not declared by verified dataset fails closed', () {
    const validator = PdfRenderContractValidator();
    final payload = _payload(
      selected: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      datasetIds: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      renderIds: const [
        PdfSectionIds.cover,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
      digest: digest,
    );

    expect(
      () => validator.validate(payload),
      throwsA(isA<FormatException>().having(
        (error) => error.message,
        'message',
        contains('not declared by the verified dataset'),
      )),
    );
  });

  test('unselected payload from another snapshot still fails closed', () {
    const validator = PdfRenderContractValidator();
    final payload = _payload(
      selected: const [PdfSectionIds.cover, PdfSectionIds.numerology],
      datasetIds: const [
        PdfSectionIds.cover,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
      renderIds: const [
        PdfSectionIds.cover,
        PdfSectionIds.numerology,
        PdfSectionIds.technicalManifest,
      ],
      digest: digest,
      overrideDigestById: const {
        PdfSectionIds.technicalManifest:
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      },
    );

    expect(
      () => validator.validate(payload),
      throwsA(isA<FormatException>().having(
        (error) => error.message,
        'message',
        contains('belongs to another snapshot'),
      )),
    );
  });
}

PdfRenderPayload _payload({
  required List<String> selected,
  required List<String> datasetIds,
  required List<String> renderIds,
  required String digest,
  Map<String, String> overrideDigestById = const {},
}) {
  final fontBytes = Uint8List.fromList(const [1, 2, 3, 4]);
  final fontDigest = sha256.convert(fontBytes).toString();
  return PdfRenderPayload(
    plan: PdfReportPlan(
      kind: PdfReportKind.numerology,
      dataOrigin: PdfDataOrigin.user,
      localeTag: 'tr',
      coverStyle: PdfCoverStyle.professional,
      sectionIds: selected,
      branding: const PdfBranding(),
      pageSpec: PdfPageSpec.a4,
      typography: const PdfTypographyTokens(),
    ),
    dataset: PdfReportDataset(
      origin: PdfDataOrigin.user,
      identity: PdfSnapshotIdentity(
        subjectKind: PdfSubjectKind.profile,
        subjectId: 'profile-1',
        snapshotDigest: digest,
        engineVersion: '1',
        algorithmVersion: '1',
        dataVersion: '1',
      ),
      sections: [
        for (final id in datasetIds)
          PdfSectionDataRef(
            sectionId: id,
            snapshotDigest: digest,
            hasContent: true,
          ),
      ],
    ),
    documentTitle: 'Ruh Code Test',
    sections: [
      for (final id in renderIds)
        PdfRenderSection(
          sectionId: id,
          snapshotDigest: overrideDigestById[id] ?? digest,
          title: id,
          paragraphs: const ['content'],
        ),
    ],
    fonts: PdfFontBundle(
      regularBytes: fontBytes,
      boldBytes: fontBytes,
      regularSha256: fontDigest,
      boldSha256: fontDigest,
      familyName: 'TestFont',
      licenseId: 'TEST-ONLY',
    ),
  );
}
