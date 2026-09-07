import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/profile/birth_profile.dart';

void main() {
  BirthPlaceSelection antalya() => BirthPlaceSelection(
        displayName: 'Antalya, Türkiye',
        countryCode: 'TR',
        latitude: 36.8969,
        longitude: 30.7133,
        timeZoneId: 'Europe/Istanbul',
      );

  test('birth date is optional and unknown birth time stays explicit', () {
    final profile = BirthProfile(
      id: 'p1',
      displayName: 'User',
      birthTime: const BirthTimeValue.unknown(),
    );
    expect(profile.birthDate, isNull);
    expect(profile.birthTime.isKnown, isFalse);
    expect(profile.supports(BirthTimeDependency.notRequired), isTrue);
    expect(profile.supports(BirthTimeDependency.required), isFalse);
  });

  test('unknown birth time can never fabricate a time-dependent datetime', () {
    final profile = BirthProfile(
      id: 'p2',
      displayName: 'User',
      birthDate: DateTime(1990, 5, 10),
      birthTime: const BirthTimeValue.unknown(),
      birthPlace: antalya(),
    );
    expect(profile.requireLocalBirthDateTime, throwsStateError);
  });

  test('known birth time validates clock values and enables dependent features', () {
    final profile = BirthProfile(
      id: 'p3',
      displayName: 'User',
      birthDate: DateTime(1990, 5, 10),
      birthTime: BirthTimeValue.known(hour: 14, minute: 35),
      birthPlace: antalya(),
    );
    expect(profile.supports(BirthTimeDependency.required), isTrue);
    expect(profile.requireLocalBirthDateTime(), DateTime(1990, 5, 10, 14, 35));
    expect(() => BirthTimeValue.known(hour: 24, minute: 0), throwsArgumentError);
  });

  test('birth place keeps coordinates and IANA timezone independently validated', () {
    final place = antalya();
    expect(place.latitude, closeTo(36.8969, 0.00001));
    expect(place.timeZoneId, 'Europe/Istanbul');
    expect(
      () => BirthPlaceSelection(
        displayName: 'Bad',
        countryCode: 'TR',
        latitude: 91,
        longitude: 30,
        timeZoneId: 'Europe/Istanbul',
      ),
      throwsArgumentError,
    );
  });

  test('profile data can be edited without changing stable profile identity', () {
    final profile = BirthProfile(
      id: 'stable-id',
      displayName: 'Old',
      birthTime: const BirthTimeValue.unknown(),
    );
    final edited = profile.copyWith(
      displayName: 'New',
      birthDate: DateTime(2000, 1, 2),
      birthTime: BirthTimeValue.known(hour: 9, minute: 15),
      birthPlace: antalya(),
    );
    expect(edited.id, 'stable-id');
    expect(edited.displayName, 'New');
    expect(edited.birthPlace, isNotNull);
  });

  test('feature notice explicitly blocks time-dependent feature when time unknown', () {
    const notice = BirthTimeFeatureNotice(
      featureId: 'ascendant',
      dependency: BirthTimeDependency.required,
      trMessage: 'Bu özellik doğum saati gerektirir.',
      enMessage: 'This feature requires a birth time.',
    );
    final profile = BirthProfile(
      id: 'p4',
      displayName: 'User',
      birthTime: const BirthTimeValue.unknown(),
    );
    expect(notice.canOpen(profile), isFalse);
    expect(notice.trMessage, isNotEmpty);
    expect(notice.enMessage, isNotEmpty);
  });
}
