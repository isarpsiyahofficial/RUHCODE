import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/luminaries_ascendant.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

EclipticState _state(AstroBody body, double longitude) => EclipticState(
      body: body,
      jdTt: 2460000.5,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 0.5,
      sourceId: 'test-source',
      dataVersion: 'v1',
    );

void main() {
  test('projects Sun Moon and Ascendant from one Western calculation snapshot', () {
    final result = WesternLuminariesAscendant.build(
      states: [
        _state(AstroBody.sun, 12.5),
        _state(AstroBody.moon, 214.25),
      ],
      houses: EqualHouseSystems.equal(ascendantLongitude: 95.75),
    );

    expect(result.sun.body, AstroBody.sun);
    expect(result.sun.sign, TropicalZodiacSign.aries);
    expect(result.sun.degreeInSign, closeTo(12.5, 1e-12));
    expect(result.moon.body, AstroBody.moon);
    expect(result.moon.sign, TropicalZodiacSign.scorpio);
    expect(result.moon.degreeInSign, closeTo(4.25, 1e-12));
    expect(result.ascendantLongitudeDegrees, closeTo(95.75, 1e-12));
    expect(result.ascendantSign, TropicalZodiacSign.cancer);
    expect(result.ascendantDegreeInSign, closeTo(5.75, 1e-12));
  });

  test('fails closed when Sun or Moon is absent', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 0);
    expect(
      () => WesternLuminariesAscendant.build(
        states: [_state(AstroBody.sun, 12)],
        houses: houses,
      ),
      throwsStateError,
    );
    expect(
      () => WesternLuminariesAscendant.build(
        states: [_state(AstroBody.moon, 12)],
        houses: houses,
      ),
      throwsStateError,
    );
  });
}
