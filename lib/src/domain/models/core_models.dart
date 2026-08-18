import '../ids/entity_id.dart';

enum BirthTimeKnowledge { exact, approximate, unknown }
enum CalculationValidity { valid, partial, unavailable, error }
enum EntitlementTier { free, pro, temporary }

final class LocationRecord {
  const LocationRecord({required this.label, required this.countryCode, required this.latitude, required this.longitude, required this.ianaTimeZoneId});
  final String label;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String ianaTimeZoneId;
}

final class BirthData {
  const BirthData({required this.localDateIso, required this.timeKnowledge, required this.location, this.localTime});
  final String localDateIso;
  final BirthTimeKnowledge timeKnowledge;
  final String? localTime;
  final LocationRecord location;
}

final class Profile {
  const Profile({required this.id, required this.displayName, required this.birthData, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final String displayName;
  final BirthData birthData;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class Client {
  const Client({required this.id, required this.displayName, required this.createdAtUtc, required this.updatedAtUtc, this.birthData, this.tags = const <String>[]});
  final EntityId id;
  final String displayName;
  final BirthData? birthData;
  final List<String> tags;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class CalculationManifest {
  const CalculationManifest({required this.id, required this.engineId, required this.engineVersion, required this.algorithmVersion, required this.dataVersion, required this.localDateTime, required this.utcDateTime, required this.location, required this.validity, this.timezoneDatabaseVersion, this.houseSystemId, this.zodiacSystemId, this.ayanamshaId, this.nodeModeId});
  final EntityId id;
  final String engineId;
  final String engineVersion;
  final String algorithmVersion;
  final String dataVersion;
  final String? timezoneDatabaseVersion;
  final DateTime localDateTime;
  final DateTime utcDateTime;
  final LocationRecord location;
  final CalculationValidity validity;
  final String? houseSystemId;
  final String? zodiacSystemId;
  final String? ayanamshaId;
  final String? nodeModeId;
}

final class Consultation {
  const Consultation({required this.id, required this.clientId, required this.startedAtUtc, required this.createdAtUtc, required this.updatedAtUtc, this.endedAtUtc});
  final EntityId id;
  final EntityId clientId;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class Note {
  const Note({required this.id, required this.ownerEntityId, required this.text, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final EntityId ownerEntityId;
  final String text;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class JournalEntry {
  const JournalEntry({required this.id, required this.profileId, required this.localDateIso, required this.text, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final EntityId profileId;
  final String localDateIso;
  final String text;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class Goal {
  const Goal({required this.id, required this.profileId, required this.title, required this.createdAtUtc, required this.updatedAtUtc, this.completed = false});
  final EntityId id;
  final EntityId profileId;
  final String title;
  final bool completed;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class Habit {
  const Habit({required this.id, required this.profileId, required this.title, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final EntityId profileId;
  final String title;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class TarotSession {
  const TarotSession({required this.id, required this.createdAtUtc, required this.updatedAtUtc, this.clientId, this.spreadId, this.cardIds = const <String>[]});
  final EntityId id;
  final EntityId? clientId;
  final String? spreadId;
  final List<String> cardIds;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class ProfessionalPreset {
  const ProfessionalPreset({required this.id, required this.name, required this.systemId, required this.settings, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final String name;
  final String systemId;
  final Map<String, String> settings;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class InterpretationTemplate {
  const InterpretationTemplate({required this.id, required this.systemId, required this.ruleId, required this.localeTag, required this.text, required this.createdAtUtc, required this.updatedAtUtc});
  final EntityId id;
  final String systemId;
  final String ruleId;
  final String localeTag;
  final String text;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

final class FeatureEntitlement {
  const FeatureEntitlement({required this.featureId, required this.tier, this.validUntilUtc});
  final String featureId;
  final EntitlementTier tier;
  final DateTime? validUntilUtc;
}

final class BackupManifest {
  const BackupManifest({required this.schemaVersion, required this.appVersion, required this.engineVersion, required this.exportedAtUtc, required this.localeTag, required this.recordCounts, required this.checksums});
  final int schemaVersion;
  final String appVersion;
  final String engineVersion;
  final DateTime exportedAtUtc;
  final String localeTag;
  final Map<String, int> recordCounts;
  final Map<String, String> checksums;
}
