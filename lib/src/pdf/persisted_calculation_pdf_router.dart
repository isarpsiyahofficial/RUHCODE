import 'pdf_service.dart';
import 'persisted_calculation_pdf_source.dart';

final class PersistedCalculationPdfHandler {
  PersistedCalculationPdfHandler({
    required String calculationType,
    required this.service,
  }) : calculationType = _validateType(calculationType);

  final String calculationType;
  final PdfService<PersistedCalculationPdfSnapshot> service;

  static String _validateType(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('PDF calculation handler type cannot be blank.');
    }
    return trimmed;
  }
}

/// Exact calculation-type router for persisted professional PDF snapshots.
///
/// A calculation type must have one explicit handler. Unknown types fail closed
/// and duplicate registrations are rejected at construction time. The router
/// never attempts to reinterpret one calculation payload as another system.
final class PersistedCalculationPdfRouter
    implements PdfService<PersistedCalculationPdfSnapshot> {
  PersistedCalculationPdfRouter({
    required Iterable<PersistedCalculationPdfHandler> handlers,
  }) : _handlers = _buildHandlers(handlers);

  final Map<String, PdfService<PersistedCalculationPdfSnapshot>> _handlers;

  Set<String> get supportedCalculationTypes =>
      Set<String>.unmodifiable(_handlers.keys);

  @override
  Future<List<int>> buildReport({
    required PersistedCalculationPdfSnapshot snapshot,
    required PdfReportOptions options,
  }) {
    final type = snapshot.calculationType.trim();
    final service = _handlers[type];
    if (service == null) {
      throw UnsupportedError(
        'No professional PDF handler is registered for calculation type: $type',
      );
    }
    return service.buildReport(snapshot: snapshot, options: options);
  }

  static Map<String, PdfService<PersistedCalculationPdfSnapshot>> _buildHandlers(
    Iterable<PersistedCalculationPdfHandler> handlers,
  ) {
    final result = <String, PdfService<PersistedCalculationPdfSnapshot>>{};
    for (final handler in handlers) {
      if (result.containsKey(handler.calculationType)) {
        throw StateError(
          'Duplicate professional PDF handler: ${handler.calculationType}',
        );
      }
      result[handler.calculationType] = handler.service;
    }
    if (result.isEmpty) {
      throw const FormatException(
        'At least one persisted calculation PDF handler is required.',
      );
    }
    return Map<String, PdfService<PersistedCalculationPdfSnapshot>>.unmodifiable(
      result,
    );
  }
}
