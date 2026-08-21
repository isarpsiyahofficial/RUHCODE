import '../calculation_core/numerology/pythagorean_snapshot.dart';
import '../calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';
import 'pdf_data_contract.dart';
import 'pdf_report_contract.dart';

final class PdfNumerologyMetricRow {
  const PdfNumerologyMetricRow({
    required this.metricId,
    required this.value,
  });

  final String metricId;
  final String value;
}

final class PdfNumerologyPayload {
  const PdfNumerologyPayload({
    required this.dataset,
    required this.snapshotDigest,
    required this.metricRows,
  });

  final PdfReportDataset dataset;
  final String snapshotDigest;
  final List<PdfNumerologyMetricRow> metricRows;
}

/// Projects the canonical Pythagorean snapshot into PDF-safe data without
/// recalculating numerology values. The same SHA-256 identity can also be used
/// by the UI so PDF/UI parity is verifiable through PdfReportDataValidator.
abstract final class PdfNumerologyDataAdapter {
  static const String dataVersion = 'numerology-pdf-data-v1';

  static PdfNumerologyPayload fromSnapshot({
    required PythagoreanNumerologySnapshot snapshot,
    required PdfDataOrigin origin,
    required PdfSubjectKind subjectKind,
    required String subjectId,
    String? calculationManifestId,
  }) {
    if (origin == PdfDataOrigin.demo && subjectKind != PdfSubjectKind.demo) {
      throw const FormatException('Demo numerology PDF requires demo subject kind.');
    }
    if (origin == PdfDataOrigin.user && subjectKind == PdfSubjectKind.demo) {
      throw const FormatException('User numerology PDF cannot use demo subject kind.');
    }
    if (subjectId.trim().isEmpty) {
      throw const FormatException('Numerology PDF subjectId cannot be blank.');
    }

    final digest = PythagoreanSnapshotFingerprint.sha256Hex(snapshot);
    final profile = snapshot.profile;
    final extended = snapshot.extendedName;
    final cycles = snapshot.personalCycles;

    final rows = <PdfNumerologyMetricRow>[
      PdfNumerologyMetricRow(metricId: 'life_path', value: '${profile.lifePath}'),
      PdfNumerologyMetricRow(metricId: 'expression', value: '${profile.expression}'),
      PdfNumerologyMetricRow(metricId: 'soul_urge', value: '${profile.soulUrge}'),
      PdfNumerologyMetricRow(metricId: 'personality', value: '${profile.personality}'),
      PdfNumerologyMetricRow(metricId: 'birthday', value: '${profile.birthday}'),
      PdfNumerologyMetricRow(metricId: 'maturity', value: '${profile.maturity}'),
      PdfNumerologyMetricRow(metricId: 'balance', value: '${extended.balance}'),
      PdfNumerologyMetricRow(
        metricId: 'karmic_lessons',
        value: extended.karmicLessons.join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'hidden_passions',
        value: extended.hiddenPassions.join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'pinnacles',
        value: snapshot.pinnaclesChallenges.pinnacles.join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'challenges',
        value: snapshot.pinnaclesChallenges.challenges.join(','),
      ),
      if (cycles != null) ...<PdfNumerologyMetricRow>[
        PdfNumerologyMetricRow(
          metricId: 'personal_year',
          value: '${cycles.personalYear}',
        ),
        PdfNumerologyMetricRow(
          metricId: 'personal_month',
          value: '${cycles.personalMonth}',
        ),
        PdfNumerologyMetricRow(
          metricId: 'personal_day',
          value: '${cycles.personalDay}',
        ),
      ],
    ];

    final identity = PdfSnapshotIdentity(
      subjectKind: subjectKind,
      subjectId: subjectId,
      snapshotDigest: digest,
      engineVersion: PythagoreanNumerologySnapshotEngine.engineVersion,
      algorithmVersion: PythagoreanSnapshotFingerprint.schemaVersion,
      dataVersion: dataVersion,
      calculationManifestId: calculationManifestId,
    );

    final dataset = PdfReportDataset(
      origin: origin,
      identity: identity,
      sections: <PdfSectionDataRef>[
        PdfSectionDataRef(
          sectionId: PdfSectionIds.numerology,
          snapshotDigest: digest,
          hasContent: rows.isNotEmpty,
        ),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.technicalManifest,
          snapshotDigest: digest,
          hasContent: true,
        ),
      ],
    );

    // Validate here so an invalid origin/subject/snapshot combination cannot be
    // handed to the renderer by another application layer.
    const PdfReportDataValidator().validateAndProject(dataset);

    return PdfNumerologyPayload(
      dataset: dataset,
      snapshotDigest: digest,
      metricRows: List<PdfNumerologyMetricRow>.unmodifiable(rows),
    );
  }
}
