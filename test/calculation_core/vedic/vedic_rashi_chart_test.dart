import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_lagna.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_rashi_chart.dart';

VedicCalculationSnapshot _snapshot() => VedicCalculationSnapshot(
      jdTt: 2451545.0,
      ephemerisSourceId: 'fixture',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
      ayanamshaDegrees: 24,
      placements: const [
        VedicPlacement(
          body: AstroBody.sun,
          siderealLongitudeDegrees: 95,
          longitudeSpeedDegreesPerDay: 1,
        ),
        VedicPlacement(
          body: AstroBody.moon,
          siderealLongitudeDegrees: 185,
          longitudeSpeedDegreesPerDay: 13,
        ),
      ],
    );

VedicLagnaResult _lagna({String version = 'fixture-v1'}) => VedicLagnaResult(
      siderealLongitudeDegrees: 65,
      ayanamshaDegrees: 24,
      localMeanSiderealDegrees: 100,
      meanObliquityDegrees: 23.4,
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: version,
    );

void main() {
  test('RC-0090 builds deterministic Rashi positions', () {
    final chart = VedicRashiChartBuilder.build(snapshot: _snapshot(), lagna: _lagna());
    expect(chart.lagnaRashiIndex, 2);
    expect(chart.placements[0].rashiIndex, 3);
    expect(chart.placements[0].degreesWithinRashi, 5);
    expect(chart.placements[1].rashiIndex, 6);
    expect(chart.placements[1].degreesWithinRashi, 5);
  });

  test('RC-0091 assigns Whole Sign houses from the Lagna Rashi', () {
    final chart = VedicRashiChartBuilder.build(snapshot: _snapshot(), lagna: _lagna());
    expect(chart.placements[0].wholeSignHouse, 2);
    expect(chart.placements[1].wholeSignHouse, 5);
  });

  test('RC-0091 wraps Whole Sign houses across Aries', () {
    final lagna = VedicLagnaResult(
      siderealLongitudeDegrees: 305,
      ayanamshaDegrees: 24,
      localMeanSiderealDegrees: 100,
      meanObliquityDegrees: 23.4,
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
    );
    final snapshot = VedicCalculationSnapshot(
      jdTt: 2451545,
      ephemerisSourceId: 'fixture',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
      ayanamshaDegrees: 24,
      placements: const [
        VedicPlacement(
          body: AstroBody.sun,
          siderealLongitudeDegrees: 5,
          longitudeSpeedDegreesPerDay: 1,
        ),
      ],
    );
    final chart = VedicRashiChartBuilder.build(snapshot: snapshot, lagna: lagna);
    expect(chart.placements.single.wholeSignHouse, 3);
  });

  test('RC-0090/RC-0091 fail closed on ayanamsha provenance mismatch', () {
    expect(
      () => VedicRashiChartBuilder.build(snapshot: _snapshot(), lagna: _lagna(version: 'other')),
      throwsStateError,
    );
  });
}
