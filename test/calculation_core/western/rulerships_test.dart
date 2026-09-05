import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';
import 'package:ruh_code/src/calculation_core/western/rulerships.dart';

void main() {
  test('traditional and modern rulership catalogs cover all twelve signs', () {
    expect(WesternRulerships.traditional.keys.toSet(), TropicalZodiacSign.values.toSet());
    expect(WesternRulerships.modern.keys.toSet(), TropicalZodiacSign.values.toSet());
    expect(
      WesternRulerships.rulerForSign(TropicalZodiacSign.scorpio),
      AstroBody.pluto,
    );
    expect(
      WesternRulerships.rulerForSign(
        TropicalZodiacSign.scorpio,
        scheme: WesternRulershipScheme.traditional,
      ),
      AstroBody.mars,
    );
    expect(
      WesternRulerships.rulerForSign(TropicalZodiacSign.aquarius),
      AstroBody.uranus,
    );
    expect(
      WesternRulerships.rulerForSign(TropicalZodiacSign.pisces),
      AstroBody.neptune,
    );
  });

  test('reports signs ruled by each planet under the selected scheme', () {
    expect(
      WesternRulerships.signsRuledBy(AstroBody.mercury),
      {TropicalZodiacSign.gemini, TropicalZodiacSign.virgo},
    );
    expect(
      WesternRulerships.signsRuledBy(
        AstroBody.mars,
        scheme: WesternRulershipScheme.traditional,
      ),
      {TropicalZodiacSign.aries, TropicalZodiacSign.scorpio},
    );
    expect(
      WesternRulerships.signsRuledBy(AstroBody.pluto),
      {TropicalZodiacSign.scorpio},
    );
  });

  test('derives all twelve house rulers from the actual cusp signs', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 15);
    final rulers = WesternRulerships.rulersForAllHouses(houses);
    expect(rulers, hasLength(12));
    expect(rulers.first.houseNumber, 1);
    expect(rulers.first.cuspSign, TropicalZodiacSign.aries);
    expect(rulers.first.ruler, AstroBody.mars);
    expect(rulers[7].houseNumber, 8);
    expect(rulers[7].cuspSign, TropicalZodiacSign.scorpio);
    expect(rulers[7].ruler, AstroBody.pluto);
    expect(rulers.last.houseNumber, 12);
    expect(rulers.last.cuspSign, TropicalZodiacSign.pisces);
    expect(rulers.last.ruler, AstroBody.neptune);
  });

  test('house ruler lookup fails closed outside houses one through twelve', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 0);
    expect(() => WesternRulerships.rulerForHouse(houses, 0), throwsRangeError);
    expect(() => WesternRulerships.rulerForHouse(houses, 13), throwsRangeError);
  });
}
