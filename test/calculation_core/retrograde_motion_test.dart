import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';

EclipticState _state(double speed) => EclipticState(
      body: AstroBody.mercury,
      jdTt: 2451545.0,
      longitudeDegrees: 10.0,
      latitudeDegrees: 0.0,
      distanceAu: 1.0,
      longitudeSpeedDegreesPerDay: speed,
      sourceId: 'test',
      dataVersion: 'test',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('motion classification is derived from signed longitude velocity', () {
    expect(_state(0.5).motion(), ApparentMotion.direct);
    expect(_state(-0.5).motion(), ApparentMotion.retrograde);
    expect(_state(0.00005).motion(), ApparentMotion.stationary);
    expect(_state(-0.00005).motion(), ApparentMotion.stationary);
    expect(_state(0.0001).motion(), ApparentMotion.stationary);
    expect(_state(-0.0001).motion(), ApparentMotion.stationary);
    expect(_state(0.0001001).motion(), ApparentMotion.direct);
    expect(_state(-0.0001001).motion(), ApparentMotion.retrograde);
  });

  test('stationary threshold is explicit and fail-closed', () {
    expect(_state(0.01).motion(stationaryThresholdDegreesPerDay: 0.02), ApparentMotion.stationary);
    expect(
      () => _state(0.01).motion(stationaryThresholdDegreesPerDay: 0),
      throwsA(isA<RangeError>()),
    );
    expect(
      () => _state(0.01).motion(stationaryThresholdDegreesPerDay: double.nan),
      throwsA(isA<RangeError>()),
    );
  });

  test('packaged DE440s state carries physical velocity into motion calculation', () async {
    final provider = await De440sEphemerisProvider.loadPackaged();
    const bodies = <AstroBody>[
      AstroBody.mercury,
      AstroBody.venus,
      AstroBody.mars,
      AstroBody.jupiter,
      AstroBody.saturn,
      AstroBody.uranus,
      AstroBody.neptune,
      AstroBody.pluto,
    ];

    for (final body in bodies) {
      final state = provider.stateAt(body: body, jdTt: 2451545.0);
      expect(state.longitudeSpeedDegreesPerDay.isFinite, isTrue);
      final expected = state.longitudeSpeedDegreesPerDay.abs() <= 1e-4
          ? ApparentMotion.stationary
          : state.longitudeSpeedDegreesPerDay < 0
              ? ApparentMotion.retrograde
              : ApparentMotion.direct;
      expect(state.motion(), expected, reason: '$body must be classified from its physical velocity');
    }
  });
}
