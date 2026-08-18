import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/sidereal_time.dart';

void main() {
  test('USNO approximate formula gives J2000 noon GMST reference', () {
    final hours = SiderealTime.greenwichMeanHours(
      julianDayUt1: 2451545.0,
      julianDayTt: 2451545.0,
    );
    expect(hours, closeTo(18.697376057086, 1e-12));
  });

  test('USNO approximate formula gives J2000 previous midnight reference', () {
    final hours = SiderealTime.greenwichMeanHours(
      julianDayUt1: 2451544.5,
      julianDayTt: 2451544.5,
    );
    expect(hours, closeTo(6.664520087883, 1e-12));
  });

  test('normalization stays in zero inclusive to 24 exclusive range', () {
    expect(SiderealTime.normalizeHours(24), 0);
    expect(SiderealTime.normalizeHours(25.5), 1.5);
    expect(SiderealTime.normalizeHours(-1), 23);
  });

  test('hour to degree conversion uses 15 degrees per sidereal hour', () {
    expect(SiderealTime.hoursToDegrees(6), closeTo(90, 1e-12));
    expect(SiderealTime.hoursToDegrees(18), closeTo(270, 1e-12));
  });

  test('non-finite inputs are rejected', () {
    expect(
      () => SiderealTime.greenwichMeanHours(
        julianDayUt1: double.nan,
        julianDayTt: 2451545.0,
      ),
      throwsArgumentError,
    );
    expect(() => SiderealTime.normalizeHours(double.infinity), throwsArgumentError);
  });
}
