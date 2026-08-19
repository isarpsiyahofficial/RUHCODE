import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/essential_dignities.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

EclipticState state(AstroBody body, double longitude) => EclipticState(
      body: body,
      jdTt: 2460000.5,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: 'test-source',
      dataVersion: 'v1',
    );

NatalPlacementSet placements(List<EclipticState> states) => WesternNatalPlacements.build(
      states: states,
      houses: EqualHouseSystems.equal(ascendantLongitude: 0),
    );

void main() {
  test('classifies domicile exaltation detriment and fall independently', () {
    final result = WesternEssentialDignities.build(
      placements: placements([
        state(AstroBody.sun, 120),
        state(AstroBody.moon, 30),
        state(AstroBody.venus, 210),
        state(AstroBody.mars, 90),
      ]),
    );

    expect(result.forBody(AstroBody.sun).has(EssentialDignity.domicile), isTrue);
    expect(result.forBody(AstroBody.moon).has(EssentialDignity.exaltation), isTrue);
    expect(result.forBody(AstroBody.venus).has(EssentialDignity.detriment), isTrue);
    expect(result.forBody(AstroBody.mars).has(EssentialDignity.fall), isTrue);
  });

  test('Mercury in Virgo carries both domicile and exaltation', () {
    final result = WesternEssentialDignities.build(
      placements: placements([state(AstroBody.mercury, 150)]),
    );
    final mercury = result.forBody(AstroBody.mercury);
    expect(
      mercury.dignities,
      containsAll([EssentialDignity.domicile, EssentialDignity.exaltation]),
    );
  });

  test('outer planets and nodes are intentionally unassigned in classical table', () {
    final result = WesternEssentialDignities.build(
      placements: placements([
        state(AstroBody.uranus, 0),
        state(AstroBody.meanNode, 90),
      ]),
    );

    expect(result.forBody(AstroBody.uranus).dignities, isEmpty);
    expect(result.forBody(AstroBody.meanNode).dignities, isEmpty);
  });

  test('opposite signs derive detriment and fall consistently', () {
    final result = WesternEssentialDignities.build(
      placements: placements([
        state(AstroBody.sun, 300),
        state(AstroBody.saturn, 0),
        state(AstroBody.jupiter, 270),
      ]),
    );

    expect(result.forBody(AstroBody.sun).has(EssentialDignity.detriment), isTrue);
    expect(result.forBody(AstroBody.saturn).has(EssentialDignity.fall), isTrue);
    expect(result.forBody(AstroBody.jupiter).has(EssentialDignity.fall), isTrue);
  });

  test('Mercury in Pisces carries both detriment and fall', () {
    final result = WesternEssentialDignities.build(
      placements: placements([state(AstroBody.mercury, 330)]),
    );
    final mercury = result.forBody(AstroBody.mercury);
    expect(
      mercury.dignities,
      containsAll([EssentialDignity.detriment, EssentialDignity.fall]),
    );
  });

  test('classical rulership queries are derived from the domicile table', () {
    expect(
      WesternEssentialDignities.domicilesForBody(AstroBody.mercury),
      containsAll([TropicalZodiacSign.gemini, TropicalZodiacSign.virgo]),
    );
    expect(
      WesternEssentialDignities.classicalRulerOfSign(TropicalZodiacSign.scorpio),
      AstroBody.mars,
    );
    expect(
      WesternEssentialDignities.classicalRulerOfSign(TropicalZodiacSign.aquarius),
      AstroBody.saturn,
    );
    expect(
      WesternEssentialDignities.rulersOfSign(TropicalZodiacSign.leo),
      {AstroBody.sun},
    );
  });

  test('modern outer-planet rulerships are not invented by the classical API', () {
    expect(WesternEssentialDignities.domicilesForBody(AstroBody.uranus), isEmpty);
    expect(WesternEssentialDignities.domicilesForBody(AstroBody.neptune), isEmpty);
    expect(WesternEssentialDignities.domicilesForBody(AstroBody.pluto), isEmpty);
  });
}
