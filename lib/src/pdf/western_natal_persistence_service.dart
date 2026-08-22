import '../data/local/core_model_codecs.dart';
import '../data/local/local_database.dart';
import '../domain/models/core_models.dart';
import 'persisted_western_natal_snapshot.dart';

/// Persists a historical Western natal calculation and its provenance manifest
/// in one LocalDatabase transaction.
///
/// The service deliberately accepts an already-resolved persisted snapshot. It
/// does not recalculate astronomy while saving, and it seals the exact snapshot
/// with SHA-256 before writing the calculation envelope.
final class WesternNatalPersistenceService {
  const WesternNatalPersistenceService({required this.database});

  final LocalDatabase database;

  Future<WesternNatalPersistenceResult> save({
    required String calculationId,
    required String ownerEntityId,
    required CalculationManifest manifest,
    required PersistedWesternNatalSnapshot snapshot,
    required DateTime createdAtUtc,
  }) async {
    final normalizedCalculationId = _requiredId(calculationId, 'calculationId');
    final normalizedOwnerId = _requiredId(ownerEntityId, 'ownerEntityId');
    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(createdAtUtc, 'createdAtUtc', 'Must be UTC.');
    }
    _validateManifestSnapshotParity(manifest, snapshot);

    final envelope = PersistedWesternNatalEnvelope.seal(snapshot);
    final calculationRow = <String, Object?>{
      'id': normalizedCalculationId,
      'ownerEntityId': normalizedOwnerId,
      'manifestId': manifest.id.value,
      'calculationType': persistedWesternNatalCalculationType,
      'payloadJson': envelope.toCalculationResult(),
      'createdAtUtc': createdAtUtc.toIso8601String(),
    };
    final manifestRow = CoreModelCodecs.calculationManifestToMap(manifest);

    await database.transaction<void>((tx) async {
      final existingCalculation = await tx.get(
        table: 'calculations',
        id: normalizedCalculationId,
      );
      if (existingCalculation != null) {
        throw StateError('Calculation ID already exists: $normalizedCalculationId');
      }
      final existingManifest = await tx.get(
        table: 'calculation_manifests',
        id: manifest.id.value,
      );
      if (existingManifest != null) {
        throw StateError('Calculation manifest ID already exists: ${manifest.id.value}');
      }

      await tx.put(
        table: 'calculation_manifests',
        id: manifest.id.value,
        value: manifestRow,
      );
      await tx.put(
        table: 'calculations',
        id: normalizedCalculationId,
        value: calculationRow,
      );
    });

    return WesternNatalPersistenceResult(
      calculationId: normalizedCalculationId,
      manifestId: manifest.id.value,
      snapshotSha256: envelope.snapshotSha256,
    );
  }

  static void _validateManifestSnapshotParity(
    CalculationManifest manifest,
    PersistedWesternNatalSnapshot snapshot,
  ) {
    if (manifest.validity != CalculationValidity.valid &&
        manifest.validity != CalculationValidity.partial) {
      throw ArgumentError.value(
        manifest.validity,
        'manifest.validity',
        'Persisted professional calculations must be valid or partial.',
      );
    }
    if (manifest.engineId != persistedWesternNatalCalculationType) {
      throw StateError('Western natal manifest engineId must be western.natal.');
    }
    if (manifest.engineVersion != snapshot.engineVersion) {
      throw StateError('Manifest/snapshot engineVersion mismatch.');
    }
    if (manifest.algorithmVersion != snapshot.algorithmVersion) {
      throw StateError('Manifest/snapshot algorithmVersion mismatch.');
    }
    if (manifest.dataVersion != snapshot.dataVersion) {
      throw StateError('Manifest/snapshot dataVersion mismatch.');
    }
    if (manifest.zodiacSystemId != 'tropical') {
      throw StateError('Western natal persisted snapshot requires tropical zodiac.');
    }
    final manifestHouse = manifest.houseSystemId?.trim();
    if (manifestHouse == null || manifestHouse.isEmpty) {
      throw StateError('Western natal CalculationManifest must carry houseSystemId.');
    }
    if (manifestHouse.toLowerCase() != snapshot.requestedHouseSystem.toLowerCase()) {
      throw StateError('Manifest/snapshot requested house-system mismatch.');
    }
  }

  static String _requiredId(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be blank.');
    }
    return normalized;
  }
}

final class WesternNatalPersistenceResult {
  const WesternNatalPersistenceResult({
    required this.calculationId,
    required this.manifestId,
    required this.snapshotSha256,
  });

  final String calculationId;
  final String manifestId;
  final String snapshotSha256;
}
