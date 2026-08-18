import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/time_scales.dart';

void main() {
  test('TAI-UTC follows historical leap-second segments', () {
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(1972, 1, 1)),
      10,
    );
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(1972, 6, 30, 23, 59, 59)),
      10,
    );
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(1972, 7, 1)),
      11,
    );
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(2000, 1, 1)),
      32,
    );
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(2017, 1, 1)),
      37,
    );
    expect(
      UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(2026, 12, 31, 23, 59, 59)),
      37,
    );
  });

  test('TT is exactly TAI plus 32.184 seconds', () {
    expect(
      TimeScales.ttMinusUtcSeconds(DateTime.utc(2000, 1, 1)),
      closeTo(64.184, 1e-12),
    );
    expect(
      TimeScales.ttMinusUtcSeconds(DateTime.utc(2026, 8, 18)),
      closeTo(69.184, 1e-12),
    );
  });

  test('USNO J2000 UTC instant maps to JD 2451545.0 TT', () {
    final jdTt = TimeScales.ttJulianDayFromUtc(
      DateTime.utc(2000, 1, 1, 11, 58, 55, 816),
    );
    expect(jdTt, closeTo(2451545.0, 1e-9));
  });

  test('pre-1972 UTC is rejected rather than given a fabricated offset', () {
    expect(
      () => UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(1971, 12, 31)),
      throwsRangeError,
    );
  });

  test('future UTC beyond known Bulletin C horizon is rejected', () {
    expect(
      () => UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime.utc(2027, 7, 1)),
      throwsRangeError,
    );
  });

  test('non-UTC DateTime is rejected', () {
    expect(
      () => UtcTaiOffsetTable.taiMinusUtcSeconds(DateTime(2026, 8, 18)),
      throwsArgumentError,
    );
  });
}
