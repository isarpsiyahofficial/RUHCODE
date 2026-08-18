import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/lunar/moon_phase.dart';

void main() {
  group('MoonPhaseEngine', () {
    test('classifies canonical phase angles and illumination', () {
      final provider = _FakeEphemerisProvider(sunLongitude: 10, moonLongitude: 10);
      final engine = MoonPhaseEngine(provider);
      final newMoon = engine.calculate(2460000.5);
      expect(newMoon.phase, MoonPhaseName.newMoon);
      expect(newMoon.illuminatedFraction, closeTo(0, 1e-12));

      provider.moonLongitude = 100;
      final firstQuarter = engine.calculate(2460000.5);
      expect(firstQuarter.phase, MoonPhaseName.firstQuarter);
      expect(firstQuarter.phaseAngleDegrees, closeTo(90, 1e-12));
      expect(firstQuarter.illuminatedFraction, closeTo(0.5, 1e-12));

      provider.moonLongitude = 190;
      final fullMoon = engine.calculate(2460000.5);
      expect(fullMoon.phase, MoonPhaseName.fullMoon);
      expect(fullMoon.illuminatedFraction, closeTo(1, 1e-12));

      provider.moonLongitude = 280;
      final lastQuarter = engine.calculate(2460000.5);
      expect(lastQuarter.phase, MoonPhaseName.lastQuarter);
      expect(lastQuarter.illuminatedFraction, closeTo(0.5, 1e-12));
    });

    test('normalizes wraparound and reports waxing/waning', () {
      final provider = _FakeEphemerisProvider(sunLongitude: 350, moonLongitude: 10);
      final waxing = MoonPhaseEngine(provider).calculate(2460000.5);
      expect(waxing.phaseAngleDegrees, closeTo(20, 1e-12));
      expect(waxing.isWaxing, isTrue);

      provider
        ..sunLongitude = 10
        ..moonLongitude = 350;
      final waning = MoonPhaseEngine(provider).calculate(2460000.5);
      expect(waning.phaseAngleDegrees, closeTo(340, 1e-12));
      expect(waning.isWaning, isTrue);
    });

    test('rejects mixed provenance instead of silently combining samples', () {
      final provider = _FakeEphemerisProvider(
        sunLongitude: 0,
        moonLongitude: 180,
        moonVersion: 'other',
      );
      expect(
        () => MoonPhaseEngine(provider).calculate(2460000.5),
        throwsStateError,
      );
    });
  });
}

final class _FakeEphemerisProvider implements EphemerisProvider {
  _FakeEphemerisProvider({
    required this.sunLongitude,
    required this.moonLongitude,
    this.moonVersion = 'fixture-v1',
  });

  double sunLongitude;
  double moonLongitude;
  String moonVersion;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2450000,
        endJdTt: 2470000,
        sourceId: 'fixture',
        dataVersion: 'fixture-v1',
        checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    coverage.requireContains(jdTt);
    if (body != AstroBody.sun && body != AstroBody.moon) {
      throw UnsupportedError('fixture only supports Sun/Moon');
    }
    final isMoon = body == AstroBody.moon;
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: isMoon ? moonLongitude : sunLongitude,
      latitudeDegrees: 0,
      distanceAu: isMoon ? 0.00257 : 1,
      longitudeSpeedDegreesPerDay: isMoon ? 13.2 : 0.9856,
      sourceId: 'fixture',
      dataVersion: isMoon ? moonVersion : 'fixture-v1',
    );
  }
}
