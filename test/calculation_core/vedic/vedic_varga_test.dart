import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_varga.dart';

VedicCalculationSnapshot _snapshot(double longitude) => VedicCalculationSnapshot(
      jdTt: 2451545.0,
      ephemerisSourceId: 'fixture',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
      ayanamshaDegrees: 24,
      placements: [
        VedicPlacement(
          body: AstroBody.sun,
          siderealLongitudeDegrees: longitude,
          longitudeSpeedDegreesPerDay: 1,
        ),
      ],
    );

void main() {
  test('RC-0092 Navamsa D9 uses movable/fixed/dual start rules', () {
    expect(VedicVargaBuilder.navamsaD9(_snapshot(1)).placements.single.vargaRashiIndex, 0);
    expect(VedicVargaBuilder.navamsaD9(_snapshot(31)).placements.single.vargaRashiIndex, 9);
    expect(VedicVargaBuilder.navamsaD9(_snapshot(61)).placements.single.vargaRashiIndex, 6);
  });

  test('RC-0092 Navamsa advances one sign per 3d20m division', () {
    final chart = VedicVargaBuilder.navamsaD9(_snapshot(10.1));
    final p = chart.placements.single;
    expect(p.division, 9);
    expect(p.divisionIndex, 3);
    expect(p.vargaRashiIndex, 3);
  });

  test('RC-0092 Navamsa preserves exact final-segment wrap', () {
    final p = VedicVargaBuilder.navamsaD9(_snapshot(359.999)).placements.single;
    expect(p.divisionIndex, 8);
    expect(p.vargaRashiIndex, 11);
    expect(p.degreesWithinVargaRashi, lessThan(30));
  });

  test('RC-0093 Hora D2 maps odd sign halves to Sun then Moon', () {
    expect(VedicVargaBuilder.horaD2(_snapshot(5)).placements.single.vargaRashiIndex, 4);
    expect(VedicVargaBuilder.horaD2(_snapshot(20)).placements.single.vargaRashiIndex, 3);
  });

  test('RC-0093 Hora D2 reverses Moon/Sun order in even signs', () {
    expect(VedicVargaBuilder.horaD2(_snapshot(35)).placements.single.vargaRashiIndex, 3);
    expect(VedicVargaBuilder.horaD2(_snapshot(50)).placements.single.vargaRashiIndex, 4);
  });

  test('RC-0092/RC-0093 fail closed on invalid provenance', () {
    final invalid = VedicCalculationSnapshot(
      jdTt: 2451545,
      ephemerisSourceId: '',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'fixture-v1',
      ayanamshaDegrees: 24,
      placements: const [
        VedicPlacement(
          body: AstroBody.sun,
          siderealLongitudeDegrees: 10,
          longitudeSpeedDegreesPerDay: 1,
        ),
      ],
    );
    expect(() => VedicVargaBuilder.navamsaD9(invalid), throwsStateError);
    expect(() => VedicVargaBuilder.horaD2(invalid), throwsStateError);
  });
}
