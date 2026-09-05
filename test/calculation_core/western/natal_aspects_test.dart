import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_aspects.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

EclipticState state(
  AstroBody body,
  double longitude, {
  double speed = 1,
}) =>
    EclipticState(
      body: body,
      jdTt: 2460000.5,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: speed,
      sourceId: 'test-source',
      dataVersion: 'v1',
    );

NatalPlacementSet placements(List<EclipticState> states) =>
    WesternNatalPlacements.build(
      states: states,
      houses: EqualHouseSystems.equal(ascendantLongitude: 0),
    );

void main() {
  test('detects conjunction sextile square trine quincunx and opposition', () {
    final result = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 0),
        state(AstroBody.mercury, 60),
        state(AstroBody.venus, 90),
        state(AstroBody.mars, 120),
        state(AstroBody.saturn, 150),
        state(AstroBody.jupiter, 180),
      ]),
    );

    final sunHits = result.aspects.where((hit) => hit.bodyA == AstroBody.sun).toList();
    expect(sunHits.map((hit) => hit.aspect), containsAll(MajorAspect.values));
    expect(sunHits.every((hit) => hit.orbDegrees == 0), isTrue);
  });

  test('handles the 0/360 seam with shortest angular separation', () {
    final result = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 359),
        state(AstroBody.moon, 1),
      ]),
      orbPolicy: AspectOrbPolicy(
        maximumOrbDegrees: const {
          MajorAspect.conjunction: 2,
          MajorAspect.sextile: 0,
          MajorAspect.square: 0,
          MajorAspect.trine: 0,
          MajorAspect.quincunx: 0,
          MajorAspect.opposition: 0,
        },
      ),
    );

    expect(result.aspects, hasLength(1));
    expect(result.aspects.single.aspect, MajorAspect.conjunction);
    expect(result.aspects.single.separationDegrees, closeTo(2, 1e-12));
  });

  test('custom orb policy includes exact boundary and excludes outside', () {
    final policy = AspectOrbPolicy(
      maximumOrbDegrees: const {
        MajorAspect.conjunction: 1,
        MajorAspect.sextile: 1,
        MajorAspect.square: 1,
        MajorAspect.trine: 1,
        MajorAspect.quincunx: 1,
        MajorAspect.opposition: 1,
      },
    );

    final included = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 91),
      ]),
      orbPolicy: policy,
    );
    expect(included.aspects.single.aspect, MajorAspect.square);
    expect(included.aspects.single.orbDegrees, closeTo(1, 1e-12));

    final excluded = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 91.000001),
      ]),
      orbPolicy: policy,
    );
    expect(excluded.aspects, isEmpty);
  });

  test('planet and aspect specific orb overrides change detection deterministically', () {
    final strictMoonSquare = AspectOrbPolicy(
      bodyAspectOverrides: {
        AstroBody.moon: {MajorAspect.square: 1.0},
      },
    );
    final strict = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 92),
      ]),
      orbPolicy: strictMoonSquare,
    );
    expect(strict.aspects, isEmpty);

    final wideMoonSquare = AspectOrbPolicy(
      bodyAspectOverrides: {
        AstroBody.moon: {MajorAspect.square: 3.0},
      },
    );
    final wide = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 92),
      ]),
      orbPolicy: wideMoonSquare,
    );
    expect(wide.aspects.single.aspect, MajorAspect.square);
    expect(wide.aspects.single.orbDegrees, closeTo(2, 1e-12));
  });

  test('derives applying exact and separating phases from physical longitude speeds', () {
    final applying = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0, speed: 1),
        state(AstroBody.moon, 88, speed: 13),
      ]),
    );
    expect(applying.aspects.single.aspect, MajorAspect.square);
    expect(applying.aspects.single.phase, AspectPhase.applying);

    final exact = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0, speed: 1),
        state(AstroBody.moon, 90, speed: 13),
      ]),
    );
    expect(exact.aspects.single.phase, AspectPhase.exact);

    final separating = WesternNatalAspects.build(
      placements: placements([
        state(AstroBody.sun, 0, speed: 1),
        state(AstroBody.moon, 92, speed: 13),
      ]),
    );
    expect(separating.aspects.single.phase, AspectPhase.separating);
  });

  test('phase calculation handles retrograde relative motion and rejects non-finite input', () {
    expect(
      WesternNatalAspects.phaseFor(
        longitudeA: 0,
        longitudeB: 92,
        speedA: 1,
        speedB: -1,
        aspect: MajorAspect.square,
      ),
      AspectPhase.applying,
    );
    expect(
      () => WesternNatalAspects.phaseFor(
        longitudeA: double.nan,
        longitudeB: 90,
        speedA: 1,
        speedB: 13,
        aspect: MajorAspect.square,
      ),
      throwsStateError,
    );
  });

  test('rejects incomplete or invalid orb policy', () {
    expect(
      () => AspectOrbPolicy(maximumOrbDegrees: const {MajorAspect.conjunction: 8}),
      throwsStateError,
    );
    expect(
      () => AspectOrbPolicy(
        maximumOrbDegrees: const {
          MajorAspect.conjunction: 8,
          MajorAspect.sextile: 5,
          MajorAspect.square: 7,
          MajorAspect.trine: 7,
          MajorAspect.quincunx: 3,
          MajorAspect.opposition: 31,
        },
      ),
      throwsStateError,
    );
    expect(
      () => AspectOrbPolicy(bodyAspectOverrides: {
        AstroBody.sun: {MajorAspect.conjunction: 31},
      }),
      throwsStateError,
    );
  });
}
