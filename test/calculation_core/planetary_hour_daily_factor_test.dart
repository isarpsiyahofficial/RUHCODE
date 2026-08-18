import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/planetary_hour_factor.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';

void main() {
  DailySnapshotIdentity identity(CivilDate date) => DailySnapshotIdentity(
        profileId: EntityId.parse('11111111-1111-4111-8111-111111111111'),
        civilDate: date,
        ianaTimeZoneId: 'Europe/Istanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        engineVersion: '1.0.0',
        timezoneDatabaseVersion: '2025c',
      );

  test('daytime DailySnapshot factor comes from real planetary-hour slots', () {
    final factor = PlanetaryHourDailyFactor.resolve(
      identity: identity(CivilDate(2026, 8, 18)),
      utcInstant: DateTime.utc(2026, 8, 18, 9),
    );

    expect(factor, isNotNull);
    expect(factor!.kind, DailyFactorKind.planetaryHour);
    expect(factor.sourceEngineId, PlanetaryHourDailyFactor.engineId);
    expect(factor.resultId, startsWith('ph|2026-08-18|'));
  });

  test('before sunrise checks previous planetary day instead of civil-midnight reset', () {
    final factor = PlanetaryHourDailyFactor.resolve(
      identity: identity(CivilDate(2026, 8, 18)),
      utcInstant: DateTime.utc(2026, 8, 18, 0),
    );

    expect(factor, isNotNull);
    expect(factor!.resultId, startsWith('ph|2026-08-17|'));
  });

  test('non-UTC query instant is rejected', () {
    expect(
      () => PlanetaryHourDailyFactor.resolve(
        identity: identity(CivilDate(2026, 8, 18)),
        utcInstant: DateTime(2026, 8, 18, 9),
      ),
      throwsArgumentError,
    );
  });
}
