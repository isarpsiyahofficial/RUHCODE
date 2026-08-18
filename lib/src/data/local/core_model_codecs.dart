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
        timeKnowledge: BirthTimeKnowledge.values.byName(
          map['timeKnowledge']! as String,
        ),
        localTime: map['localTime'] as String?,
        location: locationFromMap(_map(map['location'])),
      );

  static JsonMap profileToMap(Profile value) => <String, Object?>{
        'id': value.id.value,
        'displayName': value.displayName,
        'birthData': birthDataToMap(value.birthData),
        'createdAtUtc': value.createdAtUtc.toUtc().toIso8601String(),
        'updatedAtUtc': value.updatedAtUtc.toUtc().toIso8601String(),
      };

  static Profile profileFromMap(JsonMap map) => Profile(
        id: EntityId.parse(map['id']! as String),
        displayName: map['displayName']! as String,
        birthData: birthDataFromMap(_map(map['birthData'])),
        createdAtUtc: DateTime.parse(map['createdAtUtc']! as String).toUtc(),
        updatedAtUtc: DateTime.parse(map['updatedAtUtc']! as String).toUtc(),
      );

  static JsonMap clientToMap(Client value) => <String, Object?>{
        'id': value.id.value,
        'displayName': value.displayName,
        'birthData': value.birthData == null ? null : birthDataToMap(value.birthData!),
        'tags': value.tags,
        'createdAtUtc': value.createdAtUtc.toUtc().toIso8601String(),
        'updatedAtUtc': value.updatedAtUtc.toUtc().toIso8601String(),
      };

  static Client clientFromMap(JsonMap map) => Client(
        id: EntityId.parse(map['id']! as String),
        displayName: map['displayName']! as String,
        birthData: map['birthData'] == null
            ? null
            : birthDataFromMap(_map(map['birthData'])),
        tags: _stringList(map['tags']),
        createdAtUtc: DateTime.parse(map['createdAtUtc']! as String).toUtc(),
        updatedAtUtc: DateTime.parse(map['updatedAtUtc']! as String).toUtc(),
      );

  static JsonMap calculationManifestToMap(CalculationManifest value) =>
      <String, Object?>{
        'id': value.id.value,
        'engineId': value.engineId,
        'engineVersion': value.engineVersion,
        'algorithmVersion': value.algorithmVersion,
        'dataVersion': value.dataVersion,
        'timezoneDatabaseVersion': value.timezoneDatabaseVersion,
        'localDateTime': value.localDateTime.toIso8601String(),
        'utcDateTime': value.utcDateTime.toUtc().toIso8601String(),
        'location': locationToMap(value.location),
        'validity': value.validity.name,
        'houseSystemId': value.houseSystemId,
        'zodiacSystemId': value.zodiacSystemId,
        'ayanamshaId': value.ayanamshaId,
        'nodeModeId': value.nodeModeId,
      };

  static CalculationManifest calculationManifestFromMap(JsonMap map) =>
      CalculationManifest(
        id: EntityId.parse(map['id']! as String),
        engineId: map['engineId']! as String,
        engineVersion: map['engineVersion']! as String,
        algorithmVersion: map['algorithmVersion']! as String,
        dataVersion: map['dataVersion']! as String,
        timezoneDatabaseVersion: map['timezoneDatabaseVersion'] as String?,
        localDateTime: DateTime.parse(map['localDateTime']! as String),
        utcDateTime: DateTime.parse(map['utcDateTime']! as String).toUtc(),
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
        'startedAtUtc': value.startedAtUtc.toUtc().toIso8601String(),
        'endedAtUtc': value.endedAtUtc?.toUtc().toIso8601String(),
        'createdAtUtc': value.createdAtUtc.toUtc().toIso8601String(),
        'updatedAtUtc': value.updatedAtUtc.toUtc().toIso8601String(),
      };

  static Consultation consultationFromMap(JsonMap map) => Consultation(
        id: EntityId.parse(map['id']! as String),
        clientId: EntityId.parse(map['clientId']! as String),
        startedAtUtc: DateTime.parse(map['startedAtUtc']! as String).toUtc(),
        endedAtUtc: map['endedAtUtc'] == null
            ? null
            : DateTime.parse(map['endedAtUtc']! as String).toUtc(),
        createdAtUtc: DateTime.parse(map['createdAtUtc']! as String).toUtc(),
        updatedAtUtc: DateTime.parse(map['updatedAtUtc']! as String).toUtc(),
      );

  static JsonMap noteToMap(Note value) => <String, Object?>{
        'id': value.id.value,
        'ownerEntityId': value.ownerEntityId.value,
        'text': value.text,
        'createdAtUtc': value.createdAtUtc.toUtc().toIso8601String(),
        'updatedAtUtc': value.updatedAtUtc.toUtc().toIso8601String(),
      };

  static Note noteFromMap(JsonMap map) => Note(
        id: EntityId.parse(map['id']! as String),
        ownerEntityId: EntityId.parse(map['ownerEntityId']! as String),
        text: map['text']! as String,
        createdAtUtc: DateTime.parse(map['createdAtUtc']! as String).toUtc(),
        updatedAtUtc: DateTime.parse(map['updatedAtUtc']! as String).toUtc(),
      );

  static JsonMap _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    throw const FormatException('Expected map value.');
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) throw const FormatException('Expected list value.');
    return value.map((item) => item as String).toList(growable: false);
  }
}
