import 'dart:math' as math;

import '../time/sidereal_time.dart';
import 'vedic_engine.dart';

final class VedicLagnaResult {
  const VedicLagnaResult({
    required this.siderealLongitudeDegrees,
    required this.ayanamshaDegrees,
    required this.localMeanSiderealDegrees,
    required this.meanObliquityDegrees,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
  });

  final double siderealLongitudeDegrees;
  final double ayanamshaDegrees;
  final double localMeanSiderealDegrees;
  final double meanObliquityDegrees;
  final String ayanamshaId;
  final String ayanamshaDataVersion;

  int get rashiIndex => (siderealLongitudeDegrees / 30.0).floor() % 12;
  double get degreesWithinRashi => siderealLongitudeDegrees % 30.0;
}

/// Independent Vedic Lagna geometry for RC-0084.
///
/// The calculation consumes UT1 and TT separately, derives the eastern
/// ecliptic/horizon intersection directly, then applies the selected versioned
/// Vedic ayanamsha. It intentionally does not import or delegate to the Western
/// chart/house calculation layer.
abstract final class VedicLagna {
  static const double _j2000 = 2451545.0;
  static const double _daysPerCentury = 36525.0;

  static VedicLagnaResult calculate({
    required double julianDayUt1,
    required double julianDayTt,
    required double longitudeDegreesEast,
    required double latitudeDegreesNorth,
    required VedicAyanamshaProvider ayanamsha,
  }) {
    _finite(julianDayUt1, 'julianDayUt1');
    _finite(julianDayTt, 'julianDayTt');
    _finite(longitudeDegreesEast, 'longitudeDegreesEast');
    _finite(latitudeDegreesNorth, 'latitudeDegreesNorth');
    if (longitudeDegreesEast < -180.0 || longitudeDegreesEast > 180.0) {
      throw RangeError.value(longitudeDegreesEast, 'longitudeDegreesEast');
    }
    if (latitudeDegreesNorth <= -90.0 || latitudeDegreesNorth >= 90.0) {
      throw RangeError.value(latitudeDegreesNorth, 'latitudeDegreesNorth');
    }
    if (ayanamsha.id.trim().isEmpty || ayanamsha.dataVersion.trim().isEmpty) {
      throw StateError('Vedic ayanamsha provenance must be explicit.');
    }

    final gmstHours = SiderealTime.greenwichMeanHours(
      julianDayUt1: julianDayUt1,
      julianDayTt: julianDayTt,
    );
    final localSiderealDegrees = _normalizeDegrees(
      SiderealTime.hoursToDegrees(gmstHours) + longitudeDegreesEast,
    );
    final obliquityDegrees = _meanObliquityIau2006(julianDayTt);
    final tropicalAscendant = _tropicalAscendantFromGeometry(
      localMeanSiderealDegrees: localSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      meanObliquityDegrees: obliquityDegrees,
    );
    final ayanamshaDegrees = ayanamsha.degreesAt(julianDayTt);
    if (!ayanamshaDegrees.isFinite ||
        ayanamshaDegrees < 0.0 ||
        ayanamshaDegrees >= 360.0) {
      throw StateError('Ayanamsha provider returned an invalid angle.');
    }

    return VedicLagnaResult(
      siderealLongitudeDegrees:
          _normalizeDegrees(tropicalAscendant - ayanamshaDegrees),
      ayanamshaDegrees: ayanamshaDegrees,
      localMeanSiderealDegrees: localSiderealDegrees,
      meanObliquityDegrees: obliquityDegrees,
      ayanamshaId: ayanamsha.id,
      ayanamshaDataVersion: ayanamsha.dataVersion,
    );
  }

  static double _tropicalAscendantFromGeometry({
    required double localMeanSiderealDegrees,
    required double latitudeDegreesNorth,
    required double meanObliquityDegrees,
  }) {
    final theta = _toRadians(_normalizeDegrees(localMeanSiderealDegrees));
    final latitude = _toRadians(latitudeDegreesNorth);
    final epsilon = _toRadians(meanObliquityDegrees);
    final ascBase = math.atan2(
      -math.cos(theta),
      math.sin(theta) * math.cos(epsilon) +
          math.tan(latitude) * math.sin(epsilon),
    );
    return _normalizeDegrees(_toDegrees(ascBase) + 180.0);
  }

  static double _meanObliquityIau2006(double julianDayTt) {
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
