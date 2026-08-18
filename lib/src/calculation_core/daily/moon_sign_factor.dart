import '../ephemeris/ephemeris.dart';
import '../lunar/moon_sign.dart';
import 'daily_snapshot.dart';

final class MoonSignDailyFactor {
  const MoonSignDailyFactor({
    required this.engineVersion,
    required this.ephemeris,
  });

  final String engineVersion;
  final EphemerisProvider ephemeris;

  DailyFactorReference build({required double jdTt}) {
    if (engineVersion.trim().isEmpty) {
      throw StateError('Moon sign engine version is required.');
    }
    final result = MoonSignEngine(ephemeris).calculate(jdTt);
    final resultId = <String>[
      'moon-sign',
      result.sign.name,
      result.longitudeDegrees.toStringAsFixed(6),
      result.degreeWithinSign.toStringAsFixed(6),
      result.sourceId,
      result.dataVersion,
    ].join('|');

    return DailyFactorReference(
      kind: DailyFactorKind.moonSign,
      sourceEngineId: 'moon_sign_tropical',
      sourceEngineVersion: engineVersion,
      resultId: resultId,
    );
  }
}
