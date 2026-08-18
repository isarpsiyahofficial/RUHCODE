import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';

void main() {
  DailySnapshotIdentity identity({
    String profileId = '11111111-1111-4111-8111-111111111111',
    int year = 2026,
    int month = 8,
    int day = 16,
    String zone = 'Europe/Istanbul',
    double latitude = 41.0082,
    double longitude = 28.9784,
    String engineVersion = '1.0.0',
    String timezoneVersion = '2025c',
  }) {
    return DailySnapshotIdentity(
      profileId: EntityId.parse(profileId),
      civilDate: CivilDate(year, month, day),
      ianaTimeZoneId: zone,
      latitude: latitude,
      longitude: longitude,
      engineVersion: engineVersion,
      timezoneDatabaseVersion: timezoneVersion,
    );
  }

  test('same calendar month/day in different years never shares cache key', () {
    final in2026 = identity(year: 2026);
    final in2027 = identity(year: 2027);
    expect(in2026.dateKey, '2026-08-16');
    expect(in2027.dateKey, '2027-08-16');
    expect(in2026.cacheKey, isNot(in2027.cacheKey));
  });

  test('timezone is part of DailySnapshot identity', () {
    final istanbul = identity(zone: 'Europe/Istanbul');
    final tokyo = identity(zone: 'Asia/Tokyo');
    expect(istanbul.cacheKey, isNot(tokyo.cacheKey));
  });

  test('profile and location are part of DailySnapshot identity', () {
    final first = identity();
    final otherProfile = identity(
      profileId: '22222222-2222-4222-8222-222222222222',
    );
    final otherLocation = identity(latitude: 39.9334, longitude: 32.8597);
    expect(first.cacheKey, isNot(otherProfile.cacheKey));
    expect(first.cacheKey, isNot(otherLocation.cacheKey));
  });

  test('engine and timezone database versions invalidate cache', () {
    final current = identity();
    final engineUpdate = identity(engineVersion: '1.0.1');
    final timezoneUpdate = identity(timezoneVersion: '2026a');
    expect(current.cacheKey, isNot(engineUpdate.cacheKey));
    expect(current.cacheKey, isNot(timezoneUpdate.cacheKey));
  });

  test('leap day has its own exact snapshot identity', () {
    final leap = identity(year: 2028, month: 2, day: 29);
    expect(leap.dateKey, '2028-02-29');
    expect(leap.cacheKey, contains('2028-02-29'));
  });

  test('snapshot can exist without inventing unavailable factor results', () {
    final snapshot = DailySnapshot(
      identity: identity(),
      generatedAtUtc: DateTime.utc(2026, 8, 16, 9),
      factors: const <DailyFactorReference>[],
    );
    expect(snapshot.isEmpty, isTrue);
  });

  test('factor references retain source engine provenance', () {
    final snapshot = DailySnapshot(
      identity: identity(),
      generatedAtUtc: DateTime.utc(2026, 8, 16, 9),
      factors: const <DailyFactorReference>[
        DailyFactorReference(
          kind: DailyFactorKind.planetaryHour,
          sourceEngineId: 'planetary-hours',
          sourceEngineVersion: '1.0.0',
          resultId: 'ph:2026-08-16:istanbul:09',
        ),
      ],
    );
    expect(snapshot.isEmpty, isFalse);
    expect(snapshot.factors.single.sourceEngineId, 'planetary-hours');
  });
}
