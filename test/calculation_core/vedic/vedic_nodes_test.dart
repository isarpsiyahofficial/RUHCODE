import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_nodes.dart';

VedicCalculationSnapshot _snapshot(List<VedicPlacement> placements) {
  return VedicCalculationSnapshot(
    jdTt: 2451545.0,
    ephemerisSourceId: 'fixture',
    ephemerisDataVersion: 'v1',
    ayanamshaId: 'lahiri-chitrapaksha',
    ayanamshaDataVersion: 'fixture-v1',
    ayanamshaDegrees: 24,
    placements: placements,
  );
}

void main() {
  test('RC-0086 computes Rahu from the explicitly selected true node', () {
    final nodes = VedicRahuKetu.fromSnapshot(
      snapshot: _snapshot(const [
        VedicPlacement(
          body: AstroBody.trueNode,
          siderealLongitudeDegrees: 350,
          longitudeSpeedDegreesPerDay: -0.05,
        ),
      ]),
      mode: VedicNodeMode.trueNode,
    );

    expect(nodes.mode, VedicNodeMode.trueNode);
    expect(nodes.rahu.siderealLongitudeDegrees, 350);
    expect(nodes.rahu.longitudeSpeedDegreesPerDay, -0.05);
    expect(nodes.ephemerisSourceId, 'fixture');
    expect(nodes.ayanamshaId, 'lahiri-chitrapaksha');
  });

  test('RC-0087 computes Ketu as Rahu exact antipode with wraparound', () {
    final nodes = VedicRahuKetu.fromSnapshot(
      snapshot: _snapshot(const [
        VedicPlacement(
          body: AstroBody.meanNode,
          siderealLongitudeDegrees: 350,
          longitudeSpeedDegreesPerDay: -0.04,
        ),
      ]),
      mode: VedicNodeMode.mean,
    );

    expect(nodes.ketu.siderealLongitudeDegrees, 170);
    expect(nodes.ketu.longitudeSpeedDegreesPerDay, -0.04);
    expect(
      (nodes.ketu.siderealLongitudeDegrees -
                  nodes.rahu.siderealLongitudeDegrees -
                  180)
              .abs() ==
          0 ||
          (nodes.ketu.siderealLongitudeDegrees -
                      nodes.rahu.siderealLongitudeDegrees +
                      180)
                  .abs() ==
              0,
      isTrue,
    );
  });

  test('RC-0086 fails closed instead of switching node policy', () {
    expect(
      () => VedicRahuKetu.fromSnapshot(
        snapshot: _snapshot(const [
          VedicPlacement(
            body: AstroBody.meanNode,
            siderealLongitudeDegrees: 10,
            longitudeSpeedDegreesPerDay: -0.04,
          ),
        ]),
        mode: VedicNodeMode.trueNode,
      ),
      throwsStateError,
    );
  });

  test('RC-0087 fails closed on duplicate selected-node placements', () {
    expect(
      () => VedicRahuKetu.fromSnapshot(
        snapshot: _snapshot(const [
          VedicPlacement(
            body: AstroBody.trueNode,
            siderealLongitudeDegrees: 10,
            longitudeSpeedDegreesPerDay: -0.04,
          ),
          VedicPlacement(
            body: AstroBody.trueNode,
            siderealLongitudeDegrees: 11,
            longitudeSpeedDegreesPerDay: -0.04,
          ),
        ]),
        mode: VedicNodeMode.trueNode,
      ),
      throwsStateError,
    );
  });
}
