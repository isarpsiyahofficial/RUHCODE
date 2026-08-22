import 'dart:typed_data';

import 'guarded_pdf_service.dart';
import 'pdf_output_inspector.dart';
import 'pdf_service.dart';

abstract interface class ProfessionalPdfSnapshotSource<TSnapshot> {
  Future<TSnapshot?> loadByRecordId(String recordId);
}

final class ProfessionalPdfBuildRequest {
  const ProfessionalPdfBuildRequest({
    required this.recordId,
    required this.localeTag,
    required this.sectionIds,
    this.professionalName,
    this.brandName,
  });

  final String recordId;
  final String localeTag;
  final List<String> sectionIds;
  final String? professionalName;
  final String? brandName;
}

final class ProfessionalPdfBuildResult {
  const ProfessionalPdfBuildResult({
    required this.recordId,
    required this.localeTag,
    required this.sectionIds,
    required this.bytes,
    required this.inspection,
  });

  final String recordId;
  final String localeTag;
  final List<String> sectionIds;
  final Uint8List bytes;
  final PdfOutputInspection inspection;
}

/// Application boundary for producing a professional PDF from one persisted
/// calculation record.
///
/// This layer deliberately performs no calculation itself. It loads the exact
/// selected snapshot, delegates byte generation to the service-layer PRO guard
/// and rejects structurally unusable PDF output before UI/share code can see it.
final class ProfessionalPdfApplicationService<TSnapshot> {
  const ProfessionalPdfApplicationService({
    required this.snapshotSource,
    required this.pdfService,
    this.outputInspector = const PdfOutputInspector(),
  });

  final ProfessionalPdfSnapshotSource<TSnapshot> snapshotSource;
  final GuardedProfessionalPdfService<TSnapshot> pdfService;
  final PdfOutputInspector outputInspector;

  Future<ProfessionalPdfBuildResult> build(
    ProfessionalPdfBuildRequest request,
  ) async {
    final recordId = request.recordId.trim();
    if (recordId.isEmpty) {
      throw const FormatException('Professional PDF requires a record ID.');
    }

    final localeTag = request.localeTag.trim();
    final languageCode = localeTag.split(RegExp('[-_]')).first.toLowerCase();
    if (languageCode != 'tr' && languageCode != 'en') {
      throw FormatException('Unsupported PDF locale: $localeTag');
    }

    final sectionIds = <String>[];
    final seen = <String>{};
    for (final raw in request.sectionIds) {
      final sectionId = raw.trim();
      if (sectionId.isEmpty) {
        throw const FormatException('PDF section IDs must not be empty.');
      }
      if (!seen.add(sectionId)) {
        throw FormatException('Duplicate PDF section ID: $sectionId');
      }
      sectionIds.add(sectionId);
    }
    if (sectionIds.isEmpty) {
      throw const FormatException('Professional PDF requires at least one section.');
    }

    final snapshot = await snapshotSource.loadByRecordId(recordId);
    if (snapshot == null) {
      throw StateError('Calculation record not found: $recordId');
    }

    final bytes = Uint8List.fromList(
      await pdfService.buildReport(
        snapshot: snapshot,
        options: PdfReportOptions(
          localeTag: localeTag,
          sectionIds: List<String>.unmodifiable(sectionIds),
          professionalName: request.professionalName,
          brandName: request.brandName,
        ),
      ),
    );
    final inspection = outputInspector.requireUsable(bytes);

    return ProfessionalPdfBuildResult(
      recordId: recordId,
      localeTag: localeTag,
      sectionIds: List<String>.unmodifiable(sectionIds),
      bytes: bytes,
      inspection: inspection,
    );
  }
}
