import 'pdf_local_renderer.dart';
import 'pdf_numerology_data.dart';
import 'pdf_report_contract.dart';

/// Converts canonical numerology PDF data into the same [PdfRenderSection]
/// consumed by [PdfLocalRenderer]. No numerology value is recalculated here.
/// Human-readable labels are supplied by localization and are not stored in
/// calculation data.
abstract final class PdfNumerologySectionAdapter {
  static PdfRenderSection build({
    required PdfNumerologyPayload payload,
    required String title,
    required String metricHeader,
    required String valueHeader,
    required String Function(String metricId) labelForMetric,
  }) {
    if (title.trim().isEmpty || metricHeader.trim().isEmpty || valueHeader.trim().isEmpty) {
      throw const FormatException('Numerology PDF table labels cannot be blank.');
    }

    final seen = <String>{};
    final rows = <List<String>>[
      <String>[metricHeader, valueHeader],
    ];
    for (final metric in payload.metricRows) {
      if (metric.metricId.trim().isEmpty || !seen.add(metric.metricId)) {
        throw const FormatException('Numerology PDF metric IDs must be non-blank and unique.');
      }
      final label = labelForMetric(metric.metricId).trim();
      if (label.isEmpty) {
        throw FormatException('Missing localized PDF label for ${metric.metricId}.');
      }
      rows.add(<String>[label, metric.value]);
    }

    final sectionRef = payload.dataset.sections.where(
      (section) => section.sectionId == PdfSectionIds.numerology,
    );
    if (sectionRef.length != 1) {
      throw const StateError('Numerology PDF dataset must contain exactly one numerology section.');
    }
    if (sectionRef.single.snapshotDigest != payload.snapshotDigest) {
      throw const StateError('Numerology PDF section digest drift detected.');
    }

    return PdfRenderSection(
      sectionId: PdfSectionIds.numerology,
      snapshotDigest: payload.snapshotDigest,
      title: title,
      paragraphs: const <String>[],
      rows: List<List<String>>.unmodifiable(
        rows.map((row) => List<String>.unmodifiable(row)),
      ),
    );
  }
}
