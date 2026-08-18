import '../../domain/ids/entity_id.dart';
import '../../domain/models/core_models.dart';

typedef JsonMap = Map<String, Object?>;

final class CoreModelCodecs {
  const CoreModelCodecs._();

  static JsonMap locationToMap(LocationRecord value) => <String, Object?>{
        'label': value.label,
        'countryCode': value.countryCode,
        'latitude': value.latitude,
        'longitude': value.longitude,
        'ianaTimeZoneId': value.ianaTimeZoneId,
      };

  static LocationRecord locationFromMap(JsonMap map) => LocationRecord(
        label: map['label']! as String,
        countryCode: map['countryCode']! as String,
        latitude: (map['latitude']! as num).toDouble(),
        longitude: (map['longitude']! as num).toDouble(),
        ianaTimeZoneId: map['ianaTimeZoneId']! as String,
      );

  static JsonMap birthDataToMap(BirthData value) => <String, Object?>{
        'localDateIso': value.localDateIso,
        'timeKnowledge': value.timeKnowledge.name,
        'localTime': value.localTime,
        'location': locationToMap(value.location),
      };

  static BirthData birthDataFromMap(JsonMap map) => BirthData(
        localDateIso: map['localDateIso']! as String,
        timeKnowledge: BirthTimeKnowledge.values.byName(map['timeKnowledge']! as String),
        localTime: map['localTime'] as String?,
        location: locationFromMap(_map(map['location'])),
      );

