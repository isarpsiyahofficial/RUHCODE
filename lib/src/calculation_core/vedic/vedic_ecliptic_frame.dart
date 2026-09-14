import 'dart:math' as math;

import '../ephemeris/ephemeris.dart';

/// Converts shared ephemeris coordinates to the mean tropical ecliptic of the
/// requested date before a Vedic ayanamsha is applied.
///
/// DE440s deliberately exposes geometric J2000-ecliptic states. Subtracting a
/// date-dependent ayanamsha directly from that frame mixes two different
/// equinoxes. This transform keeps the DE440s contract intact while making the
/// Vedic zodiac boundary explicit and testable.
abstract final class VedicEclipticFrame {
  static const double _j2000Jd = 2451545.0;
  static const double _j2000ObliquityDegrees = 23.439291111;
  static const double _arcsecondsPerRadian = 206264.80624709636;

  static double tropicalOfDateLongitude(EclipticState state) {
    state.validate();
    switch (state.referenceFrame) {
      case EclipticReferenceFrame.tropicalOfDate:
        return state.longitudeDegrees;
      case EclipticReferenceFrame.j2000Geometric:
        return _precessJ2000EclipticToDate(state);
    }
  }

  static double _precessJ2000EclipticToDate(EclipticState state) {
    final lon = _radians(state.longitudeDegrees);
    final lat = _radians(state.latitudeDegrees);
    final cosLat = math.cos(lat);

    // Unit vector in the J2000 ecliptic frame.
    final xEcl = cosLat * math.cos(lon);
    final yEcl = cosLat * math.sin(lon);
    final zEcl = math.sin(lat);

    // J2000 ecliptic -> J2000 mean equatorial.
    final epsilon0 = _radians(_j2000ObliquityDegrees);
    final xEq = xEcl;
    final yEq = (yEcl * math.cos(epsilon0)) - (zEcl * math.sin(epsilon0));
    final zEq = (yEcl * math.sin(epsilon0)) + (zEcl * math.cos(epsilon0));

    final ra = math.atan2(yEq, xEq);
    final dec = math.atan2(zEq, math.sqrt((xEq * xEq) + (yEq * yEq)));

    // IAU 1976/Meeus precession J2000 -> mean equator/equinox of date.
    // Over DE440s' application window this is comfortably inside the Vedic
    // 0.02-degree longitude accuracy budget and is independently oracle-tested.
    final t = (state.jdTt - _j2000Jd) / 36525.0;
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

    final xEqDate = math.cos(decDate) * math.cos(raDate);
    final yEqDate = math.cos(decDate) * math.sin(raDate);
    final zEqDate = math.sin(decDate);

    // Mean obliquity of date (Meeus/IAU 1976), then equatorial -> ecliptic.
    final epsilonDate = _arcsecondsToRadians(
      84381.448 - (46.8150 * t) - (0.00059 * t2) + (0.001813 * t3),
    );
    final xDateEcl = xEqDate;
    final yDateEcl =
        (yEqDate * math.cos(epsilonDate)) +
        (zEqDate * math.sin(epsilonDate));

    return _normalize360(math.atan2(yDateEcl, xDateEcl) * 180.0 / math.pi);
  }

  static double _radians(double degrees) => degrees * math.pi / 180.0;

  static double _arcsecondsToRadians(double arcseconds) =>
      arcseconds / _arcsecondsPerRadian;

  static double _normalize360(double value) {
    var normalized = value % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized;
  }
}