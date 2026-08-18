import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/vedic_indicator_factor.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_daily_indicators.dart';

void main() {
  test('Vedic result becomes one deterministic DailySnapshot factor', () {
    final result = VedicDailyIndicatorsEngine.calculate(
      tropicalSunLongitudeDegrees: 120,
      tropicalMoonLongitudeDegrees: 150,
      ayanamshaDegrees: 24,
      sourceId: 'ephemeris-source',
      sourceVersion: '2026.08',
      ayanamshaId: 'lahiri',
      ayanamshaVersion: 'v1',
    );

    final factor = VedicIndicatorDailyFactor.fromResult(indicators: result);

    expect(factor.kind, DailyFactorKind.vedicIndicator);
    expect(factor.sourceEngineId, 'ephemeris-source');
    expect(factor.sourceEngineVersion, '2026.08');
    expect(factor.resultId, contains('nakshatra-'));
    expect(factor.resultId, contains('pada-'));
    expect(factor.resultId, contains('tithi-'));
    expect(factor.resultId, contains('ayanamsha-lahiri@v1'));
  });
}
