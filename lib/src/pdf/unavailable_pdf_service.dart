import 'pdf_service.dart';

/// Explicit production boundary used while a concrete, approved-font PDF
/// renderer is not yet available for a report type.
///
/// This allows catalog/preview/application wiring to exist without silently
/// pretending that byte rendering is production-ready. Any build attempt fails
/// closed with a stable error.
final class UnavailablePdfService<TSnapshot> implements PdfService<TSnapshot> {
  const UnavailablePdfService(this.reason);

  final String reason;

  @override
  Future<List<int>> buildReport({
    required TSnapshot snapshot,
    required PdfReportOptions options,
  }) {
    throw StateError(reason);
  }
}
