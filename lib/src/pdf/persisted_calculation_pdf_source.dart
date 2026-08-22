import '../data/local/core_model_codecs.dart';
import '../data/local/local_database.dart';
import '../domain/models/core_models.dart';
import 'professional_pdf_application_service.dart';

/// Exact persisted calculation envelope used by professional PDF application
/// code. It carries the stored payload and the CalculationManifest that proves
/// which engine/data/timezone configuration produced it.
final class PersistedCalculationPdfSnapshot {
  const PersistedCalculationPdfSnapshot({
    required this.recordId,
    required this.ownerEntityId,
    required this.calculationType,
    required this.payload,
    required this.createdAtUtc,
    required this.manifest,
  });

  final String recordId;
  final String ownerEntityId;
  final String calculationType;
  final Map<String, Object?> payload;
  final DateTime createdAtUtc;
  final CalculationManifest manifest;
}

final class PersistedCalculationPdfSummary {
  const PersistedCalculationPdfSummary({
    required this.recordId,
    required this.ownerEntityId,
    required this.calculationType,
    required this.createdAtUtc,
    required this.validity,
  });

  final String recordId;
  final String ownerEntityId;
  final String calculationType;
  final DateTime createdAtUtc;
  final CalculationValidity validity;
}

abstract interface class ProfessionalPdfRecordCatalog {
  Future<List<PersistedCalculationPdfSummary>> listAvailableRecords();
}

/// Production LocalDatabase adapter for professional PDF snapshot loading.
///
/// Calculation row and manifest are read in the same transaction so PDF code
/// cannot observe a calculation paired with a manifest from another database
/// state. Corrupt rows fail closed instead of being silently projected.
final class LocalDatabaseProfessionalPdfSnapshotSource
    implements
        ProfessionalPdfSnapshotSource<PersistedCalculationPdfSnapshot>,
        ProfessionalPdfRecordCatalog {
  const LocalDatabaseProfessionalPdfSnapshotSource({required this.database});

  final LocalDatabase database;

  @override
  Future<PersistedCalculationPdfSnapshot?> loadByRecordId(String recordId) {
    final id = recordId.trim();
    if (id.isEmpty) {
      throw const FormatException('Calculation record ID must not be blank.');
    }
    return database.transaction<PersistedCalculationPdfSnapshot?>((tx) async {
      final raw = await tx.get(table: 'calculations', id: id);
      if (raw == null) return null;
      return _decode(tx, id, raw);
    });
  }

  @override
  Future<List<PersistedCalculationPdfSummary>> listAvailableRecords() {
    return database.transaction<List<PersistedCalculationPdfSummary>>((tx) async {
      final rows = await tx.readTable('calculations');
      final ids = rows.keys.toList()..sort();
      final result = <PersistedCalculationPdfSummary>[];
      for (final id in ids) {
        final snapshot = await _decode(tx, id, rows[id]!);
        result.add(
          PersistedCalculationPdfSummary(
            recordId: snapshot.recordId,
            ownerEntityId: snapshot.ownerEntityId,
            calculationType: snapshot.calculationType,
            createdAtUtc: snapshot.createdAtUtc,
            validity: snapshot.manifest.validity,
          ),
        );
      }
      result.sort((a, b) {
        final date = b.createdAtUtc.compareTo(a.createdAtUtc);
        return date != 0 ? date : a.recordId.compareTo(b.recordId);
      });
      return List<PersistedCalculationPdfSummary>.unmodifiable(result);
    });
  }

  Future<PersistedCalculationPdfSnapshot> _decode(
    LocalDatabaseTransaction tx,
    String storageId,
    Map<String, Object?> raw,
  ) async {
    final payloadId = _requiredString(raw, 'id');
    if (payloadId != storageId) {
      throw StateError(
        'Calculation storage/payload ID mismatch: $storageId != $payloadId.',
      );
    }
    final manifestId = _requiredString(raw, 'manifestId');
    final ownerEntityId = _requiredString(raw, 'ownerEntityId');
    final calculationType = _requiredString(raw, 'calculationType');
    final payload = _requiredMap(raw, 'payloadJson');
    final createdAtUtc = _requiredUtc(raw, 'createdAtUtc');

    final manifestRaw = await tx.get(
      table: 'calculation_manifests',
      id: manifestId,
    );
    if (manifestRaw == null) {
      throw StateError('Calculation manifest not found: $manifestId');
    }
    final manifest = CoreModelCodecs.calculationManifestFromMap(manifestRaw);
    if (manifest.id.value != manifestId) {
      throw StateError('Calculation manifest ID mismatch: $manifestId.');
    }
    if (manifest.validity == CalculationValidity.error ||
        manifest.validity == CalculationValidity.unavailable) {
      throw StateError(
        'Professional PDF cannot use ${manifest.validity.name} calculation: $storageId.',
      );
    }

    return PersistedCalculationPdfSnapshot(
      recordId: storageId,
      ownerEntityId: ownerEntityId,
      calculationType: calculationType,
      payload: Map<String, Object?>.unmodifiable(payload),
      createdAtUtc: createdAtUtc,
      manifest: manifest,
    );
  }

  static String _requiredString(Map<String, Object?> raw, String key) {
    final value = raw[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Calculation field $key must be a non-empty string.');
    }
    return value;
  }

  static Map<String, Object?> _requiredMap(
    Map<String, Object?> raw,
    String key,
  ) {
    final value = raw[key];
    if (value is! Map) {
      throw FormatException('Calculation field $key must be a JSON object.');
    }
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static DateTime _requiredUtc(Map<String, Object?> raw, String key) {
    final value = raw[key];
    if (value is! String) {
      throw FormatException('Calculation field $key must be an ISO timestamp.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw FormatException('Calculation field $key must be UTC.');
    }
    return parsed;
  }
}
