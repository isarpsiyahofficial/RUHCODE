import '../../pdf/professional_pdf_application_service.dart';

final class ProfessionalPdfUiBuildResult {
  const ProfessionalPdfUiBuildResult({
    required this.byteLength,
    required this.pageCount,
  });

  final int byteLength;
  final int pageCount;
}

abstract interface class ProfessionalPdfBuildActions {
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  });
}

/// Bridges the generic professional PDF application service to Flutter UI
/// without exposing calculation snapshot types to widgets.
final class ProfessionalPdfApplicationActions<TSnapshot>
    implements ProfessionalPdfBuildActions {
  const ProfessionalPdfApplicationActions({required this.service});

  final ProfessionalPdfApplicationService<TSnapshot> service;

  @override
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    final result = await service.build(
      ProfessionalPdfBuildRequest(
        recordId: recordId,
        localeTag: localeTag,
        sectionIds: sectionIds,
      ),
    );
    return ProfessionalPdfUiBuildResult(
      byteLength: result.bytes.length,
      pageCount: result.inspection.pageObjectCount,
    );
  }
}
