enum RecordKind { user, profile, client, consultation, calculation, note, journal, tarotSession }

enum BirthTimePrecision { unknown, approximate, exact }

final class OpaqueLocalId {
  OpaqueLocalId(this.value) {
    final v = value.trim();
    if (v.length < 8 || v.contains(RegExp(r'\s'))) {
      throw ArgumentError('Local IDs must be opaque, non-empty and non-display-name identifiers');
    }
  }

  final String value;

  @override
  bool operator ==(Object other) => other is OpaqueLocalId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class RecordMetadata {
  RecordMetadata({required this.id, required this.kind, required this.createdAt, required this.updatedAt}) {
    if (!createdAt.isUtc || !updatedAt.isUtc) {
      throw ArgumentError('Record timestamps must preserve timezone by using UTC instants');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt cannot precede createdAt');
    }
  }

  final OpaqueLocalId id;
  final RecordKind kind;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class BirthPlace {
  BirthPlace({
    required this.countryCode,
    required this.cityName,
    required this.displayText,
    required this.latitude,
    required this.longitude,
    required this.ianaTimezoneId,
  }) {
    if (countryCode.trim().length != 2 || cityName.trim().isEmpty || displayText.trim().isEmpty) {
      throw ArgumentError('Birth place requires country, city and display text');
    }
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      throw ArgumentError('Invalid birth coordinates');
    }
    if (!ianaTimezoneId.contains('/')) throw ArgumentError('IANA timezone id required');
  }

  final String countryCode;
  final String cityName;
  final String displayText;
  final double latitude;
  final double longitude;
  final String ianaTimezoneId;
}

final class BirthData {
  BirthData({
    required this.birthDate,
    required this.timePrecision,
    required this.birthPlace,
    this.localBirthDateTime,
  }) {
    if (birthDate.isUtc) throw ArgumentError('Birth date is a civil date, not a UTC record timestamp');
    if (timePrecision == BirthTimePrecision.unknown && localBirthDateTime != null) {
      throw ArgumentError('Unknown birth time must not invent 00:00 or any other time');
    }
    if (timePrecision != BirthTimePrecision.unknown && localBirthDateTime == null) {
      throw ArgumentError('Approximate/exact birth time requires an explicit local date-time');
    }
  }

  final DateTime birthDate;
  final BirthTimePrecision timePrecision;
  final DateTime? localBirthDateTime;
  final BirthPlace birthPlace;
}

final class CalculationManifestRecord {
  CalculationManifestRecord({
    required this.engineVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.timezoneDatabaseVersion,
    required this.houseSystem,
    required this.zodiacSystem,
    required this.nodeMode,
    required this.latitude,
    required this.longitude,
    required this.utcDateTime,
    required this.localDateTimeIso,
    required Map<String, String> professionalSettings,
    this.ayanamsha,
  }) : professionalSettings = Map.unmodifiable(professionalSettings) {
    final requiredText = [engineVersion, algorithmVersion, dataVersion, timezoneDatabaseVersion, houseSystem, zodiacSystem, nodeMode, localDateTimeIso];
    if (requiredText.any((v) => v.trim().isEmpty) || !utcDateTime.isUtc) {
      throw ArgumentError('Calculation manifest requires complete reproducibility metadata');
    }
    if (zodiacSystem.toLowerCase() == 'sidereal' && (ayanamsha == null || ayanamsha!.trim().isEmpty)) {
      throw ArgumentError('Sidereal manifest requires ayanamsha');
    }
  }

  final String engineVersion;
  final String algorithmVersion;
  final String dataVersion;
  final String timezoneDatabaseVersion;
  final String houseSystem;
  final String zodiacSystem;
  final String? ayanamsha;
  final String nodeMode;
  final double latitude;
  final double longitude;
  final DateTime utcDateTime;
  final String localDateTimeIso;
  final Map<String, String> professionalSettings;
}

final class SavedCalculationRecord {
  SavedCalculationRecord({required this.meta, required this.profileId, required this.manifest, required this.payloadRef}) {
    if (meta.kind != RecordKind.calculation || payloadRef.trim().isEmpty) {
      throw ArgumentError('Saved calculation requires calculation metadata and payload reference');
    }
  }

  final RecordMetadata meta;
  final OpaqueLocalId profileId;
  final CalculationManifestRecord manifest;
  final String payloadRef;
}

final class RecalculationComparison {
  const RecalculationComparison({required this.original, required this.recalculated});

  final SavedCalculationRecord original;
  final SavedCalculationRecord recalculated;

  bool get engineChanged => original.manifest.engineVersion != recalculated.manifest.engineVersion;
}

final class DataEnvelope {
  DataEnvelope({
    required this.schemaVersion,
    required this.appVersion,
    required this.engineVersion,
    required this.exportedAt,
    required this.languageCode,
    required this.platform,
    required Map<String, Object?> payload,
  }) : payload = Map.unmodifiable(payload) {
    if (schemaVersion < 1 || [appVersion, engineVersion, languageCode, platform].any((v) => v.trim().isEmpty) || !exportedAt.isUtc) {
      throw ArgumentError('Versioned data envelope metadata is incomplete');
    }
  }

  final int schemaVersion;
  final String appVersion;
  final String engineVersion;
  final DateTime exportedAt;
  final String languageCode;
  final String platform;
  final Map<String, Object?> payload;

  DataEnvelope copyWith({required int schemaVersion, required Map<String, Object?> payload}) => DataEnvelope(
        schemaVersion: schemaVersion,
        appVersion: appVersion,
        engineVersion: engineVersion,
        exportedAt: exportedAt,
        languageCode: languageCode,
        platform: platform,
        payload: payload,
      );
}

typedef MigrationStep = DataEnvelope Function(DataEnvelope source);

final class CopyFirstMigrationEngine {
  CopyFirstMigrationEngine({required this.latestSchemaVersion, required Map<int, MigrationStep> steps}) : steps = Map.unmodifiable(steps);

  final int latestSchemaVersion;
  final Map<int, MigrationStep> steps;

  DataEnvelope migrate(DataEnvelope original) {
    var working = DataEnvelope(
      schemaVersion: original.schemaVersion,
      appVersion: original.appVersion,
      engineVersion: original.engineVersion,
      exportedAt: original.exportedAt,
      languageCode: original.languageCode,
      platform: original.platform,
      payload: Map<String, Object?>.from(original.payload),
    );
    while (working.schemaVersion < latestSchemaVersion) {
      final step = steps[working.schemaVersion];
      if (step == null) throw StateError('Missing migration step from schema ${working.schemaVersion}');
      final next = step(working);
      if (next.schemaVersion != working.schemaVersion + 1) {
        throw StateError('Migration must advance exactly one schema version');
      }
      working = next;
    }
    return working;
  }
}
