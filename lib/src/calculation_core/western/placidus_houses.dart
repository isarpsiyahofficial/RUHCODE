import 'dart:math' as math;

import 'asc_mc.dart';
import 'porphyry_houses.dart';

enum PlacidusResultStatus { success, unavailable, fallback }
enum PlacidusFallbackPolicy { none, explicitPorphyry }

final class PlacidusHouseCusps {
  PlacidusHouseCusps._({required List<double> cusps, required this.iterationsUsed})
      : cusps = List<double>.unmodifiable(cusps) {
    if (cusps.length != 12) {
      throw ArgumentError.value(cusps.length, 'cusps.length', 'Expected 12 house cusps.');
    }
    for (final cusp in cusps) {
      _requireLongitude(cusp, 'cusp');
    }
  }

  final List<double> cusps;
  final int iterationsUsed;

  double cusp(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw RangeError.range(houseNumber, 1, 12, 'houseNumber');
    }
    return cusps[houseNumber - 1];
  }

  int houseForLongitude(double longitude) {
    _requireLongitude(longitude, 'longitude');
    for (var i = 0; i < 12; i++) {
      final span = _forwardArc(cusps[i], cusps[(i + 1) % 12]);
      if (_forwardArc(cusps[i], longitude) < span) return i + 1;
    }
    throw StateError('Longitude could not be assigned to a Placidus house.');
  }
}

final class PlacidusHouseResult {
  const PlacidusHouseResult._({
    required this.status,
    required this.requestedSystem,
    required this.effectiveSystem,
    required this.reason,
    this.placidus,
    this.porphyry,
  });

  final PlacidusResultStatus status;
  final String requestedSystem;
  final String effectiveSystem;
  final String? reason;
  final PlacidusHouseCusps? placidus;
  final PorphyryHouseCusps? porphyry;

  bool get isAvailable => status != PlacidusResultStatus.unavailable;
}

/// Strict Placidus ecliptic-cusp solver.
///
/// The intermediate cusps are solved with the classical pole-height iteration:
/// each target right ascension is fixed by local sidereal time, while the pole
/// height is repeatedly recomputed from the declination of the current
/// ecliptic longitude. This is an independent implementation of the documented
/// Placidus semidiurnal/seminocturnal-arc geometry; no Swiss Ephemeris runtime
/// code or dependency is used.
///
/// Non-convergence and polar-circle geometry return UNAVAILABLE. Porphyry is
/// available only as an explicit caller-selected fallback and is always visible
/// in result metadata.
abstract final class PlacidusHouses {
  static const int maxIterations = 100;
  static const double convergenceDegrees = 1e-10;
  static const double _tiny = 1e-14;

