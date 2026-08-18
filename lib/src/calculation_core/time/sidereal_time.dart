abstract final class SiderealTime {
  static const double hoursPerDay = 24.0;
  static const double j2000JulianDay = 2451545.0;
  static const double daysPerJulianCentury = 36525.0;

  /// Computes Greenwich Mean Sidereal Time in hours using the USNO
  /// approximate expression.
  ///
  /// [julianDayUt1] is Julian Date on UT1. [julianDayTt] is Julian Date on TT.
  /// Keeping them explicit prevents UTC, UT1 and TT from being conflated in
  /// later ASC/MC and house calculations.
  static double greenwichMeanHours({
    required double julianDayUt1,
    required double julianDayTt,
  }) {
    _requireFinite(julianDayUt1, 'julianDayUt1');
    _requireFinite(julianDayTt, 'julianDayTt');

    final jd0 = (julianDayUt1 - 0.5).floorToDouble() + 0.5;
    final utHours = (julianDayUt1 - jd0) * hoursPerDay;
    final daysUtFromJ2000 = jd0 - j2000JulianDay;
    final ttCenturies = (julianDayTt - j2000JulianDay) / daysPerJulianCentury;

    final rawHours = 6.697375 +
        0.065707485828 * daysUtFromJ2000 +
        1.0027379 * utHours +
        0.0854103 * ttCenturies +
        0.0000258 * ttCenturies * ttCenturies;

    return normalizeHours(rawHours);
  }

  static double normalizeHours(double hours) {
    _requireFinite(hours, 'hours');
    final normalized = hours % hoursPerDay;
    return normalized < 0 ? normalized + hoursPerDay : normalized;
  }

  static double hoursToDegrees(double hours) => normalizeHours(hours) * 15.0;

  static void _requireFinite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'Expected a finite value.');
    }
  }
}
