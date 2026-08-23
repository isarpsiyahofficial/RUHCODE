import 'package:flutter_test/flutter_test.dart';

import 'package:ruh_code/src/pdf/pdf_combined_report.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  const builder = PdfCombinedReportBuilder();

  test('combines two distinct systems for the same subject deterministically', () {
    final western = _member(
      systemId: 'western.natal',
      digest: _hex('a'),
      sectionId: PdfSectionIds.placements,
      sectionTitle: 'Western Placements',
    );
    final numerology = _member(
      systemId: 'numerology.pythagorean',
      digest: _hex('b'),
      sectionId: PdfSectionIds.numerology,
      sectionTitle: 'Numerology',
    );

    final first = _build(builder, <PdfCombinedMember>[western, numerology]);
    final reversed = _build(builder, <PdfCombinedMember>[numerology, western]);

    expect(first.memberSystemIds,
        <String>['numerology.pythagorean', 'western.natal']);
    expect(first.dataset.identity.snapshotDigest,
        reversed.dataset.identity.snapshotDigest);
    expect(first.dataset.identity.subjectId, 'profile-1');
    expect(first.dataset.identity.subjectKind, PdfSubjectKind.profile);
    expect(first.sections.map((section) => section.sectionId), <String>[
      PdfSectionIds.cover,
      PdfSectionIds.numerology,
      PdfSectionIds.placements,
      PdfSectionIds.technicalManifest,
    ]);
    expect(
      first.sections.every(
        (section) =>
            section.snapshotDigest == first.dataset.identity.snapshotDigest,
      ),
      isTrue,
    );

    const PdfReportDataValidator().validateAndProject(first.dataset);
  });

  test('rejects a combined report with fewer than two systems', () {
    expect(
      () => _build(builder, <PdfCombinedMember>[
        _member(
          systemId: 'western.natal',
          digest: _hex('a'),
          sectionId: PdfSectionIds.placements,
          sectionTitle: 'Western Placements',
        ),
      ]),
      throwsFormatException,
    );
  });

  test('rejects members that belong to different stable subjects', () {
    final western = _member(
      systemId: 'western.natal',
      digest: _hex('a'),
      sectionId: PdfSectionIds.placements,
      sectionTitle: 'Western Placements',
    );
    final numerology = _member(
      systemId: 'numerology.pythagorean',
      digest: _hex('b'),
      sectionId: PdfSectionIds.numerology,
      sectionTitle: 'Numerology',
      subjectId: 'profile-2',
    );

    expect(
      () => _build(builder, <PdfCombinedMember>[western, numerology]),
      throwsFormatException,
    );
  });

  test('rejects section collisions between systems', () {
    final western = _member(
      systemId: 'western.natal',
      digest: _hex('a'),
      sectionId: PdfSectionIds.summary,
      sectionTitle: 'Western Summary',
    );
    final numerology = _member(
      systemId: 'numerology.pythagorean',
      digest: _hex('b'),
      sectionId: PdfSectionIds.summary,
      sectionTitle: 'Numerology Summary',
    );

    expect(
      () => _build(builder, <PdfCombinedMember>[western, numerology]),
      throwsFormatException,
    );
  });

  test('rejects child render data with another snapshot digest', () {
    final bad = PdfCombinedMember(
      systemId: 'western.natal',
      identity: _identity(_hex('a')),
      sections: <PdfRenderSection>[
        PdfRenderSection(
          sectionId: PdfSectionIds.placements,
          snapshotDigest: _hex('c'),
          title: 'Western Placements',
          paragraphs: const <String>['Stored data'],
        ),
      ],
    );
    final numerology = _member(
      systemId: 'numerology.pythagorean',
      digest: _hex('b'),
      sectionId: PdfSectionIds.numerology,
      sectionTitle: 'Numerology',
    );

    expect(
      () => _build(builder, <PdfCombinedMember>[bad, numerology]),
      throwsFormatException,
    );
  });

  test('rejects child cover or technical-manifest ownership', () {
    for (final reserved in <String>[
      PdfSectionIds.cover,
      PdfSectionIds.technicalManifest,
    ]) {
      final bad = _member(
        systemId: 'western.natal',
        digest: _hex('a'),
        sectionId: reserved,
        sectionTitle: 'Reserved',
      );
      final numerology = _member(
        systemId: 'numerology.pythagorean',
        digest: _hex('b'),
        sectionId: PdfSectionIds.numerology,
        sectionTitle: 'Numerology',
      );
      expect(
        () => _build(builder, <PdfCombinedMember>[bad, numerology]),
        throwsFormatException,
      );
    }
  });
}

PdfCombinedReportProjection _build(
  PdfCombinedReportBuilder builder,
  List<PdfCombinedMember> members,
) {
  return builder.build(
    members: members,
    coverTitle: 'Combined Consultation Report',
    technicalTitle: 'Calculation Sources',
    systemHeader: 'System',
    fieldHeader: 'Field',
    valueHeader: 'Value',
  );
}

PdfCombinedMember _member({
  required String systemId,
  required String digest,
  required String sectionId,
  required String sectionTitle,
  String subjectId = 'profile-1',
}) {
  return PdfCombinedMember(
    systemId: systemId,
    identity: _identity(digest, subjectId: subjectId),
    sections: <PdfRenderSection>[
      PdfRenderSection(
        sectionId: sectionId,
        snapshotDigest: digest,
        title: sectionTitle,
        paragraphs: const <String>['Stored calculation data'],
      ),
    ],
  );
}

PdfSnapshotIdentity _identity(String digest, {String subjectId = 'profile-1'}) {
  return PdfSnapshotIdentity(
    subjectKind: PdfSubjectKind.profile,
    subjectId: subjectId,
    snapshotDigest: digest,
    engineVersion: 'engine.v1',
    algorithmVersion: 'algorithm.v1',
    dataVersion: 'data.v1',
    calculationManifestId: 'manifest-1',
  );
}

String _hex(String character) => List<String>.filled(64, character).join();
