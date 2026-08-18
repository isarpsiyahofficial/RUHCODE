import 'daily_snapshot.dart';
import '../vedic/vedic_daily_indicators.dart';

abstract final class VedicIndicatorDailyFactor {
  static DailyFactorReference fromResult({
    required VedicDailyIndicators indicators,
  }) {
    final resultId = <String>[
      'vedic-daily',
      'nakshatra-${indicators.nakshatraIndex}',
      'pada-${indicators.pada}',
      'tithi-${indicators.tithiIndex}',
      'paksha-${indicators.paksha.name}',
      'ayanamsha-${indicators.ayanamshaId}@${indicators.ayanamshaVersion}',
    ].join('|');

    return DailyFactorReference(
      kind: DailyFactorKind.vedicIndicator,
      sourceEngineId: indicators.sourceId,
      sourceEngineVersion: indicators.sourceVersion,
      resultId: resultId,
    );
  }
}
