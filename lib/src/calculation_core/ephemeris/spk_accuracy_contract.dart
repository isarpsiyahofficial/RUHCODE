import 'dart:math' as math;

import 'spk_type2_evaluator.dart';

/// Measurable accuracy contract for raw DE440s Cartesian state validation.
///
/// This contract is intentionally narrower than the complete RC-1436 contract:
/// it validates the packaged ephemeris state against an independent geometric
/// NASA/JPL Horizons state expressed in the same ICRF/J2000 frame and KM-S
/// units. Planetary longitude, ASC/MC, house cusp, sunrise/sunset,
/// planetary-hour and Nakshatra/Pada tolerances remain separate release gates.
final class SpkStateAccuracyContract {
  const SpkStateAccuracyContract({
    this.maxPositionAxisErrorKm = 0.001,
    this.maxVelocityAxisErrorKmPerSecond = 1e-9,
  })  : assert(maxPositionAxisErrorKm > 0),
        assert(maxVelocityAxisErrorKmPerSecond > 0);

  /// One metre per Cartesian position axis.
  final double maxPositionAxisErrorKm;

  /// 1e-6 m/s per Cartesian velocity axis.
  final double maxVelocityAxisErrorKmPerSecond;

  SpkStateAccuracyResult compare({
    required SpkCartesianState actual,
    required SpkCartesianState expected,
  }) {
    final actualValues = _values(actual);
    final expectedValues = _values(expected);
    if ([...actualValues, ...expectedValues].any((value) => !value.isFinite)) {
      throw const FormatException(
        'SPK accuracy comparison requires finite actual and expected states.',
      );
    }

    final positionErrors = List<double>.generate(
      3,
      (index) => (actualValues[index] - expectedValues[index]).abs(),
      growable: false,
    );
    final velocityErrors = List<double>.generate(
      3,
      (index) => (actualValues[index + 3] - expectedValues[index + 3]).abs(),
      growable: false,
    );

    final maxPositionError = positionErrors.reduce(math.max);
    final maxVelocityError = velocityErrors.reduce(math.max);
    return SpkStateAccuracyResult(
      maxPositionAxisErrorKm: maxPositionError,
      maxVelocityAxisErrorKmPerSecond: maxVelocityError,
      positionAxisErrorsKm: positionErrors,
      velocityAxisErrorsKmPerSecond: velocityErrors,
      passed: maxPositionError <= maxPositionAxisErrorKm &&
          maxVelocityError <= maxVelocityAxisErrorKmPerSecond,
    );
  }

  void requireWithinTolerance({
    required SpkCartesianState actual,
    required SpkCartesianState expected,
  }) {
    final result = compare(actual: actual, expected: expected);
    if (!result.passed) {
      throw StateError(
        'DE440s/JPL state mismatch: maxPositionAxisErrorKm='
        '${result.maxPositionAxisErrorKm} (limit=$maxPositionAxisErrorKm), '
        'maxVelocityAxisErrorKmPerSecond='
        '${result.maxVelocityAxisErrorKmPerSecond} '
        '(limit=$maxVelocityAxisErrorKmPerSecond).',
      );
    }
  }

  static List<double> _values(SpkCartesianState state) => <double>[
        state.xKm,
        state.yKm,
        state.zKm,
        state.vxKmPerSecond,
        state.vyKmPerSecond,
        state.vzKmPerSecond,
      ];
}

final class SpkStateAccuracyResult {
  const SpkStateAccuracyResult({
    required this.maxPositionAxisErrorKm,
    required this.maxVelocityAxisErrorKmPerSecond,
    required this.positionAxisErrorsKm,
    required this.velocityAxisErrorsKmPerSecond,
    required this.passed,
  });

  final double maxPositionAxisErrorKm;
  final double maxVelocityAxisErrorKmPerSecond;
  final List<double> positionAxisErrorsKm;
  final List<double> velocityAxisErrorsKmPerSecond;
  final bool passed;
}
