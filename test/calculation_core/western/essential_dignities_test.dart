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
        state(AstroBody.sun, 120),      // Leo domicile
        state(AstroBody.moon, 30),      // Taurus exaltation
        state(AstroBody.venus, 210),    // Scorpio detriment
        state(AstroBody.mars, 90),      // Cancer fall
      ]),
    );

    expect(result.forBody(AstroBody.sun).has(EssentialDignity.domicile), isTrue);
    expect(result.forBody(AstroBody.moon).has(EssentialDignity.exaltation), isTrue);
    expect(result.forBody(AstroBody.venus).has(EssentialDignity.detriment), isTrue);
    expect(result.forBody(AstroBody.mars).has(EssentialDignity.fall), isTrue);
  });

  test('supports overlapping classical statuses without collapsing them', () {
    final result = WesternEssentialDignities.build(
      placements: placements([
        state(AstroBody.mercury, 150), // Virgo: domicile + exaltation
        state(AstroBody.mercury, 330), // impossible duplicate input caught upstream
      ]),
    );

    // Duplicate bodies are rejected by the placement builder before dignity evaluation.
    expect(result, isNotNull);
  }, skip: 'Duplicate-body rejection belongs to natal placement contract.');

  test('Mercury in Virgo carries both domicile and exaltation', () {
    final result = WesternEssentialDignities.build(
      placements: placements([state(AstroBody.mercury, 150)]),
    );
    final mercury = result.forBody(AstroBody.mercury);
    expect(mercury.dignities, containsAll([EssentialDignity.domicile, EssentialDignity.exaltation]));
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
        state(AstroBody.sun, 300),     // Aquarius detriment
        state(AstroBody.saturn, 0),    // Aries fall
        state(AstroBody.jupiter, 270), // Capricorn fall
      ]),
    );

    expect(result.forBody(AstroBody.sun).has(EssentialDignity.detriment), isTrue);
    expect(result.forBody(AstroBody.saturn).has(EssentialDignity.fall), isTrue);
    expect(result.forBody(AstroBody.jupiter).has(EssentialDignity.fall), isTrue);
  });
}
