import '../entitlements/feature_access_guard.dart';
import '../entitlements/feature_catalog.dart';
import 'pdf_service.dart';

/// Service-layer entitlement boundary for professional PDF generation.
///
/// Route/UI checks are useful for UX, but they are not a security boundary.
/// Every real professional PDF build must pass through the same canonical
/// EntitlementService via FeatureAccessGuard.runService().
final class GuardedProfessionalPdfService<TSnapshot>
    implements PdfService<TSnapshot> {
  const GuardedProfessionalPdfService({
    required this.featureAccess,
    required this.delegate,
  });

  final FeatureAccessGuard featureAccess;
  final PdfService<TSnapshot> delegate;

  @override
  Future<List<int>> buildReport({
    required TSnapshot snapshot,
    required PdfReportOptions options,
  }) {
    return featureAccess.runService<List<int>>(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      action: () => delegate.buildReport(
        snapshot: snapshot,
        options: options,
      ),
    );
  }
}
