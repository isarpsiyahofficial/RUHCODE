import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/moon_sign_factor.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/lunar/moon_sign.dart';

void main() {
  group('MoonSignEngine', () {
    test('maps exact tropical 30-degree boundaries deterministically', () {
      final provider = _MoonProvider(0);
      final engine = MoonSignEngine(provider);
      expect(engine.calculate(2460000.5).sign, TropicalZodiacSign.aries);

      provider.longitude = 29.999999;
      final lateAries = engine.calculate(2460000.5);
      expect(lateAries.sign, TropicalZodiacSign.aries);
      expect(lateAries.degreeWithinSign, closeTo(29.999999, 1e-9));

      provider.longitude = 30;
      final taurus = engine.calculate(2460000.5);
      expect(taurus.sign, TropicalZodiacSign.taurus);
      expect(taurus.degreeWithinSign, closeTo(0, 1e-12));

      provider.longitude = 180;
      expect(engine.calculate(2460000.5).sign, TropicalZodiacSign.libra);

      provider.longitude = 359.999999;
      expect(engine.calculate(2460000.5).sign, TropicalZodiacSign.pisces);
    });

    test('DailySnapshot factor preserves exact provenance', () {
      final factor = MoonSignDailyFactor(
        engineVersion: 'moon-sign-1',
        ephemeris: _MoonProvider(95.25),
      ).build(jdTt: 2460000.5);
      expect(factor.kind, DailyFactorKind.moonSign);
      expect(factor.sourceEngineId, 'moon_sign_tropical');
      expect(factor.resultId, contains('cancer'));
      expect(factor.resultId, contains('95.250000|5.250000|fixture|fixture-v1'));
    });
  });
}

final class _MoonProvider implements EphemerisProvider {
  _MoonProvider(this.longitude);
  double longitude;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2450000,
        endJdTt: 2470000,
        sourceId: 'fixture',
        dataVersion: 'fixture-v1',
        checksumSha256: 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    if (body != AstroBody.moon) throw UnsupportedError('Moon fixture only');
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 0.00257,
      longitudeSpeedDegreesPerDay: 13.2,
      sourceId: 'fixture',
      dataVersion: 'fixture-v1',
    );
  }
}
