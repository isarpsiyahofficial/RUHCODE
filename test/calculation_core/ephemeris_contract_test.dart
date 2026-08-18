import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';

void main() {
  test('coverage rejects invalid provenance and digest', () {
    expect(
      () => const EphemerisCoverage(
        startJdTt: 1,
        endJdTt: 2,
        sourceId: '',
        dataVersion: 'v1',
        checksumSha256: 'bad',
      ).validate(),
      throwsStateError,
    );
  });

  test('coverage rejects out-of-range TT requests', () {
    const coverage = EphemerisCoverage(
      startJdTt: 2400000.5,
      endJdTt: 2500000.5,
      sourceId: 'fixture',
      dataVersion: 'v1',
      checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
    expect(() => coverage.requireContains(2399999), throwsRangeError);
    expect(() => coverage.requireContains(2500001), throwsRangeError);
  });

  test('longitude must be normalized and no zero/default invalid state is accepted', () {
    expect(
      () => EclipticState(
        body: AstroBody.sun,
        jdTt: 2451545,
        longitudeDegrees: 360,
        latitudeDegrees: 0,
        distanceAu: 1,
        longitudeSpeedDegreesPerDay: 1,
        sourceId: 'fixture',
        dataVersion: 'v1',
      ),
      throwsRangeError,
    );
  });

  test('direct stationary retrograde are derived from signed longitude speed', () {
    EclipticState state(double speed) => EclipticState(
          body: AstroBody.mercury,
          jdTt: 2451545,
          longitudeDegrees: 120,
          latitudeDegrees: 1,
          distanceAu: 1,
          longitudeSpeedDegreesPerDay: speed,
          sourceId: 'fixture',
          dataVersion: 'v1',
        );

    expect(state(0.2).motion(), ApparentMotion.direct);
    expect(state(-0.2).motion(), ApparentMotion.retrograde);
    expect(state(0.00001).motion(), ApparentMotion.stationary);
  });

  test('sample provenance is mandatory', () {
    expect(
      () => EclipticState(
        body: AstroBody.moon,
        jdTt: 2451545,
        longitudeDegrees: 10,
        latitudeDegrees: 0,
        distanceAu: 0.00257,
        longitudeSpeedDegreesPerDay: 13,
        sourceId: '',
        dataVersion: 'v1',
      ),
      throwsStateError,
    );
  });
}
