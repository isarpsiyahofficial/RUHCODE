import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged provider resolves all RC-0014 physical bodies at J2000', () async {
    final provider = await De440sEphemerisProvider.loadPackaged();
    provider.coverage.requireContains(2451545.0);

    const requiredBodies = <AstroBody>[
      AstroBody.sun,
      AstroBody.moon,
      AstroBody.mercury,
      AstroBody.venus,
      AstroBody.mars,
      AstroBody.jupiter,
      AstroBody.saturn,
      AstroBody.uranus,
      AstroBody.neptune,
      AstroBody.pluto,
    ];

    final states = <AstroBody, EclipticState>{};
    for (final body in requiredBodies) {
      final state = provider.stateAt(body: body, jdTt: 2451545.0);
      expect(state.body, body);
      expect(state.sourceId, 'NASA/JPL DE440s');
      expect(state.dataVersion, 'DE440s');
      expect(state.longitudeDegrees, inInclusiveRange(0.0, 359.999999999999));
      expect(state.latitudeDegrees, inInclusiveRange(-90.0, 90.0));
      expect(state.distanceAu, greaterThan(0.0));
      expect(state.longitudeSpeedDegreesPerDay.isFinite, isTrue);
      states[body] = state;
    }

    expect(states.length, requiredBodies.length);
    expect(states[AstroBody.moon]!.distanceAu, lessThan(0.01));
    expect(states[AstroBody.sun]!.distanceAu, inInclusiveRange(0.9, 1.1));
    expect(states.values.map((state) => state.longitudeDegrees).toSet().length, greaterThan(5));
  });

  test('provider rejects node substitution and out-of-coverage requests', () async {
    final provider = await De440sEphemerisProvider.loadPackaged();

    expect(
      () => provider.stateAt(body: AstroBody.meanNode, jdTt: 2451545.0),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      () => provider.stateAt(body: AstroBody.trueNode, jdTt: 2451545.0),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      () => provider.stateAt(
        body: AstroBody.sun,
        jdTt: provider.coverage.startJdTt - 1.0,
      ),
      throwsA(isA<RangeError>()),
    );
  });

  test('retrograde motion is derived from the physical DE440s velocity state', () async {
    final provider = await De440sEphemerisProvider.loadPackaged();
    final mercury = provider.stateAt(body: AstroBody.mercury, jdTt: 2451545.0);

    expect(mercury.longitudeSpeedDegreesPerDay.abs(), greaterThan(1e-4));
    expect(
      mercury.motion(),
      mercury.longitudeSpeedDegreesPerDay < 0
          ? ApparentMotion.retrograde
          : ApparentMotion.direct,
    );
  });
}
