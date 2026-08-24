import 'combined_professional_pdf_application_service.dart';
import 'pdf_platform_gateway.dart';

enum CombinedPdfDeliveryStatus {
  saved,
  shared,
  cancelled,
  unavailable,
}

final class CombinedPdfDeliveryResult {
  const CombinedPdfDeliveryResult({
    required this.status,
    this.savedUri,
  });

  final CombinedPdfDeliveryStatus status;
  final Uri? savedUri;
}

/// Native delivery boundary for a sealed combined-PDF preview token.
///
/// The exact preview token is passed back to the application service before
/// every Save As/share operation, so native delivery cannot bypass persisted
/// snapshot/system/section drift validation.
final class CombinedProfessionalPdfDeliveryService {
  const CombinedProfessionalPdfDeliveryService({
    required this.application,
    required this.platform,
  });

  final CombinedProfessionalPdfApplicationService application;
  final PdfPlatformGateway platform;

  Future<CombinedPdfDeliveryResult> save({
    required CombinedProfessionalPdfPreview preview,
    required String fileName,
  }) async {
    final bytes = await application.buildFromPreview(preview: preview);
    final uri = await platform.savePdf(
      suggestedFileName: fileName,
      bytes: bytes,
    );
    if (uri == null) {
      return const CombinedPdfDeliveryResult(
        status: CombinedPdfDeliveryStatus.cancelled,
      );
    }
    return CombinedPdfDeliveryResult(
      status: CombinedPdfDeliveryStatus.saved,
      savedUri: uri,
    );
  }

  Future<CombinedPdfDeliveryResult> share({
    required CombinedProfessionalPdfPreview preview,
    required String fileName,
    String? title,
    String? text,
  }) async {
    final bytes = await application.buildFromPreview(preview: preview);
    final status = await platform.sharePdf(
      fileName: fileName,
      bytes: bytes,
      title: title,
      text: text,
    );
    return switch (status) {
      PdfShareStatus.success => const CombinedPdfDeliveryResult(
          status: CombinedPdfDeliveryStatus.shared,
        ),
      PdfShareStatus.dismissed => const CombinedPdfDeliveryResult(
          status: CombinedPdfDeliveryStatus.cancelled,
        ),
      PdfShareStatus.unavailable => const CombinedPdfDeliveryResult(
          status: CombinedPdfDeliveryStatus.unavailable,
        ),
    };
  }
}
