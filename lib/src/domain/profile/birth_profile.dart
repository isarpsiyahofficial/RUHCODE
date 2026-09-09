/// Birth profile input contract for RC-0354..RC-0359.
///
/// Birth date is optional. Birth time is explicitly known/unknown so consumers
/// cannot silently substitute noon/midnight and fabricate time-dependent data.
enum BirthTimeKnowledge { known, unknown }

enum BirthTimeDependency { notRequired, required }

final class BirthTimeValue {
  BirthTimeValue.known({required int hour, required int minute})
      : knowledge = BirthTimeKnowledge.known,
        hour = hour,
        minute = minute {
    if (hour < 0 || hour > 23) throw ArgumentError('hour must be 0..23');
    if (minute < 0 || minute > 59) throw ArgumentError('minute must be 0..59');
  }

  const BirthTimeValue.unknown()
      : knowledge = BirthTimeKnowledge.unknown,
        hour = null,
        minute = null;

  final BirthTimeKnowledge knowledge;
  final int? hour;
  final int? minute;

  bool get isKnown => knowledge == BirthTimeKnowledge.known;
}

final class BirthPlaceSelection {
  BirthPlaceSelection({
    required this.displayName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
  }) {
    if (displayName.trim().isEmpty) throw ArgumentError('displayName');
    if (countryCode.trim().length != 2) throw ArgumentError('countryCode');
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError('latitude');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError('longitude');
    }
    if (!timeZoneId.contains('/')) throw ArgumentError('IANA timeZoneId required');
  }

  final String displayName;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timeZoneId;
}

final class BirthProfile {
  BirthProfile({
    required this.id,
    required this.displayName,
    this.birthDate,
    required this.birthTime,
    this.birthPlace,
  }) {
    if (id.trim().isEmpty) throw ArgumentError('id');
    if (displayName.trim().isEmpty) throw ArgumentError('displayName');
  }

  final String id;
  final String displayName;
  final DateTime? birthDate;
  final BirthTimeValue birthTime;
  final BirthPlaceSelection? birthPlace;

  BirthProfile copyWith({
    String? displayName,
    DateTime? birthDate,
    bool clearBirthDate = false,
    BirthTimeValue? birthTime,
    BirthPlaceSelection? birthPlace,
    bool clearBirthPlace = false,
  }) =>
      BirthProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
        birthTime: birthTime ?? this.birthTime,
        birthPlace: clearBirthPlace ? null : (birthPlace ?? this.birthPlace),
      );

  bool supports(BirthTimeDependency dependency) =>
      dependency == BirthTimeDependency.notRequired || birthTime.isKnown;

  DateTime requireLocalBirthDateTime() {
    if (birthDate == null) throw StateError('birth date is unknown');
    if (!birthTime.isKnown) {
      throw StateError('birth time is unknown; time-dependent calculation blocked');
    }
    return DateTime(
      birthDate!.year,
      birthDate!.month,
      birthDate!.day,
      birthTime.hour!,
      birthTime.minute!,
    );
  }
}

final class BirthTimeFeatureNotice {
  const BirthTimeFeatureNotice({
    required this.featureId,
    required this.dependency,
    required this.trMessage,
    required this.enMessage,
  });

  final String featureId;
  final BirthTimeDependency dependency;
  final String trMessage;
  final String enMessage;

  bool canOpen(BirthProfile profile) => profile.supports(dependency);
}
