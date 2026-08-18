import 'dart:math' as math;

import '../ephemeris/ephemeris.dart';

enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

final class MoonPhaseResult {
  const MoonPhaseResult({
    required this.jdTt,
    required this.phaseAngleDegrees,
    required this.illuminatedFraction,
    required this.phase,
    required this.sourceId,
    required this.dataVersion,
  });

  final double jdTt;
  final double phaseAngleDegrees;
  final double illuminatedFraction;
  final MoonPhaseName phase;
  final String sourceId;
  final String dataVersion;

  bool get isWaxing => phaseAngleDegrees > 0 && phaseAngleDegrees < 180;
  bool get isWaning => phaseAngleDegrees > 180 && phaseAngleDegrees < 360;
}

final class MoonPhaseEngine {
  const MoonPhaseEngine(this.ephemeris);

  final EphemerisProvider ephemeris;

  MoonPhaseResult calculate(double jdTt) {
    ephemeris.coverage.requireContains(jdTt);
    final sun = ephemeris.stateAt(body: AstroBody.sun, jdTt: jdTt);
    final moon = ephemeris.stateAt(body: AstroBody.moon, jdTt: jdTt);

    _requireMatchingSample(sun, moon, jdTt);

    final angle = _normalizeDegrees(moon.longitudeDegrees - sun.longitudeDegrees);
    final radians = angle * math.pi / 180.0;
    final illuminated = (1.0 - math.cos(radians)) / 2.0;

    return MoonPhaseResult(
      jdTt: jdTt,
      phaseAngleDegrees: angle,
      illuminatedFraction: illuminated.clamp(0.0, 1.0).toDouble(),
      phase: _phaseForAngle(angle),
      sourceId: sun.sourceId,
      dataVersion: sun.dataVersion,
    );
  }

  static void _requireMatchingSample(EclipticState sun, EclipticState moon, double jdTt) {
    const epsilon = 1e-9;
    if ((sun.jdTt - jdTt).abs() > epsilon || (moon.jdTt - jdTt).abs() > epsilon) {
      throw StateError('Moon phase requires Sun and Moon states at the exact requested TT instant.');
    }
    if (sun.sourceId != moon.sourceId || sun.dataVersion != moon.dataVersion) {
      throw StateError('Moon phase cannot mix ephemeris source/version provenance.');
    }
  }

  static MoonPhaseName _phaseForAngle(double angle) {
    if (angle < 22.5 || angle >= 337.5) return MoonPhaseName.newMoon;
    if (angle < 67.5) return MoonPhaseName.waxingCrescent;
    if (angle < 112.5) return MoonPhaseName.firstQuarter;
    if (angle < 157.5) return MoonPhaseName.waxingGibbous;
    if (angle < 202.5) return MoonPhaseName.fullMoon;
    if (angle < 247.5) return MoonPhaseName.waningGibbous;
    if (angle < 292.5) return MoonPhaseName.lastQuarter;
    return MoonPhaseName.waningCrescent;
  }

  static double _normalizeDegrees(double value) {
    final normalized = value % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }
}
