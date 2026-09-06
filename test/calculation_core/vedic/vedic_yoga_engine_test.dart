import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_rashi_chart.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_yoga_engine.dart';

VedicRashiPlacement p(AstroBody body, int rashi, int house) => VedicRashiPlacement(
      placement: VedicPlacement(
        body: body,
        siderealLongitudeDegrees: rashi * 30.0 + 5.0,
        longitudeSpeedDegreesPerDay: 1.0,
      ),
      rashiIndex: rashi,
      degreesWithinRashi: 5.0,
      wholeSignHouse: house,
    );

VedicRashiChart chart(List<VedicRashiPlacement> placements) => VedicRashiChart(
      jdTt: 2460000.5,
      ephemerisSourceId: 'fixture',
      ephemerisDataVersion: '1',
      ayanamshaId: 'lahiri',
      ayanamshaDataVersion: '1',
      lagnaRashiIndex: 0,
      placements: placements,
    );

void main() {
  test('matches explicit same-house and house-distance rules', () {
    final c = chart([
      p(AstroBody.jupiter, 0, 1),
      p(AstroBody.moon, 0, 1),
      p(AstroBody.venus, 6, 7),
    ]);
    final definition = VedicYogaDefinition(
      id: 'fixture-yoga',
      version: '1',
      sourceId: 'fixture-source',
      requiredBodies: [AstroBody.jupiter, AstroBody.moon, AstroBody.venus],
      relations: [
        const VedicYogaRelation.sameHouse(AstroBody.jupiter, AstroBody.moon),
        const VedicYogaRelation.houseDistance(AstroBody.jupiter, AstroBody.venus, 7),
      ],
    );

    final matches = VedicYogaEngine.evaluate(chart: c, definitions: [definition]);
    expect(matches, hasLength(1));
    expect(matches.single.definitionId, 'fixture-yoga');
    expect(matches.single.ayanamshaId, 'lahiri');
  });

  test('does not match when a required relation fails', () {
    final c = chart([
      p(AstroBody.jupiter, 0, 1),
      p(AstroBody.moon, 1, 2),
    ]);
    final definition = VedicYogaDefinition(
      id: 'same-house',
      version: '1',
      sourceId: 'fixture-source',
      requiredBodies: [AstroBody.jupiter, AstroBody.moon],
      relations: [
        const VedicYogaRelation.sameHouse(AstroBody.jupiter, AstroBody.moon),
      ],
    );
    expect(VedicYogaEngine.evaluate(chart: c, definitions: [definition]), isEmpty);
  });

  test('rejects duplicate catalog ids and missing provenance', () {
    final c = chart([p(AstroBody.sun, 0, 1), p(AstroBody.moon, 0, 1)]);
    final definition = VedicYogaDefinition(
      id: 'x',
      version: '1',
      sourceId: 'source',
      requiredBodies: [AstroBody.sun, AstroBody.moon],
      relations: [
        const VedicYogaRelation.sameRashi(AstroBody.sun, AstroBody.moon),
      ],
    );
    expect(
      () => VedicYogaEngine.evaluate(chart: c, definitions: [definition, definition]),
      throwsStateError,
    );
    expect(
      () => VedicYogaDefinition(
        id: '',
        version: '1',
        sourceId: 'source',
        requiredBodies: [AstroBody.sun],
        relations: [
          const VedicYogaRelation.sameHouse(AstroBody.sun, AstroBody.sun),
        ],
      ),
      throwsArgumentError,
    );
  });
}
