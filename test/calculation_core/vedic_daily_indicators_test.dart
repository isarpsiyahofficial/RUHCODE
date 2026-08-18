import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/ayanamsha.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_daily_indicators.dart';

void main() {
  VedicDailyIndicators calculate({
    required double sun,
    required double moon,
    double ayanamsha = 0,
  }) {
    return VedicDailyIndicatorsEngine.calculate(
      tropicalSunLongitudeDegrees: sun,
      tropicalMoonLongitudeDegrees: moon,
      ayanamshaDegrees: ayanamsha,
      sourceId: 'test-ephemeris',
      sourceVersion: '1',
      ayanamshaId: 'lahiri-test',
      ayanamshaVersion: '1',
    );
  }

  test('nakshatra and pada are one-based and boundary deterministic', () {
    final first = calculate(sun: 0, moon: 0);
    expect(first.nakshatraIndex, 1);
    expect(first.pada, 1);

    final beforeFirstNakshatraEnd = calculate(
      sun: 0,
      moon: (360 / 27) - 1e-8,
    );
    expect(beforeFirstNakshatraEnd.nakshatraIndex, 1);
    expect(beforeFirstNakshatraEnd.pada, 4);

    final second = calculate(sun: 0, moon: 360 / 27);
    expect(second.nakshatraIndex, 2);
    expect(second.pada, 1);

    final finalBoundary = calculate(sun: 0, moon: 359.999999);
    expect(finalBoundary.nakshatraIndex, 27);
    expect(finalBoundary.pada, 4);
  });

  test('ayanamsha subtraction wraps negative sidereal longitude', () {
    final result = calculate(sun: 10, moon: 5, ayanamsha: 24);
    expect(result.siderealSunLongitudeDegrees, closeTo(346, 1e-12));
    expect(result.siderealMoonLongitudeDegrees, closeTo(341, 1e-12));
  });

  test('provider path binds TT instant and ayanamsha provenance', () {
    const sha = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
    final provider = TabulatedAyanamshaProvider(
      sourceId: 'lahiri-independent-fixture',
      sourceVersion: 'fixture-v1',
      dataSha256: sha,
      samples: const [
        AyanamshaSample(julianDayTt: 2451545.0, degrees: 24.0),
        AyanamshaSample(julianDayTt: 2451546.0, degrees: 24.01),
      ],
    );

    final result = VedicDailyIndicatorsEngine.calculateWithProvider(
      julianDayTt: 2451545.5,
      tropicalSunLongitudeDegrees: 10,
      tropicalMoonLongitudeDegrees: 5,
      sourceId: 'test-ephemeris',
      sourceVersion: '1',
      ayanamshaProvider: provider,
    );

    expect(result.siderealSunLongitudeDegrees, closeTo(345.995, 1e-12));
    expect(result.siderealMoonLongitudeDegrees, closeTo(340.995, 1e-12));
    expect(result.ayanamshaId, 'lahiri-independent-fixture');
    expect(result.ayanamshaVersion, 'fixture-v1');
  });

  test('provider path refuses ayanamsha extrapolation', () {
    const sha = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
    final provider = TabulatedAyanamshaProvider(
      sourceId: 'source',
      sourceVersion: '1',
      dataSha256: sha,
      samples: const [
        AyanamshaSample(julianDayTt: 2451545.0, degrees: 24.0),
        AyanamshaSample(julianDayTt: 2451546.0, degrees: 24.01),
      ],
    );

    expect(
      () => VedicDailyIndicatorsEngine.calculateWithProvider(
        julianDayTt: 2451544.9,
        tropicalSunLongitudeDegrees: 10,
        tropicalMoonLongitudeDegrees: 5,
        sourceId: 'test-ephemeris',
        sourceVersion: '1',
        ayanamshaProvider: provider,
      ),
      throwsRangeError,
    );
  });

  test('tithi uses 12 degree elongation with paksha boundary', () {
    final first = calculate(sun: 0, moon: 0);
    expect(first.tithiIndex, 1);
    expect(first.tithiInPaksha, 1);
    expect(first.paksha, VedicPaksha.shukla);

    final fifteenth = calculate(sun: 0, moon: 168);
    expect(fifteenth.tithiIndex, 15);
    expect(fifteenth.tithiInPaksha, 15);
    expect(fifteenth.paksha, VedicPaksha.shukla);

    final sixteenth = calculate(sun: 0, moon: 180);
    expect(sixteenth.tithiIndex, 16);
    expect(sixteenth.tithiInPaksha, 1);
    expect(sixteenth.paksha, VedicPaksha.krishna);

    final thirtieth = calculate(sun: 0, moon: 359.999999);
    expect(thirtieth.tithiIndex, 30);
    expect(thirtieth.tithiInPaksha, 15);
    expect(thirtieth.paksha, VedicPaksha.krishna);
  });

  test('provenance is mandatory', () {
    expect(
      () => VedicDailyIndicatorsEngine.calculate(
        tropicalSunLongitudeDegrees: 0,
        tropicalMoonLongitudeDegrees: 0,
        ayanamshaDegrees: 0,
        sourceId: '',
        sourceVersion: '1',
        ayanamshaId: 'lahiri',
        ayanamshaVersion: '1',
      ),
      throwsArgumentError,
    );
  });
}
