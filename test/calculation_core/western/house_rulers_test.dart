import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/house_rulers.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

void main() {
  test('RC-0036 classical rulership covers all twelve tropical signs', () {
    const expected = <TropicalZodiacSign, AstroBody>{
      TropicalZodiacSign.aries: AstroBody.mars,
      TropicalZodiacSign.taurus: AstroBody.venus,
      TropicalZodiacSign.gemini: AstroBody.mercury,
      TropicalZodiacSign.cancer: AstroBody.moon,
      TropicalZodiacSign.leo: AstroBody.sun,
      TropicalZodiacSign.virgo: AstroBody.mercury,
      TropicalZodiacSign.libra: AstroBody.venus,
      TropicalZodiacSign.scorpio: AstroBody.mars,
      TropicalZodiacSign.sagittarius: AstroBody.jupiter,
      TropicalZodiacSign.capricorn: AstroBody.saturn,
      TropicalZodiacSign.aquarius: AstroBody.saturn,
      TropicalZodiacSign.pisces: AstroBody.jupiter,
    };

    for (final entry in expected.entries) {
      expect(
        WesternHouseRulers.classicalRulerFor(entry.key),
        entry.value,
        reason: 'Unexpected classical ruler for ${entry.key.name}',
      );
    }
  });

  test('RC-0036 derives one ruler for every exact house cusp', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 15);
    final rulers = WesternHouseRulers.build(houses: houses);

    expect(rulers.rulers, hasLength(12));
    expect(rulers.forHouse(1).cuspLongitudeDegrees, 15);
    expect(rulers.forHouse(1).cuspSign, TropicalZodiacSign.aries);
    expect(rulers.forHouse(1).ruler, AstroBody.mars);

    expect(rulers.forHouse(2).cuspLongitudeDegrees, 45);
    expect(rulers.forHouse(2).cuspSign, TropicalZodiacSign.taurus);
    expect(rulers.forHouse(2).ruler, AstroBody.venus);

    expect(rulers.forHouse(8).cuspLongitudeDegrees, 225);
    expect(rulers.forHouse(8).cuspSign, TropicalZodiacSign.scorpio);
    expect(rulers.forHouse(8).ruler, AstroBody.mars);

    expect(rulers.forHouse(12).cuspLongitudeDegrees, 345);
    expect(rulers.forHouse(12).cuspSign, TropicalZodiacSign.pisces);
    expect(rulers.forHouse(12).ruler, AstroBody.jupiter);
  });

  test('whole-sign rulership follows the sign containing the ascendant', () {
    final houses = EqualHouseSystems.wholeSign(ascendantLongitude: 95);
    final rulers = WesternHouseRulers.build(houses: houses);

    expect(rulers.forHouse(1).cuspLongitudeDegrees, 90);
    expect(rulers.forHouse(1).cuspSign, TropicalZodiacSign.cancer);
    expect(rulers.forHouse(1).ruler, AstroBody.moon);
    expect(rulers.forHouse(10).cuspLongitudeDegrees, 0);
    expect(rulers.forHouse(10).cuspSign, TropicalZodiacSign.aries);
    expect(rulers.forHouse(10).ruler, AstroBody.mars);
  });

  test('house lookup rejects numbers outside the twelve-house contract', () {
    final rulers = WesternHouseRulers.build(
      houses: EqualHouseSystems.equal(ascendantLongitude: 0),
    );

    expect(() => rulers.forHouse(0), throwsRangeError);
    expect(() => rulers.forHouse(13), throwsRangeError);
  });
}
