import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/calculation_core/time/julian_day.dart';

void main() {
  test('USNO reference 1978-01-01 00 UT is JD 2443509.5', () {
    expect(
      JulianDay.fromCivilDate(CivilDate(1978, 1, 1)),
      closeTo(2443509.5, 1e-9),
    );
  });

  test('USNO reference 1978-07-21 15 UT is JD 2443711.125', () {
    expect(
      JulianDay.fromCivilDate(CivilDate(1978, 7, 21), utHours: 15),
      closeTo(2443711.125, 1e-9),
    );
  });

  test('J2000 epoch is JD 2451545.0 at 2000-01-01 12 UTC', () {
    final jd = JulianDay.fromUtc(DateTime.utc(2000, 1, 1, 12));
    expect(jd, closeTo(2451545.0, 1e-9));
    expect(JulianDay.centuriesSinceJ2000(jd), closeTo(0, 1e-15));
  });

  test('Modified Julian Date relationship is exact by definition', () {
    expect(JulianDay.modified(2400000.5), 0);
    expect(JulianDay.modified(2451545.0), closeTo(51544.5, 1e-9));
  });

  test('one second advances Julian Day by 1/86400', () {
    final first = JulianDay.fromUtc(DateTime.utc(2026, 8, 18, 12));
    final next = JulianDay.fromUtc(DateTime.utc(2026, 8, 18, 12, 0, 1));
    expect(next - first, closeTo(1 / 86400, 1e-10));
  });

  test('non UTC DateTime is rejected', () {
    expect(
      () => JulianDay.fromUtc(DateTime(2026, 8, 18, 12)),
      throwsArgumentError,
    );
  });

  test('invalid UT hour is rejected rather than normalized silently', () {
    expect(
      () => JulianDay.fromCivilDate(CivilDate(2026, 8, 18), utHours: 24),
      throwsRangeError,
    );
    expect(
      () => JulianDay.fromCivilDate(CivilDate(2026, 8, 18), utHours: -0.1),
      throwsRangeError,
    );
  });
}
