import '../../pdf/persisted_calculation_pdf_source.dart';
import '../../pdf/professional_pdf_application_service.dart';

final class ProfessionalPdfUiBuildResult {
  const ProfessionalPdfUiBuildResult({
    required this.byteLength,
    required this.pageCount,
  });

  final int byteLength;
  final int pageCount;
}

final class ProfessionalPdfUiRecord {
  const ProfessionalPdfUiRecord({
    required this.recordId,
    required this.ownerEntityId,
    required this.calculationType,
    required this.createdAtUtc,
  });

  final String recordId;
  final String ownerEntityId;
  final String calculationType;
  final DateTime createdAtUtc;
}

abstract interface class ProfessionalPdfBuildActions {
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  });
}

abstract interface class ProfessionalPdfRecordActions {
  Future<List<ProfessionalPdfUiRecord>> listRecords();
}

/// Projects the production persisted-calculation catalog into UI-safe typed
/// rows. Widgets never need to know LocalDatabase or CalculationManifest types.
final class ProfessionalPdfCatalogActions implements ProfessionalPdfRecordActions {
  const ProfessionalPdfCatalogActions({required this.catalog});

  final ProfessionalPdfRecordCatalog catalog;

  @override
  Future<List<ProfessionalPdfUiRecord>> listRecords() async {
    final records = await catalog.listAvailableRecords();
    return List<ProfessionalPdfUiRecord>.unmodifiable(
      records.map(
        (record) => ProfessionalPdfUiRecord(
          recordId: record.recordId,
          ownerEntityId: record.ownerEntityId,
          calculationType: record.calculationType,
          createdAtUtc: record.createdAtUtc,
        ),
      ),
    );
  }
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
