import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_grahas.dart';

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
  test('RC-0085 requires all seven classical Graha placements', () {
    final placements = <VedicPlacement>[
      for (var i = 0; i < canonicalClassicalGrahas.length; i++)
        VedicPlacement(
          body: canonicalClassicalGrahas[i],
          siderealLongitudeDegrees: i * 30.0,
          longitudeSpeedDegreesPerDay: 1,
        ),
    ];
    final set = VedicGrahaSet.fromSnapshot(_snapshot(placements));

    expect(set.placements.length, 7);
    expect(set.forGraha(AstroBody.jupiter).body, AstroBody.jupiter);
    expect(set.ayanamshaId, 'lahiri-chitrapaksha');
    expect(set.ephemerisSourceId, 'fixture');
  });

  test('RC-0085 fails closed when a classical Graha is missing', () {
    final placements = <VedicPlacement>[
      for (final body in canonicalClassicalGrahas.where(
        (body) => body != AstroBody.saturn,
      ))
        VedicPlacement(
          body: body,
          siderealLongitudeDegrees: 10,
          longitudeSpeedDegreesPerDay: 1,
        ),
    ];

    expect(
      () => VedicGrahaSet.fromSnapshot(_snapshot(placements)),
      throwsStateError,
    );
  });

  test('Rahu/Ketu are not silently folded into RC-0085', () {
    final placements = <VedicPlacement>[
      for (final body in canonicalClassicalGrahas)
        VedicPlacement(
          body: body,
          siderealLongitudeDegrees: 10,
          longitudeSpeedDegreesPerDay: 1,
        ),
    ];
    final set = VedicGrahaSet.fromSnapshot(_snapshot(placements));

    expect(() => set.forGraha(AstroBody.trueNode), throwsArgumentError);
  });
}
