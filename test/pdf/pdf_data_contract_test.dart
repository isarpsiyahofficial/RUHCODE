import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

const digestA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const digestB = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

void main() {
  const validator = PdfReportDataValidator();

  PdfSnapshotIdentity identity({
    PdfSubjectKind kind = PdfSubjectKind.client,
    String subjectId = 'client-1',
    String digest = digestA,
  }) => PdfSnapshotIdentity(
        subjectKind: kind,
        subjectId: subjectId,
        snapshotDigest: digest,
        engineVersion: 'engine-1',
        algorithmVersion: 'western-1',
        dataVersion: 'ephemeris-1',
        calculationManifestId: kind == PdfSubjectKind.demo ? null : 'manifest-1',
      );

  test('all report sections must belong to the same exact snapshot', () {
    final projected = validator.validateAndProject(
      PdfReportDataset(
        origin: PdfDataOrigin.user,
        identity: identity(),
        sections: const [
          PdfSectionDataRef(
            sectionId: PdfSectionIds.chart,
            snapshotDigest: digestA,
            hasContent: true,
          ),
          PdfSectionDataRef(
            sectionId: PdfSectionIds.interpretation,
            snapshotDigest: digestA,
            hasContent: true,
          ),
        ],
      ),
    );

    expect(projected.map((section) => section.id), [PdfSectionIds.chart, PdfSectionIds.interpretation]);
  });

  test('section from another snapshot is rejected before rendering', () {
    expect(
      () => validator.validateAndProject(
        PdfReportDataset(
          origin: PdfDataOrigin.user,
          identity: identity(),
          sections: const [
            PdfSectionDataRef(
              sectionId: PdfSectionIds.chart,
              snapshotDigest: digestB,
              hasContent: true,
            ),
          ],
        ),
      ),
      throwsFormatException,
    );
  });

  test('demo origin cannot be mislabeled as a real client and vice versa', () {
    expect(
      () => validator.validateAndProject(
        PdfReportDataset(
          origin: PdfDataOrigin.demo,
          identity: identity(kind: PdfSubjectKind.client),
          sections: const [],
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => validator.validateAndProject(
        PdfReportDataset(
          origin: PdfDataOrigin.user,
          identity: identity(kind: PdfSubjectKind.demo, subjectId: 'demo'),
          sections: const [],
        ),
      ),
      throwsFormatException,
    );
  });

  test('UI and PDF must use the exact same calculation snapshot digest', () {
    expect(
      () => validator.requireUiPdfSnapshotParity(
        uiSnapshotDigest: digestA,
        pdfIdentity: identity(),
      ),
      returnsNormally,
    );
    expect(
      () => validator.requireUiPdfSnapshotParity(
        uiSnapshotDigest: digestB,
        pdfIdentity: identity(),
      ),
      throwsFormatException,
    );
  });

  test('strong UI PDF parity requires subject kind id and snapshot digest', () {
    expect(
      () => validator.requireUiPdfSubjectAndSnapshotParity(
        uiSubjectKind: PdfSubjectKind.client,
        uiSubjectId: 'client-1',
        uiSnapshotDigest: digestA,
        pdfIdentity: identity(),
      ),
      returnsNormally,
    );

    expect(
      () => validator.requireUiPdfSubjectAndSnapshotParity(
        uiSubjectKind: PdfSubjectKind.client,
        uiSubjectId: 'client-2',
        uiSnapshotDigest: digestA,
        pdfIdentity: identity(),
      ),
      throwsFormatException,
    );

    expect(
      () => validator.requireUiPdfSubjectAndSnapshotParity(
        uiSubjectKind: PdfSubjectKind.profile,
        uiSubjectId: 'client-1',
        uiSnapshotDigest: digestA,
        pdfIdentity: identity(),
      ),
      throwsFormatException,
    );

    expect(
      () => validator.requireUiPdfSubjectAndSnapshotParity(
        uiSubjectKind: PdfSubjectKind.client,
        uiSubjectId: 'client-1',
        uiSnapshotDigest: digestB,
        pdfIdentity: identity(),
      ),
      throwsFormatException,
    );
  });

  test('strong UI PDF parity rejects blank UI subject id', () {
    expect(
      () => validator.requireUiPdfSubjectAndSnapshotParity(
        uiSubjectKind: PdfSubjectKind.client,
        uiSubjectId: '   ',
        uiSnapshotDigest: digestA,
        pdfIdentity: identity(),
      ),
      throwsFormatException,
    );
  });

  test('snapshot digest must be a real lowercase SHA-256-shaped value', () {
    expect(
      () => identity(digest: 'not-a-sha').validate(),
      throwsFormatException,
    );
  });
}
