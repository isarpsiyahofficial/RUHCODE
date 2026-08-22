import '../../pdf/persisted_calculation_pdf_source.dart';
import '../../pdf/professional_pdf_application_service.dart';
import '../../pdf/professional_pdf_delivery_service.dart';

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

enum ProfessionalPdfUiDeliveryOutcome {
  success,
  cancelled,
  unavailable,
}

final class ProfessionalPdfUiDeliveryResult {
  const ProfessionalPdfUiDeliveryResult({
    required this.outcome,
    this.savedUri,
  });

  final ProfessionalPdfUiDeliveryOutcome outcome;
  final Uri? savedUri;
}

abstract interface class ProfessionalPdfBuildActions {
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  });
}

abstract interface class ProfessionalPdfDeliveryActions {
  Future<ProfessionalPdfUiDeliveryResult> save({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  });

  Future<ProfessionalPdfUiDeliveryResult> share({
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

/// Narrow one-time composition bridge for persisted professional PDF actions.
///
/// Production can bind only the pieces that are actually ready. Widgets still
/// accept explicit actions in tests. Duplicate production binding is rejected
/// so a later screen cannot silently replace the trusted source/service.
final class ProfessionalPdfUiRuntimeBindings {
  ProfessionalPdfUiRuntimeBindings._();

  static ProfessionalPdfRecordActions? _records;
  static ProfessionalPdfBuildActions? _build;
  static ProfessionalPdfDeliveryActions? _delivery;

  static ProfessionalPdfRecordActions? get records => _records;
  static ProfessionalPdfBuildActions? get build => _build;
  static ProfessionalPdfDeliveryActions? get delivery => _delivery;

  static void bindRecords(ProfessionalPdfRecordActions records) {
    if (_records != null) {
      throw StateError('Professional PDF record actions are already bound.');
    }
    _records = records;
  }

  static void bindBuild(ProfessionalPdfBuildActions build) {
    if (_build != null) {
      throw StateError('Professional PDF build actions are already bound.');
    }
    _build = build;
  }

  static void bindDelivery(ProfessionalPdfDeliveryActions delivery) {
    if (_delivery != null) {
      throw StateError('Professional PDF delivery actions are already bound.');
    }
    _delivery = delivery;
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

/// Bridges verified PDF generation + native OS delivery to UI-safe outcomes.
/// Cancellation is a normal outcome, not an exception. The adapter never
/// bypasses the ProfessionalPdfApplicationService or its entitlement guard.
final class ProfessionalPdfDeliveryUiActions<TSnapshot>
    implements ProfessionalPdfDeliveryActions {
  const ProfessionalPdfDeliveryUiActions({required this.service});

  final ProfessionalPdfDeliveryService<TSnapshot> service;

  @override
  Future<ProfessionalPdfUiDeliveryResult> save({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    final result = await service.save(
      ProfessionalPdfBuildRequest(
        recordId: recordId,
        localeTag: localeTag,
        sectionIds: sectionIds,
      ),
      fileName: _fileName(recordId),
    );
    return switch (result.status) {
      ProfessionalPdfDeliveryStatus.saved => ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.success,
          savedUri: result.savedUri,
        ),
      ProfessionalPdfDeliveryStatus.cancelled => const ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.cancelled,
        ),
      _ => const ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.unavailable,
        ),
    };
  }

  @override
  Future<ProfessionalPdfUiDeliveryResult> share({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    final result = await service.share(
      ProfessionalPdfBuildRequest(
        recordId: recordId,
        localeTag: localeTag,
        sectionIds: sectionIds,
      ),
      fileName: _fileName(recordId),
      title: 'Ruh Code PDF Raporu',
    );
    return switch (result.status) {
      ProfessionalPdfDeliveryStatus.shared => const ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.success,
        ),
      ProfessionalPdfDeliveryStatus.cancelled => const ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.cancelled,
        ),
      _ => const ProfessionalPdfUiDeliveryResult(
          outcome: ProfessionalPdfUiDeliveryOutcome.unavailable,
        ),
    };
  }

  static String _fileName(String recordId) {
    final safe = recordId.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-');
    if (safe.isEmpty) {
      throw const FormatException('Professional PDF record ID cannot be empty.');
    }
    return 'ruh-code-$safe.pdf';
  }
}
