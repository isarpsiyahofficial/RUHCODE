import '../ephemeris/ephemeris.dart';
import '../lunar/moon_phase.dart';
import 'daily_snapshot.dart';

final class MoonPhaseDailyFactor {
  const MoonPhaseDailyFactor({
    required this.engineVersion,
    required this.ephemeris,
  });

  final String engineVersion;
  final EphemerisProvider ephemeris;

  DailyFactorReference build({required double jdTt}) {
    if (engineVersion.trim().isEmpty) {
      throw StateError('Moon phase engine version is required.');
    }
    final result = MoonPhaseEngine(ephemeris).calculate(jdTt);
    final angle = result.phaseAngleDegrees.toStringAsFixed(6);
    final illumination = result.illuminatedFraction.toStringAsFixed(6);
    final resultId = <String>[
      'moon-phase',
      result.phase.name,
      angle,
      illumination,
      result.sourceId,
      result.dataVersion,
    ].join('|');

    return DailyFactorReference(
      kind: DailyFactorKind.moonPhase,
      sourceEngineId: 'moon_phase',
      sourceEngineVersion: engineVersion,
      resultId: resultId,
    );
  }
}
