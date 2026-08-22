import 'professional_pdf_application_service.dart';
import 'pdf_platform_gateway.dart';

enum ProfessionalPdfDeliveryStatus { saved, shared, cancelled, unavailable }

final class ProfessionalPdfDeliveryResult {
  const ProfessionalPdfDeliveryResult({
    required this.status,
    required this.build,
    this.savedUri,
  });

  final ProfessionalPdfDeliveryStatus status;
  final ProfessionalPdfBuildResult build;
  final Uri? savedUri;
}

/// Orchestrates a fully validated professional PDF build with native delivery.
/// User cancellation is a normal outcome and is never reported as an error.
final class ProfessionalPdfDeliveryService<TSnapshot> {
  const ProfessionalPdfDeliveryService({
    required this.applicationService,
    required this.platformGateway,
  });

  final ProfessionalPdfApplicationService<TSnapshot> applicationService;
  final PdfPlatformGateway platformGateway;

  Future<ProfessionalPdfDeliveryResult> save({
    required ProfessionalPdfBuildRequest request,
    required String fileName,
  }) async {
    final build = await applicationService.build(request);
    final uri = await platformGateway.savePdf(
      suggestedFileName: fileName,
      bytes: build.bytes,
    );
    return ProfessionalPdfDeliveryResult(
      status: uri == null
          ? ProfessionalPdfDeliveryStatus.cancelled
          : ProfessionalPdfDeliveryStatus.saved,
      build: build,
      savedUri: uri,
    );
  }

  Future<ProfessionalPdfDeliveryResult> share({
    required ProfessionalPdfBuildRequest request,
    required String fileName,
    String? title,
    String? text,
  }) async {
    final build = await applicationService.build(request);
    final status = await platformGateway.sharePdf(
      fileName: fileName,
      bytes: build.bytes,
      title: title,
      text: text,
    );
    return ProfessionalPdfDeliveryResult(
      status: switch (status) {
        PdfShareStatus.success => ProfessionalPdfDeliveryStatus.shared,
        PdfShareStatus.dismissed => ProfessionalPdfDeliveryStatus.cancelled,
        PdfShareStatus.unavailable => ProfessionalPdfDeliveryStatus.unavailable,
      },
      build: build,
    );
  }
}
