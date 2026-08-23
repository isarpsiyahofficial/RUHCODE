import 'pdf_report_contract.dart';

/// User-visible preflight preview derived from the exact report plan that will
/// later be rendered. It never invents sections and never renders PDF bytes.
///
/// This keeps "preview before create" separate from the demo/sample PDF: a
/// professional report preview must describe the selected persisted record's
/// planned report structure before byte generation begins.
final class PdfPreflightPreview {
  const PdfPreflightPreview({
    required this.kind,
    required this.localeTag,
    required this.coverStyle,
    required this.sectionIds,
    required this.pageSpec,
    required this.hasBranding,
  });

  final PdfReportKind kind;
  final String localeTag;
  final PdfCoverStyle coverStyle;
  final List<String> sectionIds;
  final PdfPageSpec pageSpec;
  final bool hasBranding;
}

final class PdfPreflightPreviewBuilder {
  const PdfPreflightPreviewBuilder();

  PdfPreflightPreview fromPlan(PdfReportPlan plan) {
    if (plan.sectionIds.isEmpty) {
      throw const FormatException('PDF preview cannot be built from an empty report plan.');
    }
    if (plan.sectionIds.toSet().length != plan.sectionIds.length) {
      throw const FormatException('PDF preview cannot contain duplicate section ids.');
    }
    for (final id in plan.sectionIds) {
      if (!PdfSectionIds.all.contains(id)) {
        throw FormatException('PDF preview contains an unknown section id: $id.');
      }
    }
    if (!plan.pageSpec.widthMm.isFinite ||
        !plan.pageSpec.heightMm.isFinite ||
        plan.pageSpec.widthMm <= 0 ||
        plan.pageSpec.heightMm <= 0) {
      throw const FormatException('PDF preview page dimensions are invalid.');
    }
    return PdfPreflightPreview(
      kind: plan.kind,
      localeTag: plan.localeTag,
      coverStyle: plan.coverStyle,
      sectionIds: List<String>.unmodifiable(plan.sectionIds),
      pageSpec: plan.pageSpec,
      hasBranding: plan.branding.hasAny,
    );
  }
}
