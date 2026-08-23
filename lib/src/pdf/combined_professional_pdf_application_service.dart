import '../entitlements/feature_access_guard.dart';
import '../entitlements/feature_catalog.dart';
import 'pdf_combined_report.dart';
import 'pdf_data_contract.dart';
import 'pdf_service.dart';
import 'persisted_calculation_pdf_source.dart';
import 'persisted_combined_pdf_projection.dart';
import 'persisted_pythagorean_numerology_pdf.dart';
import 'persisted_western_natal_pdf.dart';
import 'persisted_western_natal_snapshot.dart';

/// Immutable preflight token for a true multi-record professional PDF.
///
/// Build must reload the exact persisted record set and prove that the
/// composite digest, subject, locale, systems and selected section order are
/// still identical. This prevents a preview for one set of records from being
/// used to build another set after the database changes.
final class CombinedProfessionalPdfPreview {
  const CombinedProfessionalPdfPreview({
    required this.recordIds,
    required this.localeTag,
    required this.subjectKind,
    required this.subjectId,
    required this.compositeSnapshotDigest,
    required this.memberSystemIds,
    required this.sectionIds,
  });

  final List<String> recordIds;
  final String localeTag;
  final PdfSubjectKind subjectKind;
  final String subjectId;
  final String compositeSnapshotDigest;
  final List<String> memberSystemIds;
  final List<String> sectionIds;
}

final class CombinedPdfRecordChoice {
  const CombinedPdfRecordChoice({
    required this.recordId,
    required this.ownerEntityId,
    required this.subjectKind,
    required this.calculationType,
    required this.createdAtUtc,
  });

  final String recordId;
  final String ownerEntityId;
  final PdfSubjectKind subjectKind;
  final String calculationType;
  final DateTime createdAtUtc;
}

/// Application boundary for combined professional reports.
///
/// - catalog results are filtered to one exact subject kind + stable ID;
/// - preview and build both use the canonical PRO service guard;
/// - preview seals the exact persisted record set and selected sections;
/// - build reloads persisted records and rejects any digest/system/subject drift;
/// - no astronomy or numerology is recalculated in this layer.
final class CombinedProfessionalPdfApplicationService {
  const CombinedProfessionalPdfApplicationService({
    required this.featureAccess,
    required this.recordCatalog,
    required this.snapshotSource,
    required this.projectionSource,
    required this.pdfService,
  });

  final FeatureAccessGuard featureAccess;
  final ProfessionalPdfRecordCatalog recordCatalog;
  final ProfessionalPdfSnapshotSource<PersistedCalculationPdfSnapshot>
      snapshotSource;
  final PersistedCombinedPdfProjectionSource projectionSource;
  final PdfService<PdfCombinedReportProjection> pdfService;

  static const supportedCalculationTypes = <String>{
    persistedWesternNatalCalculationType,
    PersistedPythagoreanNumerologyPdfContract.calculationType,
  };

  Future<List<CombinedPdfRecordChoice>> listCandidates({
    required PdfSubjectKind subjectKind,
    required String subjectId,
  }) {
    return featureAccess.runService<List<CombinedPdfRecordChoice>>(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      action: () async {
        final normalizedSubjectId = _requiredId(subjectId, 'subjectId');
        final summaries = await recordCatalog.listAvailableRecords();
        final choices = <CombinedPdfRecordChoice>[];
        for (final summary in summaries) {
          if (summary.ownerEntityId != normalizedSubjectId ||
              !supportedCalculationTypes.contains(summary.calculationType)) {
            continue;
          }
          final snapshot = await snapshotSource.loadByRecordId(summary.recordId);
          if (snapshot == null) continue;
          final resolvedKind = _subjectKind(snapshot);
          if (resolvedKind != subjectKind) continue;
          choices.add(
            CombinedPdfRecordChoice(
              recordId: summary.recordId,
              ownerEntityId: summary.ownerEntityId,
              subjectKind: resolvedKind,
              calculationType: summary.calculationType,
              createdAtUtc: summary.createdAtUtc,
            ),
          );
        }
        choices.sort((a, b) {
          final byDate = b.createdAtUtc.compareTo(a.createdAtUtc);
          return byDate != 0 ? byDate : a.recordId.compareTo(b.recordId);
        });
        return List<CombinedPdfRecordChoice>.unmodifiable(choices);
      },
    );
  }