  static JsonMap profileToMap(Profile value) => <String, Object?>{
        'id': value.id.value,
        'displayName': value.displayName,
        'birthData': birthDataToMap(value.birthData),
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Profile profileFromMap(JsonMap map) => Profile(
        id: EntityId.parse(map['id']! as String),
        displayName: map['displayName']! as String,
        birthData: birthDataFromMap(_map(map['birthData'])),
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap clientToMap(Client value) => <String, Object?>{
        'id': value.id.value,
        'displayName': value.displayName,
        'birthData': value.birthData == null ? null : birthDataToMap(value.birthData!),
        'tags': value.tags,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Client clientFromMap(JsonMap map) => Client(
        id: EntityId.parse(map['id']! as String),
        displayName: map['displayName']! as String,
        birthData: map['birthData'] == null ? null : birthDataFromMap(_map(map['birthData'])),
        tags: _stringList(map['tags']),
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap calculationManifestToMap(CalculationManifest value) => <String, Object?>{
        'id': value.id.value,
        'engineId': value.engineId,
        'engineVersion': value.engineVersion,
        'algorithmVersion': value.algorithmVersion,
        'dataVersion': value.dataVersion,
        'timezoneDatabaseVersion': value.timezoneDatabaseVersion,
        'localDateTime': value.localDateTime.toIso8601String(),
        'utcDateTime': _utc(value.utcDateTime),
        'location': locationToMap(value.location),
        'validity': value.validity.name,
        'houseSystemId': value.houseSystemId,
        'zodiacSystemId': value.zodiacSystemId,
        'ayanamshaId': value.ayanamshaId,
        'nodeModeId': value.nodeModeId,
      };

  static CalculationManifest calculationManifestFromMap(JsonMap map) => CalculationManifest(
        id: EntityId.parse(map['id']! as String),
        engineId: map['engineId']! as String,
        engineVersion: map['engineVersion']! as String,
        algorithmVersion: map['algorithmVersion']! as String,
        dataVersion: map['dataVersion']! as String,
        timezoneDatabaseVersion: map['timezoneDatabaseVersion'] as String?,
        localDateTime: DateTime.parse(map['localDateTime']! as String),
        utcDateTime: _date(map['utcDateTime']),
        location: locationFromMap(_map(map['location'])),
        validity: CalculationValidity.values.byName(map['validity']! as String),
        houseSystemId: map['houseSystemId'] as String?,
        zodiacSystemId: map['zodiacSystemId'] as String?,
        ayanamshaId: map['ayanamshaId'] as String?,
        nodeModeId: map['nodeModeId'] as String?,
      );

  static JsonMap consultationToMap(Consultation value) => <String, Object?>{
        'id': value.id.value,
        'clientId': value.clientId.value,
        'startedAtUtc': _utc(value.startedAtUtc),
        'endedAtUtc': value.endedAtUtc == null ? null : _utc(value.endedAtUtc!),
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Consultation consultationFromMap(JsonMap map) => Consultation(
        id: EntityId.parse(map['id']! as String),
        clientId: EntityId.parse(map['clientId']! as String),
        startedAtUtc: _date(map['startedAtUtc']),
        endedAtUtc: map['endedAtUtc'] == null ? null : _date(map['endedAtUtc']),
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap noteToMap(Note value) => <String, Object?>{
        'id': value.id.value,
        'ownerEntityId': value.ownerEntityId.value,
        'text': value.text,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Note noteFromMap(JsonMap map) => Note(
        id: EntityId.parse(map['id']! as String),
        ownerEntityId: EntityId.parse(map['ownerEntityId']! as String),
        text: map['text']! as String,
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap journalEntryToMap(JournalEntry value) => <String, Object?>{
        'id': value.id.value,
        'profileId': value.profileId.value,
        'localDateIso': value.localDateIso,
        'text': value.text,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static JournalEntry journalEntryFromMap(JsonMap map) => JournalEntry(
        id: EntityId.parse(map['id']! as String),
        profileId: EntityId.parse(map['profileId']! as String),
        localDateIso: map['localDateIso']! as String,
        text: map['text']! as String,
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap goalToMap(Goal value) => <String, Object?>{
        'id': value.id.value,
        'profileId': value.profileId.value,
        'title': value.title,
        'completed': value.completed,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Goal goalFromMap(JsonMap map) => Goal(
        id: EntityId.parse(map['id']! as String),
        profileId: EntityId.parse(map['profileId']! as String),
        title: map['title']! as String,
        completed: map['completed']! as bool,
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap habitToMap(Habit value) => <String, Object?>{
        'id': value.id.value,
        'profileId': value.profileId.value,
        'title': value.title,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static Habit habitFromMap(JsonMap map) => Habit(
        id: EntityId.parse(map['id']! as String),
        profileId: EntityId.parse(map['profileId']! as String),
        title: map['title']! as String,
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap tarotSessionToMap(TarotSession value) => <String, Object?>{
        'id': value.id.value,
        'clientId': value.clientId?.value,
        'spreadId': value.spreadId,
        'cardIds': value.cardIds,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static TarotSession tarotSessionFromMap(JsonMap map) => TarotSession(
        id: EntityId.parse(map['id']! as String),
        clientId: map['clientId'] == null ? null : EntityId.parse(map['clientId']! as String),
        spreadId: map['spreadId'] as String?,
        cardIds: _stringList(map['cardIds']),
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap professionalPresetToMap(ProfessionalPreset value) => <String, Object?>{
        'id': value.id.value,
        'name': value.name,
        'systemId': value.systemId,
        'settings': value.settings,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static ProfessionalPreset professionalPresetFromMap(JsonMap map) => ProfessionalPreset(
        id: EntityId.parse(map['id']! as String),
        name: map['name']! as String,
        systemId: map['systemId']! as String,
        settings: _stringMap(map['settings']),
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap interpretationTemplateToMap(InterpretationTemplate value) => <String, Object?>{
        'id': value.id.value,
        'systemId': value.systemId,
        'ruleId': value.ruleId,
        'localeTag': value.localeTag,
        'text': value.text,
        'createdAtUtc': _utc(value.createdAtUtc),
        'updatedAtUtc': _utc(value.updatedAtUtc),
      };

  static InterpretationTemplate interpretationTemplateFromMap(JsonMap map) => InterpretationTemplate(
        id: EntityId.parse(map['id']! as String),
        systemId: map['systemId']! as String,
        ruleId: map['ruleId']! as String,
        localeTag: map['localeTag']! as String,
        text: map['text']! as String,
        createdAtUtc: _date(map['createdAtUtc']),
        updatedAtUtc: _date(map['updatedAtUtc']),
      );

  static JsonMap featureEntitlementToMap(FeatureEntitlement value) => <String, Object?>{
        'featureId': value.featureId,
        'tier': value.tier.name,
        'validUntilUtc': value.validUntilUtc == null ? null : _utc(value.validUntilUtc!),
      };

  static FeatureEntitlement featureEntitlementFromMap(JsonMap map) => FeatureEntitlement(
        featureId: map['featureId']! as String,
        tier: EntitlementTier.values.byName(map['tier']! as String),
        validUntilUtc: map['validUntilUtc'] == null ? null : _date(map['validUntilUtc']),
      );

  static JsonMap backupManifestToMap(BackupManifest value) => <String, Object?>{
        'schemaVersion': value.schemaVersion,
        'appVersion': value.appVersion,
        'engineVersion': value.engineVersion,
        'exportedAtUtc': _utc(value.exportedAtUtc),
        'localeTag': value.localeTag,
        'recordCounts': value.recordCounts,
        'checksums': value.checksums,
      };

  static BackupManifest backupManifestFromMap(JsonMap map) => BackupManifest(
        schemaVersion: map['schemaVersion']! as int,
        appVersion: map['appVersion']! as String,
        engineVersion: map['engineVersion']! as String,
        exportedAtUtc: _date(map['exportedAtUtc']),
        localeTag: map['localeTag']! as String,
        recordCounts: _intMap(map['recordCounts']),
        checksums: _stringMap(map['checksums']),
      );

  static String _utc(DateTime value) => value.toUtc().toIso8601String();
  static DateTime _date(Object? value) => DateTime.parse(value! as String).toUtc();

  static JsonMap _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.map((key, item) => MapEntry(key.toString(), item));
    throw const FormatException('Expected map value.');
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) throw const FormatException('Expected list value.');
    return value.map((item) => item as String).toList(growable: false);
  }

  static Map<String, String> _stringMap(Object? value) =>
      _map(value).map((key, item) => MapEntry(key, item! as String));

  static Map<String, int> _intMap(Object? value) =>
      _map(value).map((key, item) => MapEntry(key, item! as int));
}
