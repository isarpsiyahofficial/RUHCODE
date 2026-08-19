import 'dart:math' as math;

import '../time/sidereal_time.dart';

class AscMcResult {
  const AscMcResult({
    required this.ascendantDegrees,
    required this.midheavenDegrees,
    required this.localMeanSiderealDegrees,
    required this.meanObliquityDegrees,
  });

  final double ascendantDegrees;
  final double midheavenDegrees;
  final double localMeanSiderealDegrees;
  final double meanObliquityDegrees;
}

/// Mean tropical ASC/MC geometry.
///
/// This layer deliberately consumes UT1 and TT separately. It must not silently
/// replace UT1 with UTC. The result is a geometric prerequisite for Western
/// house systems; production accuracy still depends on verified EOP/time-scale
/// inputs and independent golden-reference validation.
abstract final class WesternAscMc {
  static const double _j2000 = 2451545.0;
  static const double _daysPerCentury = 36525.0;

  static AscMcResult calculate({
    required double julianDayUt1,
    required double julianDayTt,
    required double longitudeDegreesEast,
    required double latitudeDegreesNorth,
  }) {
    _finite(julianDayUt1, 'julianDayUt1');
    _finite(julianDayTt, 'julianDayTt');
    _finite(longitudeDegreesEast, 'longitudeDegreesEast');
    _finite(latitudeDegreesNorth, 'latitudeDegreesNorth');

    if (longitudeDegreesEast < -180.0 || longitudeDegreesEast > 180.0) {
      throw RangeError.range(
        longitudeDegreesEast,
        -180.0,
        180.0,
        'longitudeDegreesEast',
      );
    }
    if (latitudeDegreesNorth <= -90.0 || latitudeDegreesNorth >= 90.0) {
      throw RangeError.range(
        latitudeDegreesNorth,
        -89.999999999,
        89.999999999,
        'latitudeDegreesNorth',
        'Exact geographic poles do not have a stable ascendant.',
      );
    }

    final gmstHours = SiderealTime.greenwichMeanHours(
      julianDayUt1: julianDayUt1,
      julianDayTt: julianDayTt,
    );
    final localSiderealDegrees = _normalizeDegrees(
      SiderealTime.hoursToDegrees(gmstHours) + longitudeDegreesEast,
    );
    final obliquityDegrees = meanObliquityIau2006(julianDayTt);

    return calculateFromLocalSidereal(
      localMeanSiderealDegrees: localSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      meanObliquityDegrees: obliquityDegrees,
    );
  }

  /// Deterministic geometry entry point used by boundary tests.
  static AscMcResult calculateFromLocalSidereal({
    required double localMeanSiderealDegrees,
    required double latitudeDegreesNorth,
    required double meanObliquityDegrees,
  }) {
    _finite(localMeanSiderealDegrees, 'localMeanSiderealDegrees');
    _finite(latitudeDegreesNorth, 'latitudeDegreesNorth');
    _finite(meanObliquityDegrees, 'meanObliquityDegrees');

    if (latitudeDegreesNorth <= -90.0 || latitudeDegreesNorth >= 90.0) {
      throw RangeError.range(
        latitudeDegreesNorth,
        -89.999999999,
        89.999999999,
        'latitudeDegreesNorth',
      );
    }
    if (meanObliquityDegrees <= 0.0 || meanObliquityDegrees >= 90.0) {
      throw RangeError.range(
        meanObliquityDegrees,
        0.0,
        90.0,
        'meanObliquityDegrees',
      );
    }

    final thetaDegrees = _normalizeDegrees(localMeanSiderealDegrees);
    final theta = _toRadians(thetaDegrees);
    final latitude = _toRadians(latitudeDegreesNorth);
    final epsilon = _toRadians(meanObliquityDegrees);

    // Ecliptic longitude whose right ascension lies on the local meridian.
    final mc = math.atan2(
      math.sin(theta),
      math.cos(theta) * math.cos(epsilon),
    );

    // Eastern intersection of the ecliptic with the local horizon.
    // The +180° selects the eastern horizon rather than the descendant.
    final ascBase = math.atan2(
      -math.cos(theta),
      math.sin(theta) * math.cos(epsilon) +
          math.tan(latitude) * math.sin(epsilon),
    );

    return AscMcResult(
      ascendantDegrees: _normalizeDegrees(_toDegrees(ascBase) + 180.0),
      midheavenDegrees: _normalizeDegrees(_toDegrees(mc)),
      localMeanSiderealDegrees: thetaDegrees,
      meanObliquityDegrees: meanObliquityDegrees,
    );
  }

  /// IAU 2006 mean obliquity polynomial, expressed in degrees.
  static double meanObliquityIau2006(double julianDayTt) {
    _finite(julianDayTt, 'julianDayTt');
    final t = (julianDayTt - _j2000) / _daysPerCentury;
    final arcseconds = 84381.406 -
        46.836769 * t -
        0.0001831 * t * t +
        0.00200340 * t * t * t -
        0.000000576 * t * t * t * t -
        0.0000000434 * t * t * t * t * t;
    return arcseconds / 3600.0;
  }

  static double _normalizeDegrees(double degrees) {
    final normalized = degrees % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
  static double _toDegrees(double radians) => radians * 180.0 / math.pi;

  static void _finite(double value, String name) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, name, 'Expected a finite value.');
    }
  }
}
