import 'dart:math' as math;

import '../time/civil_calendar.dart';
import '../time/julian_day.dart';

enum SolarDayState { normal, polarDay, polarNight }

final class SolarEventsResult {
  const SolarEventsResult._({
    required this.state,
    this.sunriseUtcMinutes,
    this.solarNoonUtcMinutes,
    this.sunsetUtcMinutes,
  });

  final SolarDayState state;
  final double? sunriseUtcMinutes;
  final double? solarNoonUtcMinutes;
  final double? sunsetUtcMinutes;

  bool get hasSunriseAndSunset => state == SolarDayState.normal;
}

final class SolarEvents {
  SolarEvents._();

  static const double apparentSunriseZenithDegrees = 90.83333333333333;

  /// Computes apparent sunrise, solar noon and sunset as minutes from
  /// 00:00 UTC for [date]. Longitude follows the international convention:
  /// east positive, west negative.
  ///
  /// The equations follow the NOAA/GML solar-calculation implementation,
  /// which in turn is based on Jean Meeus' Astronomical Algorithms. No time
  /// zone or DST rule is applied here; localization belongs to the timezone
  /// layer after the UTC instants are known.
  static SolarEventsResult forDate({
    required CivilDate date,
    required double latitudeDegrees,
    required double longitudeDegrees,
  }) {
    _validateCoordinates(latitudeDegrees, longitudeDegrees);
    final jd = JulianDay.fromCivilDate(date);

    final noon = _solarNoonUtcMinutes(jd, longitudeDegrees);
    final rise = _eventUtcMinutes(
      jd: jd,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
      sunrise: true,
    );
    final set = _eventUtcMinutes(
      jd: jd,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
      sunrise: false,
    );

    if (rise == null || set == null) {
      final declination = _sunDeclination(_julianCenturies(jd + noon / 1440));
      final cosHourAngle = _cosHourAngle(latitudeDegrees, declination);
      return SolarEventsResult._(
        state: cosHourAngle < -1 ? SolarDayState.polarDay : SolarDayState.polarNight,
        solarNoonUtcMinutes: noon,
      );
    }

    return SolarEventsResult._(
      state: SolarDayState.normal,
      sunriseUtcMinutes: rise,
      solarNoonUtcMinutes: noon,
      sunsetUtcMinutes: set,
    );
  }

  static double? _eventUtcMinutes({
    required double jd,
    required double latitudeDegrees,
    required double longitudeDegrees,
    required bool sunrise,
  }) {
    var t = _julianCenturies(jd);
    var eqTime = _equationOfTimeMinutes(t);
    var solarDec = _sunDeclination(t);
    var hourAngle = _hourAngleDegrees(latitudeDegrees, solarDec);
    if (hourAngle == null) return null;

    var delta = sunrise ? hourAngle : -hourAngle;
    var minutes = 720 - 4 * (longitudeDegrees + delta) - eqTime;

    t = _julianCenturies(jd + minutes / 1440);
    eqTime = _equationOfTimeMinutes(t);
    solarDec = _sunDeclination(t);
    hourAngle = _hourAngleDegrees(latitudeDegrees, solarDec);
    if (hourAngle == null) return null;
    delta = sunrise ? hourAngle : -hourAngle;
    return 720 - 4 * (longitudeDegrees + delta) - eqTime;
  }

  static double _solarNoonUtcMinutes(double jd, double longitudeDegrees) {
    var t = _julianCenturies(jd + longitudeDegrees / 360);
    var eqTime = _equationOfTimeMinutes(t);
    var noon = 720 - 4 * longitudeDegrees - eqTime;
    t = _julianCenturies(jd + noon / 1440);
    eqTime = _equationOfTimeMinutes(t);
    noon = 720 - 4 * longitudeDegrees - eqTime;
    return noon;
  }

  static double? _hourAngleDegrees(double latitudeDegrees, double solarDeclinationDegrees) {
    final cosH = _cosHourAngle(latitudeDegrees, solarDeclinationDegrees);
    if (cosH < -1 || cosH > 1) return null;
    return _radToDeg(math.acos(cosH));
  }

  static double _cosHourAngle(double latitudeDegrees, double solarDeclinationDegrees) {
    final lat = _degToRad(latitudeDegrees);
    final dec = _degToRad(solarDeclinationDegrees);
    final zenith = _degToRad(apparentSunriseZenithDegrees);
    return math.cos(zenith) / (math.cos(lat) * math.cos(dec)) - math.tan(lat) * math.tan(dec);
  }

  static double _equationOfTimeMinutes(double t) {
    final epsilon = _obliquityCorrection(t);
    final l0 = _geomMeanLongSun(t);
    final e = _eccentricityEarthOrbit(t);
    final m = _geomMeanAnomalySun(t);
    final y = math.pow(math.tan(_degToRad(epsilon) / 2), 2).toDouble();

    final sin2l0 = math.sin(2 * _degToRad(l0));
    final sinm = math.sin(_degToRad(m));
    final cos2l0 = math.cos(2 * _degToRad(l0));
    final sin4l0 = math.sin(4 * _degToRad(l0));
    final sin2m = math.sin(2 * _degToRad(m));

    final eTime = y * sin2l0 -
        2 * e * sinm +
        4 * e * y * sinm * cos2l0 -
        0.5 * y * y * sin4l0 -
        1.25 * e * e * sin2m;
    return _radToDeg(eTime) * 4;
  }

  static double _sunDeclination(double t) {
    final e = _obliquityCorrection(t);
    final lambda = _sunApparentLongitude(t);
    return _radToDeg(math.asin(math.sin(_degToRad(e)) * math.sin(_degToRad(lambda))));
  }

  static double _sunApparentLongitude(double t) {
    final trueLong = _sunTrueLongitude(t);
    final omega = 125.04 - 1934.136 * t;
    return trueLong - 0.00569 - 0.00478 * math.sin(_degToRad(omega));
  }

  static double _sunTrueLongitude(double t) => _geomMeanLongSun(t) + _sunEquationOfCenter(t);

  static double _sunEquationOfCenter(double t) {
    final m = _degToRad(_geomMeanAnomalySun(t));
    return math.sin(m) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * m) * (0.019993 - 0.000101 * t) +
        math.sin(3 * m) * 0.000289;
  }

  static double _geomMeanLongSun(double t) => _normalizeDegrees(280.46646 + t * (36000.76983 + 0.0003032 * t));

  static double _geomMeanAnomalySun(double t) => 357.52911 + t * (35999.05029 - 0.0001537 * t);

  static double _eccentricityEarthOrbit(double t) => 0.016708634 - t * (0.000042037 + 0.0000001267 * t);

  static double _meanObliquityOfEcliptic(double t) {
    final seconds = 21.448 - t * (46.815 + t * (0.00059 - t * 0.001813));
    return 23 + (26 + seconds / 60) / 60;
  }

  static double _obliquityCorrection(double t) {
    final e0 = _meanObliquityOfEcliptic(t);
    final omega = 125.04 - 1934.136 * t;
    return e0 + 0.00256 * math.cos(_degToRad(omega));
  }

  static double _julianCenturies(double jd) => (jd - 2451545.0) / 36525.0;

  static void _validateCoordinates(double latitude, double longitude) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw RangeError('Latitude must be within [-90, 90].');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw RangeError('Longitude must be within [-180, 180].');
    }
  }

  static double _normalizeDegrees(double degrees) {
    final value = degrees % 360;
    return value < 0 ? value + 360 : value;
  }

  static double _degToRad(double degrees) => degrees * math.pi / 180;
  static double _radToDeg(double radians) => radians * 180 / math.pi;
}
