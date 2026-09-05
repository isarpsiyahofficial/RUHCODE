import '../ephemeris/ephemeris.dart';

final class PlanetaryReturnResult {
  const PlanetaryReturnResult({
    required this.body,
    required this.jdTt,
    required this.targetLongitudeDegrees,
    required this.actualLongitudeDegrees,
    required this.sourceId,
    required this.dataVersion,
  });

  final AstroBody body;
  final double jdTt;
  final double targetLongitudeDegrees;
  final double actualLongitudeDegrees;
  final String sourceId;
  final String dataVersion;
}

/// Finds the first exact geocentric ecliptic longitude return inside an explicit
/// TT search window. The caller supplies the window; the solver never guesses a
/// calendar period, uses device time, or silently extends ephemeris coverage.
abstract final class WesternPlanetaryReturnSolver {
  static PlanetaryReturnResult findFirst({
    required AstroBody body,
    required double natalLongitudeDegrees,
    required double startJdTt,
    required double endJdTt,
    required EphemerisProvider ephemeris,
    double sampleStepDays = 0.25,
    double longitudeToleranceDegrees = 1e-7,
    int maxBisectionIterations = 80,
  }) {
    _validateInput(
      natalLongitudeDegrees: natalLongitudeDegrees,
      startJdTt: startJdTt,
      endJdTt: endJdTt,
      sampleStepDays: sampleStepDays,
      longitudeToleranceDegrees: longitudeToleranceDegrees,
      maxBisectionIterations: maxBisectionIterations,
    );
    ephemeris.coverage.requireContains(startJdTt);
    ephemeris.coverage.requireContains(endJdTt);

    final target = _normalize360(natalLongitudeDegrees);
    var leftT = startJdTt;
    var left = _sample(ephemeris, body, leftT);
    var leftError = _signedAngularError(left.longitudeDegrees, target);
    if (leftError.abs() <= longitudeToleranceDegrees) {
      return _result(body, target, left, ephemeris);
    }

    while (leftT < endJdTt) {
      final rightT = (leftT + sampleStepDays > endJdTt) ? endJdTt : leftT + sampleStepDays;
      final right = _sample(ephemeris, body, rightT);
      final rightError = _signedAngularError(right.longitudeDegrees, target);
      if (rightError.abs() <= longitudeToleranceDegrees) {
        return _result(body, target, right, ephemeris);
      }

      // A genuine zero crossing has opposite signs without crossing the ±180°
      // branch cut. This prevents a false return when angular error wraps.
      final signChanged = leftError.sign != rightError.sign;
      final branchCutJump = (leftError - rightError).abs() >= 180.0;
      if (signChanged && !branchCutJump) {
        return _bisect(
          body: body,
          target: target,
          leftT: leftT,
          rightT: rightT,
          leftError: leftError,
          ephemeris: ephemeris,
          tolerance: longitudeToleranceDegrees,
          maxIterations: maxBisectionIterations,
        );
      }

      leftT = rightT;
      left = right;
      leftError = rightError;
    }

    throw StateError('No planetary longitude return exists inside the supplied TT window.');
  }

  static PlanetaryReturnResult findSolarReturn({
    required double natalSunLongitudeDegrees,
    required double startJdTt,
    required double endJdTt,
    required EphemerisProvider ephemeris,
    double sampleStepDays = 0.25,
  }) =>
      findFirst(
        body: AstroBody.sun,
        natalLongitudeDegrees: natalSunLongitudeDegrees,
        startJdTt: startJdTt,
        endJdTt: endJdTt,
        ephemeris: ephemeris,
        sampleStepDays: sampleStepDays,
      );

  static PlanetaryReturnResult findLunarReturn({
    required double natalMoonLongitudeDegrees,
    required double startJdTt,
    required double endJdTt,
    required EphemerisProvider ephemeris,
    double sampleStepDays = 0.05,
  }) =>
      findFirst(
        body: AstroBody.moon,
        natalLongitudeDegrees: natalMoonLongitudeDegrees,
        startJdTt: startJdTt,
        endJdTt: endJdTt,
        ephemeris: ephemeris,
        sampleStepDays: sampleStepDays,
      );

  static PlanetaryReturnResult _bisect({
    required AstroBody body,
    required double target,
    required double leftT,
    required double rightT,
    required double leftError,
    required EphemerisProvider ephemeris,
    required double tolerance,
    required int maxIterations,
  }) {
    var lo = leftT;
    var hi = rightT;
    var loError = leftError;
    EclipticState? best;

    for (var i = 0; i < maxIterations; i++) {
      final mid = lo + (hi - lo) / 2.0;
      final state = _sample(ephemeris, body, mid);
      final error = _signedAngularError(state.longitudeDegrees, target);
      best = state;
      if (error.abs() <= tolerance || (hi - lo).abs() <= 1e-10) {
        return _result(body, target, state, ephemeris);
      }
      final sameSign = loError.sign == error.sign;
      if (sameSign) {
        lo = mid;
        loError = error;
      } else {
        hi = mid;
      }
    }

    if (best != null && _signedAngularError(best.longitudeDegrees, target).abs() <= tolerance * 10) {
      return _result(body, target, best, ephemeris);
    }
    throw StateError('Planetary return root did not converge within the configured tolerance.');
  }

  static EclipticState _sample(EphemerisProvider ephemeris, AstroBody body, double jdTt) {
    final state = ephemeris.stateAt(body: body, jdTt: jdTt);
    if (state.body != body ||
        (state.jdTt - jdTt).abs() > 1e-12 ||
        state.sourceId != ephemeris.coverage.sourceId ||
        state.dataVersion != ephemeris.coverage.dataVersion) {
      throw StateError('Return ephemeris result body/instant/provenance mismatch.');
    }
    return state;
  }

  static PlanetaryReturnResult _result(
    AstroBody body,
    double target,
    EclipticState state,
    EphemerisProvider ephemeris,
  ) =>
      PlanetaryReturnResult(
        body: body,
        jdTt: state.jdTt,
        targetLongitudeDegrees: target,
        actualLongitudeDegrees: state.longitudeDegrees,
        sourceId: ephemeris.coverage.sourceId,
        dataVersion: ephemeris.coverage.dataVersion,
      );

  static double _signedAngularError(double actual, double target) {
    var value = _normalize360(actual) - _normalize360(target);
    if (value >= 180) value -= 360;
    if (value < -180) value += 360;
    return value;
  }

  static double _normalize360(double value) {
    var normalized = value % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized;
  }

  static void _validateInput({
    required double natalLongitudeDegrees,
    required double startJdTt,
    required double endJdTt,
    required double sampleStepDays,
    required double longitudeToleranceDegrees,
    required int maxBisectionIterations,
  }) {
    if (!natalLongitudeDegrees.isFinite) {
      throw ArgumentError('Natal longitude must be finite.');
    }
    if (!startJdTt.isFinite || !endJdTt.isFinite || startJdTt >= endJdTt) {
      throw RangeError('Return TT search window must be finite and increasing.');
    }
    if (!sampleStepDays.isFinite || sampleStepDays <= 0) {
      throw RangeError('Return sample step must be positive and finite.');
    }
    if (!longitudeToleranceDegrees.isFinite || longitudeToleranceDegrees <= 0) {
      throw RangeError('Return longitude tolerance must be positive and finite.');
    }
    if (maxBisectionIterations <= 0) {
      throw RangeError('Return bisection iteration limit must be positive.');
    }
  }
}
