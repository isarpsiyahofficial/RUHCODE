import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_report_contract.dart';

/// Minimal local-renderer cover payload tied to the exact calculation snapshot.
///
/// The renderer uses the report document title and branding for visual cover
/// content. This adapter exists so the cover participates in the same strict
/// section availability/digest contract as every other selected PDF section.
abstract final class PdfCoverSectionAdapter {
  static PdfSectionDataRef dataRef({required String snapshotDigest}) {
    return PdfSectionDataRef(
      sectionId: PdfSectionIds.cover,
      snapshotDigest: snapshotDigest,
      hasContent: true,
    );
  }

  static PdfRenderSection build({
    required String snapshotDigest,
    required String title,
  }) {
    if (title.trim().isEmpty) {
      throw const FormatException('PDF cover section title cannot be blank.');
    }
    return PdfRenderSection(
      sectionId: PdfSectionIds.cover,
      snapshotDigest: snapshotDigest,
      title: title.trim(),
      paragraphs: const <String>[],
    );
  }
}
