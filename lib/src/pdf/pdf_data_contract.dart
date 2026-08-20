import 'pdf_report_contract.dart';

enum PdfSubjectKind { profile, client, demo }

final class PdfSnapshotIdentity {
  const PdfSnapshotIdentity({
    required this.subjectKind,
    required this.subjectId,
    required this.snapshotDigest,
    required this.engineVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    this.calculationManifestId,
  });

  final PdfSubjectKind subjectKind;
  final String subjectId;
  final String snapshotDigest;
  final String engineVersion;
  final String algorithmVersion;
  final String dataVersion;
  final String? calculationManifestId;

  void validate() {
    final required = <String>[
      subjectId,
      snapshotDigest,
      engineVersion,
      algorithmVersion,
      dataVersion,
    ];
    if (required.any((value) => value.trim().isEmpty)) {
      throw const FormatException('PDF snapshot identity contains an empty required field.');
    }
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(snapshotDigest)) {
      throw const FormatException('PDF snapshot digest must be lowercase SHA-256 hex.');
    }
    final manifest = calculationManifestId;
    if (manifest != null && manifest.trim().isEmpty) {
      throw const FormatException('PDF calculation manifest id cannot be blank.');
    }
  }
}

final class PdfSectionDataRef {
  const PdfSectionDataRef({
    required this.sectionId,
    required this.snapshotDigest,
    required this.hasContent,
  });

  final String sectionId;
  final String snapshotDigest;
  final bool hasContent;
}

final class PdfReportDataset {
  const PdfReportDataset({
    required this.origin,
    required this.identity,
    required this.sections,
  });

  final PdfDataOrigin origin;
  final PdfSnapshotIdentity identity;
  final List<PdfSectionDataRef> sections;
}

final class PdfReportDataValidator {
  const PdfReportDataValidator();

  List<PdfSectionInput> validateAndProject(PdfReportDataset dataset) {
    dataset.identity.validate();

    if (dataset.origin == PdfDataOrigin.demo && dataset.identity.subjectKind != PdfSubjectKind.demo) {
      throw const FormatException('Demo PDF origin requires a demo subject identity.');
    }
    if (dataset.origin == PdfDataOrigin.user && dataset.identity.subjectKind == PdfSubjectKind.demo) {
      throw const FormatException('User PDF origin cannot use a demo subject identity.');
    }

    final seen = <String>{};
    final projected = <PdfSectionInput>[];
    for (final section in dataset.sections) {
      if (!PdfSectionIds.all.contains(section.sectionId)) {
        throw FormatException('Unknown PDF section data id: ${section.sectionId}.');
      }
      if (!seen.add(section.sectionId)) {
        throw FormatException('Duplicate PDF section data id: ${section.sectionId}.');
      }
      if (section.snapshotDigest != dataset.identity.snapshotDigest) {
        throw FormatException(
          'PDF section ${section.sectionId} does not belong to the report snapshot.',
        );
      }
      projected.add(
        PdfSectionInput(id: section.sectionId, hasContent: section.hasContent),
      );
    }
    return List.unmodifiable(projected);
  }

  void requireUiPdfSnapshotParity({
    required String uiSnapshotDigest,
    required PdfSnapshotIdentity pdfIdentity,
  }) {
    pdfIdentity.validate();
    if (uiSnapshotDigest != pdfIdentity.snapshotDigest) {
      throw const FormatException('UI and PDF calculation snapshots do not match.');
    }
  }
}
