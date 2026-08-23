import 'pdf_data_contract.dart';
import 'pdf_western_chart_geometry.dart';
import 'persisted_calculation_pdf_source.dart';
import 'persisted_western_natal_snapshot.dart';

/// Verified Western natal payload ready for PDF/UI projection.
///
/// This layer refuses to recalculate a historical chart. It only accepts the
/// versioned snapshot already stored in Calculation.result and proves that its
/// engine/algorithm/data provenance agrees with the linked CalculationManifest.
final class PersistedWesternNatalPdfData {
  const PersistedWesternNatalPdfData({
    required this.recordId,
    required this.ownerEntityId,
    required this.subjectKind,
    required this.snapshotSha256,
    required this.snapshot,
    required this.geometry,
  });

  final String recordId;
  final String ownerEntityId;
  final PdfSubjectKind subjectKind;
  final String snapshotSha256;
  final PersistedWesternNatalSnapshot snapshot;
  final PdfWesternChartGeometry geometry;
}

abstract final class PersistedWesternNatalPdfReader {
  static PersistedWesternNatalPdfData read(PersistedCalculationPdfSnapshot persisted) {
    if (persisted.calculationType != persistedWesternNatalCalculationType) {
      throw FormatException(
        'Expected $persistedWesternNatalCalculationType calculation, got ${persisted.calculationType}.',
      );
    }

    final envelope = PersistedWesternNatalEnvelope.fromCalculationResult(
      Map<String, dynamic>.from(persisted.payload),
    );
    final snapshot = envelope.snapshot;
    final manifest = persisted.manifest;

    if (manifest.engineVersion != snapshot.engineVersion) {
      throw StateError(
        'Western snapshot engine version does not match CalculationManifest.',
      );
    }
    if (manifest.algorithmVersion != snapshot.algorithmVersion) {
      throw StateError(
        'Western snapshot algorithm version does not match CalculationManifest.',
      );
    }
    if (manifest.dataVersion != snapshot.dataVersion) {
      throw StateError(
        'Western snapshot data version does not match CalculationManifest.',
      );
    }

    return PersistedWesternNatalPdfData(
      recordId: persisted.recordId,
      ownerEntityId: persisted.ownerEntityId,
      subjectKind: _subjectKind(persisted.payload['subjectKind']),
      snapshotSha256: envelope.snapshotSha256,
      snapshot: snapshot,
      geometry: PdfWesternChartGeometryAdapter.fromPersistedSnapshot(snapshot),
    );
  }

  static PdfSubjectKind _subjectKind(Object? raw) {
    // Schema-v1 Western rows created before explicit subject-kind persistence
    // represented only personal profiles. Preserve those exact rows without
    // inventing client ownership. New client rows must carry subjectKind.
    if (raw == null) return PdfSubjectKind.profile;
    if (raw == 'profile') return PdfSubjectKind.profile;
    if (raw == 'client') return PdfSubjectKind.client;
    throw const FormatException(
      'Persisted Western subjectKind must be profile or client.',
    );
  }
}
