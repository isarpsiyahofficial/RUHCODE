import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/degree_tables.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

EclipticState _state(AstroBody body, double longitude) => EclipticState(
      body: body,
      jdTt: 2460000.5,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: 'test-source',
      dataVersion: 'v1',
    );

void main() {
  test('planet degree table preserves placement identity and degrees', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 0);
    final placements = WesternNatalPlacements.build(
      states: [
        _state(AstroBody.sun, 12.5),
        _state(AstroBody.moon, 47.25),
      ],
      houses: houses,
    );

    final rows = WesternDegreeTables.planets(placements);
    expect(rows, hasLength(2));
    expect(rows[0].body, AstroBody.sun);
    expect(rows[0].longitudeDegrees, 12.5);
    expect(rows[0].sign, TropicalZodiacSign.aries);
    expect(rows[0].degreeInSign, 12.5);
    expect(rows[0].houseNumber, 1);
    expect(rows[1].body, AstroBody.moon);
    expect(rows[1].sign, TropicalZodiacSign.taurus);
    expect(rows[1].degreeInSign, 17.25);
  });

  test('house degree table exposes exactly twelve individually numbered cusps', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 12.5);
    final rows = WesternDegreeTables.houses(houses);

    expect(rows, hasLength(12));
    for (var i = 0; i < 12; i++) {
      expect(rows[i].houseNumber, i + 1);
      expect(rows[i].cuspLongitudeDegrees, houses.cusp(i + 1));
      expect(rows[i].degreeInSign, inInclusiveRange(0, 30));
    }
    expect(rows.first.sign, TropicalZodiacSign.aries);
    expect(rows.last.houseNumber, 12);
  });
}
