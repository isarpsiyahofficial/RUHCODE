import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/solar/solar_events.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  test('NOAA New York 2026-08-01 sunrise agrees within one minute', () {
    final result = SolarEvents.forDate(
      date: CivilDate(2026, 8, 1),
      latitudeDegrees: 40.72,
      longitudeDegrees: -74.02,
    );

    expect(result.state, SolarDayState.normal);
    // NOAA table: 05:53 local at UTC-04:00 => 09:53 UTC => 593 minutes.
    expect(result.sunriseUtcMinutes!, closeTo(593, 1));
  });

  test('normal day preserves sunrise < noon < sunset in UTC timeline', () {
    final result = SolarEvents.forDate(
      date: CivilDate(2026, 3, 20),
      latitudeDegrees: 0,
      longitudeDegrees: 0,
    );

    expect(result.state, SolarDayState.normal);
    expect(result.sunriseUtcMinutes!, lessThan(result.solarNoonUtcMinutes!));
    expect(result.solarNoonUtcMinutes!, lessThan(result.sunsetUtcMinutes!));
  });

  test('northern polar summer is represented explicitly instead of fake times', () {
    final result = SolarEvents.forDate(
      date: CivilDate(2026, 6, 21),
      latitudeDegrees: 89,
      longitudeDegrees: 0,
    );

    expect(result.state, SolarDayState.polarDay);
    expect(result.sunriseUtcMinutes, isNull);
    expect(result.sunsetUtcMinutes, isNull);
  });

  test('northern polar winter is represented explicitly instead of fake times', () {
    final result = SolarEvents.forDate(
      date: CivilDate(2026, 12, 21),
      latitudeDegrees: 89,
      longitudeDegrees: 0,
    );

    expect(result.state, SolarDayState.polarNight);
    expect(result.sunriseUtcMinutes, isNull);
    expect(result.sunsetUtcMinutes, isNull);
  });

  test('coordinate ranges are strict', () {
    expect(
      () => SolarEvents.forDate(
        date: CivilDate(2026, 8, 18),
        latitudeDegrees: 91,
        longitudeDegrees: 0,
      ),
      throwsRangeError,
    );
    expect(
      () => SolarEvents.forDate(
        date: CivilDate(2026, 8, 18),
        latitudeDegrees: 0,
        longitudeDegrees: 181,
      ),
      throwsRangeError,
    );
  });
}