  static PlacidusHouseResult calculate({
    required AscMcResult angles,
    required double latitudeDegreesNorth,
    PlacidusFallbackPolicy fallbackPolicy = PlacidusFallbackPolicy.none,
  }) {
    _finite(latitudeDegreesNorth, 'latitudeDegreesNorth');
    if (latitudeDegreesNorth <= -90.0 || latitudeDegreesNorth >= 90.0) {
      throw RangeError.value(
        latitudeDegreesNorth,
        'latitudeDegreesNorth',
        'Expected a value strictly between -90 and 90 degrees.',
      );
    }

    final obliquity = angles.meanObliquityDegrees;
    final polarLimit = 90.0 - obliquity;
    if (latitudeDegreesNorth.abs() >= polarLimit) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus ecliptic cusps are undefined beyond the polar circle.',
      );
    }

    final tanLatitude = math.tan(_radians(latitudeDegreesNorth));
    final tanObliquity = math.tan(_radians(obliquity));
    final initialArgument = tanLatitude * tanObliquity;
    if (!initialArgument.isFinite || initialArgument.abs() > 1.0) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus initial pole-height geometry is outside its real domain.',
      );
    }

    final auxiliaryAngle = _degrees(math.asin(initialArgument.clamp(-1.0, 1.0).toDouble()));
    final initialPoleOneThird = _degrees(math.atan(
      math.sin(_radians(auxiliaryAngle / 3.0)) / tanObliquity,
    ));
    final initialPoleTwoThirds = _degrees(math.atan(
      math.sin(_radians(auxiliaryAngle * 2.0 / 3.0)) / tanObliquity,
    ));

    final c11 = _solvePoleHeightCusp(
      targetRightAscensionDegrees: _normalize(angles.localMeanSiderealDegrees + 30.0),
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: obliquity,
      divisor: 3.0,
      initialPoleHeightDegrees: initialPoleOneThird,
    );
    final c12 = _solvePoleHeightCusp(
      targetRightAscensionDegrees: _normalize(angles.localMeanSiderealDegrees + 60.0),
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: obliquity,
      divisor: 1.5,
      initialPoleHeightDegrees: initialPoleTwoThirds,
    );
    final c2 = _solvePoleHeightCusp(
      targetRightAscensionDegrees: _normalize(angles.localMeanSiderealDegrees + 120.0),
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: obliquity,
      divisor: 1.5,
      initialPoleHeightDegrees: initialPoleTwoThirds,
    );
    final c3 = _solvePoleHeightCusp(
      targetRightAscensionDegrees: _normalize(angles.localMeanSiderealDegrees + 150.0),
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: obliquity,
      divisor: 3.0,
      initialPoleHeightDegrees: initialPoleOneThird,
    );

    final solved = <_SolvedCusp?>[c11, c12, c2, c3];
    if (solved.any((cusp) => cusp == null)) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus iterative cusp solver did not converge within $maxIterations iterations.',
      );
    }

    final asc = angles.ascendantDegrees;
    final mc = angles.midheavenDegrees;
    final cusps = <double>[
      asc,
      c2!.longitude,
      c3!.longitude,
      _normalize(mc + 180.0),
      _normalize(c11!.longitude + 180.0),
      _normalize(c12!.longitude + 180.0),
      _normalize(asc + 180.0),
      _normalize(c2.longitude + 180.0),
      _normalize(c3.longitude + 180.0),
      mc,
      c11.longitude,
      c12.longitude,
    ];

    if (!_isOrderedHouseCycle(cusps)) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus solution produced non-monotonic ecliptic cusp geometry.',
      );
    }

    final iterationsUsed = solved.whereType<_SolvedCusp>().fold<int>(
          0,
          (current, cusp) => cusp.iterations > current ? cusp.iterations : current,
        );
    return PlacidusHouseResult._(
      status: PlacidusResultStatus.success,
      requestedSystem: 'PLACIDUS',
      effectiveSystem: 'PLACIDUS',
      reason: null,
      placidus: PlacidusHouseCusps._(cusps: cusps, iterationsUsed: iterationsUsed),
    );
  }

  static _SolvedCusp? _solvePoleHeightCusp({
    required double targetRightAscensionDegrees,
    required double latitudeDegreesNorth,
    required double obliquityDegrees,
    required double divisor,
    required double initialPoleHeightDegrees,
  }) {
    var longitude = _eclipticIntersection(
      rightAscensionDegrees: targetRightAscensionDegrees,
      poleHeightDegrees: initialPoleHeightDegrees,
      obliquityDegrees: obliquityDegrees,
    );
    final tanLatitude = math.tan(_radians(latitudeDegreesNorth));
    final sineObliquity = math.sin(_radians(obliquityDegrees));

    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final declination = math.asin(sineObliquity * math.sin(_radians(longitude)));
      final tanDeclination = math.tan(declination);

      if (tanDeclination.abs() <= _tiny) {
        final next = _normalize(targetRightAscensionDegrees);
        return _SolvedCusp(longitude: next, iterations: iteration);
      }

      final argument = tanLatitude * tanDeclination;
      if (!argument.isFinite || argument.abs() > 1.0) return null;
      final arcAngle = math.asin(argument.clamp(-1.0, 1.0).toDouble());
      final poleHeight = _degrees(math.atan(
        math.sin(arcAngle / divisor) / tanDeclination,
      ));
      final next = _eclipticIntersection(
        rightAscensionDegrees: targetRightAscensionDegrees,
        poleHeightDegrees: poleHeight,
        obliquityDegrees: obliquityDegrees,
      );

      if (_angularDistance(longitude, next) <= convergenceDegrees) {
        return _SolvedCusp(longitude: next, iterations: iteration);
      }
      longitude = next;
    }
    return null;
  }

  /// Intersection longitude between the ecliptic and the great circle defined
  /// by [rightAscensionDegrees] and [poleHeightDegrees]. The quadrant handling
  /// is explicit so the result remains continuous across 0/90/180/270°.
  static double _eclipticIntersection({
    required double rightAscensionDegrees,
    required double poleHeightDegrees,
    required double obliquityDegrees,
  }) {
    final x = _normalize(rightAscensionDegrees);
    final quadrant = (x / 90.0).floor();
    switch (quadrant) {
      case 0:
        return _quadrantIntersection(x, poleHeightDegrees, obliquityDegrees);
      case 1:
        return _normalize(180.0 - _quadrantIntersection(
          180.0 - x,
          -poleHeightDegrees,
          obliquityDegrees,
        ));
      case 2:
        return _normalize(180.0 + _quadrantIntersection(
          x - 180.0,
          -poleHeightDegrees,
          obliquityDegrees,
        ));
      default:
        return _normalize(360.0 - _quadrantIntersection(
          360.0 - x,
          poleHeightDegrees,
          obliquityDegrees,
        ));
    }
  }

  static double _quadrantIntersection(
    double rightAscensionDegrees,
    double poleHeightDegrees,
    double obliquityDegrees,
  ) {
    final x = _radians(rightAscensionDegrees);
    final pole = _radians(poleHeightDegrees);
    final epsilon = _radians(obliquityDegrees);
    final numerator = math.sin(x);
    final denominator = -math.tan(pole) * math.sin(epsilon) +
        math.cos(epsilon) * math.cos(x);
    if (numerator.abs() <= _tiny) return 0.0;
    if (denominator.abs() <= _tiny) return 90.0;
    var angle = _degrees(math.atan(numerator / denominator));
    if (angle < 0.0) angle += 180.0;
    return angle;
  }

  static PlacidusHouseResult _unavailableOrFallback({
    required AscMcResult angles,
    required PlacidusFallbackPolicy fallbackPolicy,
    required String reason,
  }) {
    if (fallbackPolicy == PlacidusFallbackPolicy.explicitPorphyry) {
      return PlacidusHouseResult._(
        status: PlacidusResultStatus.fallback,
        requestedSystem: 'PLACIDUS',
        effectiveSystem: 'PORPHYRY',
        reason: reason,
        porphyry: PorphyryHouses.calculate(
          ascendantLongitude: angles.ascendantDegrees,
          midheavenLongitude: angles.midheavenDegrees,
        ),
      );
    }
    return PlacidusHouseResult._(
      status: PlacidusResultStatus.unavailable,
      requestedSystem: 'PLACIDUS',
      effectiveSystem: 'UNAVAILABLE',
      reason: reason,
    );
  }

  static bool _isOrderedHouseCycle(List<double> cusps) {
    var total = 0.0;
    for (var i = 0; i < cusps.length; i++) {
      final span = _forwardArc(cusps[i], cusps[(i + 1) % cusps.length]);
      if (!span.isFinite || span <= 0.0 || span >= 180.0) return false;
      total += span;
    }
    return (total - 360.0).abs() < 1e-7;
  }
}

final class _SolvedCusp {
  const _SolvedCusp({required this.longitude, required this.iterations});
  final double longitude;
  final int iterations;
}

double _forwardArc(double start, double end) => _normalize(end - start);

double _angularDistance(double a, double b) {
  final d = (_normalize(a) - _normalize(b)).abs();
  return math.min(d, 360.0 - d);
}

double _normalize(double degrees) {
  final normalized = degrees % 360.0;
  return normalized < 0 ? normalized + 360.0 : normalized;
}

double _radians(double degrees) => degrees * math.pi / 180.0;
double _degrees(double radians) => radians * 180.0 / math.pi;

void _finite(double value, String name) {
  if (!value.isFinite) {
    throw ArgumentError.value(value, name, 'Expected a finite value.');
  }
}

void _requireLongitude(double value, String name) {
  if (!value.isFinite || value < 0.0 || value >= 360.0) {
    throw ArgumentError.value(value, name, 'Expected longitude in [0, 360).');
  }
}
