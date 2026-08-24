import '../../pdf/combined_professional_pdf_application_service.dart';
import '../../pdf/combined_professional_pdf_delivery_service.dart';
import '../../pdf/pdf_data_contract.dart';
import '../../pdf/persisted_calculation_pdf_source.dart';

final class CombinedPdfUiSubject {
  const CombinedPdfUiSubject({
    required this.subjectKind,
    required this.subjectId,
    required this.availableRecordCount,
  });

  final PdfSubjectKind subjectKind;
  final String subjectId;
  final int availableRecordCount;
}

final class CombinedPdfUiRecord {
  const CombinedPdfUiRecord({
    required this.recordId,
    required this.calculationType,
    required this.createdAtUtc,
  });

  final String recordId;
  final String calculationType;
  final DateTime createdAtUtc;
}

final class CombinedPdfUiPreview {
  const CombinedPdfUiPreview({required this.value});

  final CombinedProfessionalPdfPreview value;

  List<String> get recordIds => value.recordIds;
  String get localeTag => value.localeTag;
  PdfSubjectKind get subjectKind => value.subjectKind;
  String get subjectId => value.subjectId;
  String get compositeSnapshotDigest => value.compositeSnapshotDigest;
  List<String> get memberSystemIds => value.memberSystemIds;
  List<String> get sectionIds => value.sectionIds;
}

abstract interface class CombinedProfessionalPdfUiActions {
  Future<List<CombinedPdfUiSubject>> listSubjects();

  Future<List<CombinedPdfUiRecord>> listCandidates({
    required PdfSubjectKind subjectKind,
    required String subjectId,
  });

  Future<CombinedPdfUiPreview> preview({
    required List<String> recordIds,
    required String localeTag,
    required List<String> sectionIds,
  });

  Future<List<int>> build({required CombinedPdfUiPreview preview});
}

