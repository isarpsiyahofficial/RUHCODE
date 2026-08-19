import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_aspects.dart';
import 'package:ruh_code/src/calculation_core/western/natal_chart.dart';

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

void main() {
  test('assembles placements, houses and aspects from one provenance snapshot', () {
    final chart = WesternNatalChartAssembler.build(
      states: [
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 90),
        state(AstroBody.mercury, 120),
      ],
      houses: EqualHouseSystems.wholeSign(ascendantLongitude: 95),
    );

    expect(chart.jdTt, 2460000.5);
    expect(chart.sourceId, 'test-source');
    expect(chart.dataVersion, 'v1');
    expect(chart.placements.placements, hasLength(3));
    expect(chart.aspects.aspects, isNotEmpty);
    expect(
      chart.aspects.aspects.any(
        (hit) => hit.bodyA == AstroBody.sun && hit.bodyB == AstroBody.moon && hit.aspect == MajorAspect.square,
      ),
      isTrue,
    );
    expect(chart.placements.forBody(AstroBody.sun).houseNumber, 10);
  });

  test('all derived natal collections preserve the exact placement body set', () {
    final chart = WesternNatalChartAssembler.build(
      states: [
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 90),
        state(AstroBody.mercury, 120),
        state(AstroBody.venus, 180),
      ],
      houses: EqualHouseSystems.equal(ascendantLongitude: 15),
    );

    final placementBodies = chart.placements.placements.map((item) => item.body).toSet();
    final gridBodies = chart.aspectGrid.bodies.toSet();
    final dignityBodies = chart.dignities.assessments.map((item) => item.body).toSet();

    expect(gridBodies, placementBodies);
    expect(dignityBodies, placementBodies);
    expect(chart.aspectGrid.rows, hasLength(placementBodies.length));
    expect(
      chart.aspectGrid.rows.every((row) => row.length == placementBodies.length),
      isTrue,
    );
  });

  test('custom orb policy is propagated through chart assembly', () {
    final chart = WesternNatalChartAssembler.build(
      states: [state(AstroBody.sun, 0), state(AstroBody.moon, 92)],
      houses: EqualHouseSystems.equal(ascendantLongitude: 0),
      orbPolicy: AspectOrbPolicy(
        maximumOrbDegrees: const {
          MajorAspect.conjunction: 1,
          MajorAspect.sextile: 1,
          MajorAspect.square: 1,
          MajorAspect.trine: 1,
          MajorAspect.opposition: 1,
        },
      ),
    );

    expect(chart.aspects.aspects, isEmpty);
  });
}
