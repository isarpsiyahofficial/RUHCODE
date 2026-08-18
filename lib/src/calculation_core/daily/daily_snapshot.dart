import '../../domain/ids/entity_id.dart';
import '../time/civil_calendar.dart';

final class DailySnapshotIdentity {
  const DailySnapshotIdentity({
    required this.profileId,
    required this.civilDate,
    required this.ianaTimeZoneId,
    required this.latitude,
    required this.longitude,
    required this.engineVersion,
    required this.timezoneDatabaseVersion,
  });

  final EntityId profileId;
  final CivilDate civilDate;
  final String ianaTimeZoneId;
  final double latitude;
  final double longitude;
  final String engineVersion;
  final String timezoneDatabaseVersion;

  String get dateKey => civilDate.isoKey;

  String get cacheKey => <String>[
        'daily',
        profileId.value,
        dateKey,
        ianaTimeZoneId,
        _coordinateKey(latitude),
        _coordinateKey(longitude),
        engineVersion,
        timezoneDatabaseVersion,
      ].join('|');

  static String _coordinateKey(double value) => value.toStringAsFixed(6);

  @override
  bool operator ==(Object other) =>
      other is DailySnapshotIdentity &&
      profileId == other.profileId &&
      civilDate == other.civilDate &&
      ianaTimeZoneId == other.ianaTimeZoneId &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      engineVersion == other.engineVersion &&
      timezoneDatabaseVersion == other.timezoneDatabaseVersion;

  @override
  int get hashCode => Object.hash(
        profileId,
        civilDate,
        ianaTimeZoneId,
        latitude,
        longitude,
        engineVersion,
        timezoneDatabaseVersion,
      );
}

enum DailyFactorKind {
  moonSign,
  moonPhase,
  transit,
  planetaryHour,
  personalDay,
  vedicIndicator,
}

final class DailyFactorReference {
  const DailyFactorReference({
    required this.kind,
    required this.sourceEngineId,
    required this.sourceEngineVersion,
    required this.resultId,
  });

  final DailyFactorKind kind;
  final String sourceEngineId;
  final String sourceEngineVersion;
  final String resultId;
}

final class DailySnapshot {
  const DailySnapshot({
    required this.identity,
    required this.generatedAtUtc,
    required this.factors,
  });

  final DailySnapshotIdentity identity;
  final DateTime generatedAtUtc;
  final List<DailyFactorReference> factors;

  bool get isEmpty => factors.isEmpty;
}
