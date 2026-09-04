import 'dart:math' as math;

/// Deterministic lunar ascending-node longitudes from TT Julian Day.
///
/// Mean node uses the Meeus lunar-element polynomial. True node applies the
/// leading periodic corrections to the mean node. Both are geocentric
/// ecliptic longitudes in degrees, normalized to [0, 360).
final class LunarNodeCalculator {
  const LunarNodeCalculator();

  static const double _j2000Jd = 2451545.0;
  static const double _daysPerJulianCentury = 36525.0;

  double meanAscendingNodeDegrees({required double jdTt}) {
    _requireFiniteJd(jdTt);
    final t = (jdTt - _j2000Jd) / _daysPerJulianCentury;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;
    final omega = 125.0445479 -
        1934.1362891 * t +
        0.0020754 * t2 +
        t3 / 467441.0 -
        t4 / 60616000.0;
    return _normalizeDegrees(omega);
  }

  double trueAscendingNodeDegrees({required double jdTt}) {
    _requireFiniteJd(jdTt);
    final t = (jdTt - _j2000Jd) / _daysPerJulianCentury;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;

    final d = _normalizeDegrees(
      297.8501921 +
          445267.1114034 * t -
          0.0018819 * t2 +
          t3 / 545868.0 -
          t4 / 113065000.0,
    );
    final m = _normalizeDegrees(
      357.5291092 +
          35999.0502909 * t -
          0.0001536 * t2 +
          t3 / 24490000.0,
    );
    final mPrime = _normalizeDegrees(
      134.9633964 +
          477198.8675055 * t +
          0.0087414 * t2 +
          t3 / 69699.0 -
          t4 / 14712000.0,
    );
    final f = _normalizeDegrees(
      93.2720950 +
          483202.0175233 * t -
          0.0036539 * t2 -
          t3 / 3526000.0 +
          t4 / 863310000.0,
    );

    final correction =
        -1.4979 * _sinDegrees(2.0 * (d - f)) -
        0.1500 * _sinDegrees(m) -
        0.1226 * _sinDegrees(2.0 * d) +
        0.1176 * _sinDegrees(2.0 * f) -
        0.0801 * _sinDegrees(2.0 * (mPrime - f));

    return _normalizeDegrees(meanAscendingNodeDegrees(jdTt: jdTt) + correction);
  }

  static double descendingNodeDegrees(double ascendingNodeDegrees) {
    if (!ascendingNodeDegrees.isFinite) {
      throw ArgumentError.value(
        ascendingNodeDegrees,
        'ascendingNodeDegrees',
        'must be finite',
      );
    }
    return _normalizeDegrees(ascendingNodeDegrees + 180.0);
  }

  static double _sinDegrees(double degrees) =>
      math.sin(degrees * math.pi / 180.0);

  static double _normalizeDegrees(double degrees) {
    final normalized = degrees % 360.0;
    return normalized < 0.0 ? normalized + 360.0 : normalized;
  }

  static void _requireFiniteJd(double jdTt) {
    if (!jdTt.isFinite) {
      throw ArgumentError.value(jdTt, 'jdTt', 'must be finite TT Julian Day');
    }
  }
}
