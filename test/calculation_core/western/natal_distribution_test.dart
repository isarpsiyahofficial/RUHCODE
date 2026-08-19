import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_distribution.dart';
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
  test('maps zodiac signs to four elements and three modalities', () {
    final result = WesternNatalDistributionEngine.build(
      placements: placements([
        state(AstroBody.sun, 0),      // Aries: fire/cardinal
        state(AstroBody.moon, 30),    // Taurus: earth/fixed
        state(AstroBody.mercury, 60), // Gemini: air/mutable
        state(AstroBody.venus, 90),   // Cancer: water/cardinal
      ]),
    );

    expect(result.elementWeights[WesternElement.fire], 1);
    expect(result.elementWeights[WesternElement.earth], 1);
    expect(result.elementWeights[WesternElement.air], 1);
    expect(result.elementWeights[WesternElement.water], 1);
    expect(result.modalityWeights[WesternModality.cardinal], 2);
    expect(result.modalityWeights[WesternModality.fixed], 1);
    expect(result.modalityWeights[WesternModality.mutable], 1);
    expect(result.elementPercent(WesternElement.fire), closeTo(25, 1e-12));
    expect(result.modalityPercent(WesternModality.cardinal), closeTo(50, 1e-12));
  });

  test('custom body weights are explicit and deterministic', () {
    final weights = {for (final body in AstroBody.values) body: 0.0};
    weights[AstroBody.sun] = 2;
    weights[AstroBody.moon] = 1;
    final result = WesternNatalDistributionEngine.build(
      placements: placements([
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 30),
        state(AstroBody.mercury, 60),
      ]),
      weightPolicy: PlacementWeightPolicy(weights: weights),
    );

    expect(result.elementPercent(WesternElement.fire), closeTo(66.6666666667, 1e-9));
    expect(result.elementPercent(WesternElement.earth), closeTo(33.3333333333, 1e-9));
    expect(result.elementPercent(WesternElement.air), 0);
  });

  test('rejects incomplete and all-zero weight policies', () {
    expect(
      () => PlacementWeightPolicy(weights: const {AstroBody.sun: 1}),
      throwsStateError,
    );
    expect(
      () => PlacementWeightPolicy(
        weights: {for (final body in AstroBody.values) body: 0.0},
      ),
      throwsStateError,
    );
  });
}