/// UI-safe bridge for true multi-record professional PDF reports.
///
/// Subject discovery intentionally reuses [CombinedProfessionalPdfApplicationService]
/// for subject-kind resolution. It never duplicates Western/Numerology parsing in
/// widgets and it only exposes subjects that have at least two eligible persisted
/// calculations.
final class CombinedProfessionalPdfApplicationActions
    implements CombinedProfessionalPdfUiActions {
  const CombinedProfessionalPdfApplicationActions({
    required this.service,
    required this.catalog,
  });

  final CombinedProfessionalPdfApplicationService service;
  final ProfessionalPdfRecordCatalog catalog;

  @override
  Future<List<CombinedPdfUiSubject>> listSubjects() async {
    final summaries = await catalog.listAvailableRecords();
    final ownerIds = summaries.map((item) => item.ownerEntityId).toSet().toList()
      ..sort();
    final subjects = <CombinedPdfUiSubject>[];
    for (final ownerId in ownerIds) {
      for (final kind in PdfSubjectKind.values) {
        final candidates = await service.listCandidates(
          subjectKind: kind,
          subjectId: ownerId,
        );
        if (candidates.length < 2) continue;
        subjects.add(
          CombinedPdfUiSubject(
            subjectKind: kind,
            subjectId: ownerId,
            availableRecordCount: candidates.length,
          ),
        );
      }
    }
    subjects.sort((a, b) {
      final kind = a.subjectKind.name.compareTo(b.subjectKind.name);
      return kind != 0 ? kind : a.subjectId.compareTo(b.subjectId);
    });
    return List<CombinedPdfUiSubject>.unmodifiable(subjects);
  }

  @override
  Future<List<CombinedPdfUiRecord>> listCandidates({
    required PdfSubjectKind subjectKind,
    required String subjectId,
  }) async {
    final candidates = await service.listCandidates(
      subjectKind: subjectKind,
      subjectId: subjectId,
    );
    return List<CombinedPdfUiRecord>.unmodifiable(
      candidates.map(
        (item) => CombinedPdfUiRecord(
          recordId: item.recordId,
          calculationType: item.calculationType,
          createdAtUtc: item.createdAtUtc,
        ),
      ),
    );
  }

  @override
  Future<CombinedPdfUiPreview> preview({
    required List<String> recordIds,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    final preview = await service.preview(
      recordIds: recordIds,
      localeTag: localeTag,
      requestedSectionIds: sectionIds,
    );
    return CombinedPdfUiPreview(value: preview);
  }

  @override
  Future<List<int>> build({required CombinedPdfUiPreview preview}) {
    return service.buildFromPreview(preview: preview.value);
  }
}

enum CombinedPdfUiDeliveryOutcome {
  saved,
  shared,
  cancelled,
  unavailable,
}

final class CombinedPdfUiDeliveryResult {
  const CombinedPdfUiDeliveryResult({
    required this.outcome,
    this.savedUri,
  });

  final CombinedPdfUiDeliveryOutcome outcome;
  final Uri? savedUri;
}

abstract interface class CombinedProfessionalPdfDeliveryActions {
  Future<CombinedPdfUiDeliveryResult> save({
    required CombinedPdfUiPreview preview,
    required String fileName,
  });

  Future<CombinedPdfUiDeliveryResult> share({
    required CombinedPdfUiPreview preview,
    required String fileName,
  });
}

/// UI bridge for native delivery. Every call forwards the exact sealed preview
/// back to [CombinedProfessionalPdfDeliveryService], so Save As/share cannot
/// bypass preview/build persisted-snapshot drift validation.
final class CombinedProfessionalPdfDeliveryApplicationActions
    implements CombinedProfessionalPdfDeliveryActions {
  const CombinedProfessionalPdfDeliveryApplicationActions({required this.service});

  final CombinedProfessionalPdfDeliveryService service;

  @override
  Future<CombinedPdfUiDeliveryResult> save({
    required CombinedPdfUiPreview preview,
    required String fileName,
  }) async {
    final result = await service.save(preview: preview.value, fileName: fileName);
    return CombinedPdfUiDeliveryResult(
      outcome: switch (result.status) {
        CombinedPdfDeliveryStatus.saved => CombinedPdfUiDeliveryOutcome.saved,
        CombinedPdfDeliveryStatus.shared => CombinedPdfUiDeliveryOutcome.shared,
        CombinedPdfDeliveryStatus.cancelled => CombinedPdfUiDeliveryOutcome.cancelled,
        CombinedPdfDeliveryStatus.unavailable => CombinedPdfUiDeliveryOutcome.unavailable,
      },
      savedUri: result.savedUri,
    );
  }

  @override
  Future<CombinedPdfUiDeliveryResult> share({
    required CombinedPdfUiPreview preview,
    required String fileName,
  }) async {
    final result = await service.share(preview: preview.value, fileName: fileName);
    return CombinedPdfUiDeliveryResult(
      outcome: switch (result.status) {
        CombinedPdfDeliveryStatus.saved => CombinedPdfUiDeliveryOutcome.saved,
        CombinedPdfDeliveryStatus.shared => CombinedPdfUiDeliveryOutcome.shared,
        CombinedPdfDeliveryStatus.cancelled => CombinedPdfUiDeliveryOutcome.cancelled,
        CombinedPdfDeliveryStatus.unavailable => CombinedPdfUiDeliveryOutcome.unavailable,
      },
      savedUri: result.savedUri,
    );
  }
}

/// One-time production binding for combined-report UI surfaces.
final class CombinedProfessionalPdfUiRuntimeBindings {
  CombinedProfessionalPdfUiRuntimeBindings._();

  static CombinedProfessionalPdfUiActions? _actions;
  static CombinedProfessionalPdfDeliveryActions? _delivery;

  static CombinedProfessionalPdfUiActions? get actions => _actions;
  static CombinedProfessionalPdfDeliveryActions? get delivery => _delivery;

  static void bind(CombinedProfessionalPdfUiActions actions) {
    if (_actions != null) {
      throw StateError('Combined professional PDF UI actions are already bound.');
    }
    _actions = actions;
  }

  static void bindDelivery(CombinedProfessionalPdfDeliveryActions delivery) {
    if (_delivery != null) {
      throw StateError('Combined professional PDF delivery actions are already bound.');
    }
    _delivery = delivery;
  }
}
