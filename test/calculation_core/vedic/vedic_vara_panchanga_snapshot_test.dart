import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_panchanga_snapshot.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_vara.dart';

void main() {
  test('RC-0114 uses the previous sunrise weekday, not civil midnight', () {
    final result = VedicVaraCalculator.calculate(
      queryJdUt1: 2451545.0,
      latitudeDegrees: 0,
      longitudeDegrees: 0,
      sunriseProvider: const _FixedSunrise(2451544.75),
    );
    expect(result.vara, VedicVara.shanivara);
    expect(result.sunriseJdUt1, 2451544.75);
  });

  test('RC-0112 assembles all five Panchanga limbs', () {
    final snapshot = VedicPanchangaAssembler.calculate(
      vedicSnapshot: _snapshot(),
      queryJdUt1: 2451545.0,
      latitudeDegrees: 12,
      longitudeDegrees: 77,
      sunriseProvider: const _FixedSunrise(2451544.75),
    );
    expect(snapshot.core.tithiIndex, 2);
    expect(snapshot.core.nakshatraIndex, 2);
    expect(snapshot.core.yogaIndex, 3);
    expect(snapshot.core.karanaHalfTithiIndex, 3);
    expect(snapshot.vara.vara, VedicVara.shanivara);
  });

  test('Vara fails closed when provider returns a future sunrise', () {
    expect(
      () => VedicVaraCalculator.calculate(
        queryJdUt1: 2451545.0,
        latitudeDegrees: 0,
        longitudeDegrees: 0,
        sunriseProvider: const _FixedSunrise(2451545.1),
      ),
      throwsStateError,
    );
  });
}

VedicCalculationSnapshot _snapshot() => VedicCalculationSnapshot(
      jdTt: 2451545.0008,
      ephemerisSourceId: 'fixture-ephemeris',
      ephemerisDataVersion: '1',
      ayanamshaId: 'fixture-lahiri',
      ayanamshaDataVersion: '1',
      ayanamshaDegrees: 24,
      placements: const <VedicPlacement>[
        VedicPlacement(
          body: AstroBody.sun,
          siderealLongitudeDegrees: 10,
          longitudeSpeedDegreesPerDay: 1,
        ),
        VedicPlacement(
          body: AstroBody.moon,
          siderealLongitudeDegrees: 25,
          longitudeSpeedDegreesPerDay: 13,
        ),
      ],
    );

final class _FixedSunrise implements SunriseBoundaryProvider {
  const _FixedSunrise(this.jdUt1);
  final double jdUt1;

  @override
  SunriseBoundary previousSunrise({
    required double queryJdUt1,
    required double latitudeDegrees,
    required double longitudeDegrees,
  }) => SunriseBoundary(
        jdUt1: jdUt1,
        sourceId: 'fixture-sunrise',
        dataVersion: '1',
      );
}
