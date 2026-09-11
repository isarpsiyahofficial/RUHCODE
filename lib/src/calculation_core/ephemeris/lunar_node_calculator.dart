import 'dart:math' as math;

import 'ephemeris.dart';

/// Deterministic lunar ascending-node longitudes from TT Julian Day.
///
/// Mean node uses the Meeus lunar-element polynomial. The legacy
/// [trueAscendingNodeDegrees] method retains the historical leading-periodic
/// approximation for compatibility. Production/high-accuracy consumers must
/// use [trueAscendingNodeFromEphemerisDegrees], which derives the osculating
/// lunar orbital plane from the physical Moon ephemeris and intersects it with
/// the mean ecliptic/equinox of date.
final class LunarNodeCalculator {
  const LunarNodeCalculator();

  static const double _j2000Jd = 2451545.0;
  static const double _daysPerJulianCentury = 36525.0;
  static const double _j2000ObliquityDegrees = 23.439291111;
  static const double _arcsecondsPerRadian = 206264.80624709636;

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

  /// Historical analytical approximation retained for compatibility tests.
  ///
  /// This method is not the RC-1436 high-accuracy production path because its
  /// truncated periodic series can exceed the canonical 0.02 degree budget.
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

  /// High-accuracy true/osculating ascending node from a physical Moon
  /// ephemeris. The derivative is central-differenced in the same mean
  /// ecliptic/equinox-of-date frame used for the returned node.
  ///
  /// This avoids a fitted periodic node series: the instantaneous orbital
  /// plane normal is `r x v`, and the ascending intersection longitude is
  /// `atan2(h.x, -h.y)`.
  double trueAscendingNodeFromEphemerisDegrees({
    required double jdTt,
    required EphemerisProvider ephemeris,
    double derivativeStepDays = 1.0 / 1440.0,
  }) {
    _requireFiniteJd(jdTt);
    if (!derivativeStepDays.isFinite ||
        derivativeStepDays <= 0.0 ||
        derivativeStepDays > 0.25) {
      throw RangeError(
        'Lunar-node derivative step must be finite and within (0, 0.25] days.',
      );
    }

    ephemeris.coverage.requireContains(jdTt - derivativeStepDays);
    ephemeris.coverage.requireContains(jdTt);
    ephemeris.coverage.requireContains(jdTt + derivativeStepDays);

    final before = ephemeris.stateAt(
      body: AstroBody.moon,
      jdTt: jdTt - derivativeStepDays,
    );
    final current = ephemeris.stateAt(body: AstroBody.moon, jdTt: jdTt);
    final after = ephemeris.stateAt(
      body: AstroBody.moon,
      jdTt: jdTt + derivativeStepDays,
    );
    _requireMoonState(before, ephemeris);
    _requireMoonState(current, ephemeris);
    _requireMoonState(after, ephemeris);

    final r0 = _meanEclipticOfDateCartesian(before);
    final r = _meanEclipticOfDateCartesian(current);
    final r1 = _meanEclipticOfDateCartesian(after);
    final denominator = 2.0 * derivativeStepDays;
    final vx = (r1.$1 - r0.$1) / denominator;
    final vy = (r1.$2 - r0.$2) / denominator;
    final vz = (r1.$3 - r0.$3) / denominator;

    final hx = (r.$2 * vz) - (r.$3 * vy);
    final hy = (r.$3 * vx) - (r.$1 * vz);
    final hz = (r.$1 * vy) - (r.$2 * vx);
    final hNorm = math.sqrt((hx * hx) + (hy * hy) + (hz * hz));
    final nodePlanarNorm = math.sqrt((hx * hx) + (hy * hy));
    if (!hNorm.isFinite ||
        hNorm <= 0.0 ||
        !nodePlanarNorm.isFinite ||
        nodePlanarNorm <= 1e-18) {
      throw StateError('Moon ephemeris produced a degenerate osculating plane.');
    }

    return _normalizeDegrees(math.atan2(hx, -hy) * 180.0 / math.pi);
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

  static void _requireMoonState(
    EclipticState state,
    EphemerisProvider ephemeris,
  ) {
    state.validate();
    if (state.body != AstroBody.moon ||
        state.sourceId != ephemeris.coverage.sourceId ||
        state.dataVersion != ephemeris.coverage.dataVersion) {
      throw StateError('True-node ephemeris Moon state/provenance mismatch.');
    }
  }

  static (double, double, double) _meanEclipticOfDateCartesian(
    EclipticState state,
  ) {
    final lon = _radians(state.longitudeDegrees);
    final lat = _radians(state.latitudeDegrees);
    final cosLat = math.cos(lat);
    final distance = state.distanceAu;
    final xEcl = distance * cosLat * math.cos(lon);
    final yEcl = distance * cosLat * math.sin(lon);
    final zEcl = distance * math.sin(lat);

    if (state.referenceFrame == EclipticReferenceFrame.tropicalOfDate) {
      return (xEcl, yEcl, zEcl);
    }

    // J2000 mean ecliptic -> J2000 mean equatorial.
    final epsilon0 = _radians(_j2000ObliquityDegrees);
    final xEq = xEcl;
    final yEq = (yEcl * math.cos(epsilon0)) - (zEcl * math.sin(epsilon0));
    final zEq = (yEcl * math.sin(epsilon0)) + (zEcl * math.cos(epsilon0));

    // IAU 1976/Meeus precession J2000 -> mean equator/equinox of date.
    final t = (state.jdTt - _j2000Jd) / _daysPerJulianCentury;
    final t2 = t * t;
    final t3 = t2 * t;
    final zeta = _arcsecondsToRadians(
      (2306.2181 * t) + (0.30188 * t2) + (0.017998 * t3),
    );
    final z = _arcsecondsToRadians(
      (2306.2181 * t) + (1.09468 * t2) + (0.018203 * t3),
    );
    final theta = _arcsecondsToRadians(
      (2004.3109 * t) - (0.42665 * t2) - (0.041833 * t3),
    );

    final radius = math.sqrt((xEq * xEq) + (yEq * yEq) + (zEq * zEq));
    final ra = math.atan2(yEq, xEq);
    final dec = math.atan2(zEq, math.sqrt((xEq * xEq) + (yEq * yEq)));
    final cosDec = math.cos(dec);
    final a = cosDec * math.sin(ra + zeta);
    final b =
        (math.cos(theta) * cosDec * math.cos(ra + zeta)) -
        (math.sin(theta) * math.sin(dec));
    final c =
        (math.sin(theta) * cosDec * math.cos(ra + zeta)) +
        (math.cos(theta) * math.sin(dec));
    final raDate = math.atan2(a, b) + z;
    final decDate = math.asin(c.clamp(-1.0, 1.0));

    final xEqDate = radius * math.cos(decDate) * math.cos(raDate);
    final yEqDate = radius * math.cos(decDate) * math.sin(raDate);
    final zEqDate = radius * math.sin(decDate);

    final epsilonDate = _arcsecondsToRadians(
      84381.448 - (46.8150 * t) - (0.00059 * t2) + (0.001813 * t3),
    );
    return (
      xEqDate,
      (yEqDate * math.cos(epsilonDate)) +
          (zEqDate * math.sin(epsilonDate)),
      (-yEqDate * math.sin(epsilonDate)) +
          (zEqDate * math.cos(epsilonDate)),
    );
  }

  static double _sinDegrees(double degrees) =>
      math.sin(degrees * math.pi / 180.0);

  static double _radians(double degrees) => degrees * math.pi / 180.0;

  static double _arcsecondsToRadians(double arcseconds) =>
      arcseconds / _arcsecondsPerRadian;

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
