import 'dart:math' as math;

import 'asc_mc.dart';
import 'porphyry_houses.dart';

enum PlacidusResultStatus { success, unavailable, fallback }

enum PlacidusFallbackPolicy { none, explicitPorphyry }

final class PlacidusHouseCusps {
  PlacidusHouseCusps._({
    required List<double> cusps,
    required this.iterationsUsed,
  }) : cusps = List<double>.unmodifiable(cusps) {
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
    for (var index = 0; index < 12; index++) {
      final start = cusps[index];
      final end = cusps[(index + 1) % 12];
      final span = _forwardArc(start, end);
      final offset = _forwardArc(start, longitude);
      if (offset < span) return index + 1;
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
/// The four intermediate northern cusps are solved from the fraction of the
/// semidiurnal/seminocturnal arc completed by an ecliptic point. The equations
/// are implicit because the point's declination changes with longitude, so the
/// solver iterates until the longitude converges or the 100-iteration ceiling
/// is reached. No invented polar cusps are produced.
///
/// Porphyry fallback is available only when callers request it explicitly; the
/// returned metadata always exposes the effective house system.
abstract final class PlacidusHouses {
  static const int maxIterations = 100;
  static const double convergenceDegrees = 1e-10;

  static PlacidusHouseResult calculate({
    required AscMcResult angles,
    required double latitudeDegreesNorth,
    PlacidusFallbackPolicy fallbackPolicy = PlacidusFallbackPolicy.none,
  }) {
    _finite(latitudeDegreesNorth, 'latitudeDegreesNorth');
    if (latitudeDegreesNorth <= -90.0 || latitudeDegreesNorth >= 90.0) {
      throw RangeError.range(
        latitudeDegreesNorth,
        -89.999999999,
        89.999999999,
        'latitudeDegreesNorth',
      );
    }

    final polarLimit = 90.0 - angles.meanObliquityDegrees;
    if (latitudeDegreesNorth.abs() >= polarLimit) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus ecliptic cusps are undefined beyond the polar circle.',
      );
    }

    final upper11 = _solveCusp(
      localSiderealDegrees: angles.localMeanSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: angles.meanObliquityDegrees,
      phase: _ArcPhase.diurnal,
      fractionCompleted: 2.0 / 3.0,
      initialLongitude: _normalize(angles.midheavenDegrees + 30.0),
    );
    final upper12 = _solveCusp(
      localSiderealDegrees: angles.localMeanSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: angles.meanObliquityDegrees,
      phase: _ArcPhase.diurnal,
      fractionCompleted: 1.0 / 3.0,
      initialLongitude: _normalize(angles.midheavenDegrees + 60.0),
    );
    final lower2 = _solveCusp(
      localSiderealDegrees: angles.localMeanSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: angles.meanObliquityDegrees,
      phase: _ArcPhase.seminocturnal,
      fractionCompleted: 2.0 / 3.0,
      initialLongitude: _normalize(angles.ascendantDegrees + 30.0),
    );
    final lower3 = _solveCusp(
      localSiderealDegrees: angles.localMeanSiderealDegrees,
      latitudeDegreesNorth: latitudeDegreesNorth,
      obliquityDegrees: angles.meanObliquityDegrees,
      phase: _ArcPhase.seminocturnal,
      fractionCompleted: 1.0 / 3.0,
      initialLongitude: _normalize(angles.ascendantDegrees + 60.0),
    );

    final solved = <_SolvedCusp?>[upper11, upper12, lower2, lower3];
    if (solved.any((value) => value == null)) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus iterative cusp solver did not converge within $maxIterations iterations.',
      );
    }

    final c11 = upper11!.longitude;
    final c12 = upper12!.longitude;
    final c2 = lower2!.longitude;
    final c3 = lower3!.longitude;
    final asc = angles.ascendantDegrees;
    final mc = angles.midheavenDegrees;
    final dsc = _normalize(asc + 180.0);
    final ic = _normalize(mc + 180.0);

    final cusps = <double>[
      asc,
      c2,
      c3,
      ic,
      _normalize(c11 + 180.0),
      _normalize(c12 + 180.0),
      dsc,
      _normalize(c2 + 180.0),
      _normalize(c3 + 180.0),
      mc,
      c11,
      c12,
    ];

    if (!_isOrderedHouseCycle(cusps)) {
      return _unavailableOrFallback(
        angles: angles,
        fallbackPolicy: fallbackPolicy,
        reason: 'Placidus solution produced non-monotonic ecliptic cusp geometry.',
      );
    }

    final maxUsed = solved.whereType<_SolvedCusp>().map((e) => e.iterations).reduce(math.max);
    return PlacidusHouseResult._(
      status: PlacidusResultStatus.success,
      requestedSystem: 'PLACIDUS',
      effectiveSystem: 'PLACIDUS',
      reason: null,
      placidus: PlacidusHouseCusps._(cusps: cusps, iterationsUsed: maxUsed),
    );
  }

  static PlacidusHouseResult _unavailableOrFallback({
    required AscMcResult angles,
    required PlacidusFallbackPolicy fallbackPolicy,
    required String reason,
  }) {
    if (fallbackPolicy == PlacidusFallbackPolicy.explicitPorphyry) {
      final fallback = PorphyryHouses.calculate(
        ascendantLongitude: angles.ascendantDegrees,
        midheavenLongitude: angles.midheavenDegrees,
      );
      return PlacidusHouseResult._(
        status: PlacidusResultStatus.fallback,
        requestedSystem: 'PLACIDUS',
        effectiveSystem: 'PORPHYRY',
        reason: reason,
        porphyry: fallback,
      );
    }
    return PlacidusHouseResult._(
      status: PlacidusResultStatus.unavailable,
      requestedSystem: 'PLACIDUS',
      effectiveSystem: 'UNAVAILABLE',
      reason: reason,
    );
  }

  static _SolvedCusp? _solveCusp({
    required double localSiderealDegrees,
    required double latitudeDegreesNorth,
    required double obliquityDegrees,
    required _ArcPhase phase,
    required double fractionCompleted,
    required double initialLongitude,
  }) {
    var longitude = _normalize(initialLongitude);
    final latitude = _radians(latitudeDegreesNorth);
    final epsilon = _radians(obliquityDegrees);

    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final lambda = _radians(longitude);
      final declination = math.asin(math.sin(epsilon) * math.sin(lambda));
      final riseSetCosine = -math.tan(latitude) * math.tan(declination);
      if (!riseSetCosine.isFinite || riseSetCosine.abs() > 1.0) return null;

      final semiDiurnal = _degrees(math.acos(riseSetCosine.clamp(-1.0, 1.0)));
      final targetHourAngle = switch (phase) {
        _ArcPhase.diurnal => -(1.0 - fractionCompleted) * semiDiurnal,
        _ArcPhase.seminocturnal =>
          -180.0 + fractionCompleted * (180.0 - semiDiurnal),
      };

      final targetRa = _normalize(localSiderealDegrees - targetHourAngle);
      final alpha = _radians(targetRa);
      final next = _normalize(_degrees(math.atan2(
        math.sin(alpha) / math.cos(epsilon),
        math.cos(alpha),
      )));

      if (_angularDistance(longitude, next) <= convergenceDegrees) {
        return _SolvedCusp(longitude: next, iterations: iteration);
      }
      longitude = next;
    }
    return null;
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

enum _ArcPhase { diurnal, seminocturnal }

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
