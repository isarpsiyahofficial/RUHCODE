import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/aspect_grid.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_aspects.dart';
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

NatalPlacementSet makePlacements() => WesternNatalPlacements.build(
      states: [
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 90),
        state(AstroBody.mercury, 200),
      ],
      houses: EqualHouseSystems.equal(ascendantLongitude: 0),
    );

void main() {
  test('builds symmetric square grid with empty diagonal', () {
    final placements = makePlacements();
    final aspects = WesternNatalAspects.build(placements: placements);
    final grid = WesternAspectGrid.build(placements: placements, aspects: aspects);

    expect(grid.rows.length, 3);
    expect(grid.rows.every((row) => row.length == 3), isTrue);
    expect(grid.cell(AstroBody.sun, AstroBody.sun).hit, isNull);
    expect(grid.cell(AstroBody.sun, AstroBody.moon).hit?.aspect, MajorAspect.square);
    expect(grid.cell(AstroBody.moon, AstroBody.sun).hit?.aspect, MajorAspect.square);
    expect(grid.cell(AstroBody.sun, AstroBody.mercury).hit, isNull);
  });

  test('rejects provenance mismatch', () {
    final placements = makePlacements();
    final aspects = NatalAspectSet(
      jdTt: placements.jdTt + 1,
      sourceId: placements.sourceId,
      dataVersion: placements.dataVersion,
      aspects: const [],
    );

    expect(
      () => WesternAspectGrid.build(placements: placements, aspects: aspects),
      throwsStateError,
    );
  });

  test('rejects duplicate aspect entries for one body pair', () {
    final placements = makePlacements();
    final duplicate = NatalAspectHit(
      bodyA: AstroBody.sun,
      bodyB: AstroBody.moon,
      aspect: MajorAspect.square,
      separationDegrees: 90,
      orbDegrees: 0,
    );
    final aspects = NatalAspectSet(
      jdTt: placements.jdTt,
      sourceId: placements.sourceId,
      dataVersion: placements.dataVersion,
      aspects: [duplicate, duplicate],
    );

    expect(
      () => WesternAspectGrid.build(placements: placements, aspects: aspects),
      throwsStateError,
    );
  });
}