  Future<CombinedProfessionalPdfPreview> preview({
    required Iterable<String> recordIds,
    required String localeTag,
    required Iterable<String> requestedSectionIds,
  }) {
    return featureAccess.runService<CombinedProfessionalPdfPreview>(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      action: () async {
        final ids = _normalizeRecordIds(recordIds);
        final locale = _locale(localeTag);
        final projection = await projectionSource.load(
          recordIds: ids,
          localeTag: locale,
        );
        final sections = _selectSections(
          projection: projection,
          requestedSectionIds: requestedSectionIds,
        );
        final identity = projection.dataset.identity;
        return CombinedProfessionalPdfPreview(
          recordIds: List<String>.unmodifiable(ids),
          localeTag: locale,
          subjectKind: identity.subjectKind,
          subjectId: identity.subjectId,
          compositeSnapshotDigest: identity.snapshotDigest,
          memberSystemIds:
              List<String>.unmodifiable(projection.memberSystemIds),
          sectionIds: List<String>.unmodifiable(sections),
        );
      },
    );
  }

  Future<List<int>> buildFromPreview({
    required CombinedProfessionalPdfPreview preview,
    String? professionalName,
    String? brandName,
  }) {
    return featureAccess.runService<List<int>>(
      featureId: RuhFeatureIds.pdfProfessionalExport,
      action: () async {
        final projection = await projectionSource.load(
          recordIds: preview.recordIds,
          localeTag: preview.localeTag,
        );
        final identity = projection.dataset.identity;
        if (identity.subjectKind != preview.subjectKind ||
            identity.subjectId != preview.subjectId ||
            identity.snapshotDigest != preview.compositeSnapshotDigest) {
          throw const StateError(
            'Combined PDF preview/build persisted snapshot drift detected.',
          );
        }
        if (!_sameStrings(projection.memberSystemIds, preview.memberSystemIds)) {
          throw const StateError('Combined PDF preview/build system drift detected.');
        }
        final selected = _selectSections(
          projection: projection,
          requestedSectionIds: preview.sectionIds,
        );
        if (!_sameStrings(selected, preview.sectionIds)) {
          throw const StateError('Combined PDF preview/build section drift detected.');
        }
        return pdfService.buildReport(
          snapshot: projection,
          options: PdfReportOptions(
            localeTag: preview.localeTag,
            sectionIds: preview.sectionIds,
            professionalName: professionalName,
            brandName: brandName,
          ),
        );
      },
    );
  }

  static PdfSubjectKind _subjectKind(PersistedCalculationPdfSnapshot snapshot) {
    if (snapshot.calculationType == persistedWesternNatalCalculationType) {
      return PersistedWesternNatalPdfReader.read(snapshot).subjectKind;
    }
    if (snapshot.calculationType ==
        PersistedPythagoreanNumerologyPdfContract.calculationType) {
      final raw = snapshot.payload[
        PersistedPythagoreanNumerologyPdfContract.subjectKindKey
      ];
      if (raw == 'profile') return PdfSubjectKind.profile;
      if (raw == 'client') return PdfSubjectKind.client;
      throw const FormatException(
        'Persisted numerology subjectKind must be profile or client.',
      );
    }
    throw FormatException(
      'Unsupported combined PDF calculation type: ${snapshot.calculationType}',
    );
  }

  static List<String> _normalizeRecordIds(Iterable<String> values) {
    final result = <String>[];
    final seen = <String>{};
    for (final raw in values) {
      final value = _requiredId(raw, 'recordId');
      if (!seen.add(value)) {
        throw FormatException('Duplicate combined PDF record ID: $value');
      }
      result.add(value);
    }
    if (result.length < 2) {
      throw const FormatException(
        'Combined PDF requires at least two persisted calculation records.',
      );
    }
    return result;
  }

  static List<String> _selectSections({
    required PdfCombinedReportProjection projection,
    required Iterable<String> requestedSectionIds,
  }) {
    final available = <String>{
      for (final section in projection.sections) section.sectionId,
    };
    final requested = <String>{};
    for (final raw in requestedSectionIds) {
      final id = _requiredId(raw, 'sectionId');
      if (!requested.add(id)) {
        throw FormatException('Duplicate combined PDF section ID: $id');
      }
      if (!available.contains(id)) {
        throw FormatException('Unavailable combined PDF section ID: $id');
      }
    }
    if (requested.isEmpty) {
      throw const FormatException('Combined PDF preview requires content sections.');
    }
    // Cover is a structural part of every professional combined report. The
    // normalized preview token includes it explicitly so build parity is exact.
    requested.add(PdfSectionIds.cover);
    final ordered = <String>[
      for (final section in projection.sections)
        if (requested.contains(section.sectionId)) section.sectionId,
    ];
    if (ordered.where((id) => id != PdfSectionIds.cover).isEmpty) {
      throw const FormatException('Combined PDF has no selected content section.');
    }
    return ordered;
  }

  static String _locale(String raw) {
    final value = raw.trim().split(RegExp('[-_]')).first.toLowerCase();
    if (value != 'tr' && value != 'en') {
      throw FormatException('Unsupported combined PDF locale: $raw');
    }
    return value;
  }

  static String _requiredId(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be blank.');
    }
    return normalized;
  }

  static bool _sameStrings(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
