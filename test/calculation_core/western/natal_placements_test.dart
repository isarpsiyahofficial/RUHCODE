import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

EclipticState state(
  AstroBody body,
  double longitude, {
  double speed = 1.0,
  double jd = 2460000.5,
  String source = 'test-source',
  String version = 'v1',
}) =>
    EclipticState(
      body: body,
      jdTt: jd,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: speed,
      sourceId: source,
      dataVersion: version,
    );

void main() {
  test('maps exact zodiac boundaries and houses deterministically', () {
    final houses = EqualHouseSystems.wholeSign(ascendantLongitude: 95);
    final result = WesternNatalPlacements.build(
      states: [
        state(AstroBody.sun, 0),
        state(AstroBody.moon, 29.999999),
        state(AstroBody.mercury, 30),
        state(AstroBody.venus, 359.999999),
      ],
      houses: houses,
    );

    expect(result.forBody(AstroBody.sun).sign, TropicalZodiacSign.aries);
    expect(result.forBody(AstroBody.moon).sign, TropicalZodiacSign.aries);
    expect(result.forBody(AstroBody.mercury).sign, TropicalZodiacSign.taurus);
    expect(result.forBody(AstroBody.venus).sign, TropicalZodiacSign.pisces);
    expect(result.forBody(AstroBody.mercury).degreeInSign, closeTo(0, 1e-12));

    // Whole Sign ASC 95° => first cusp 90°; longitude 30° is house 11.
    expect(result.forBody(AstroBody.mercury).houseNumber, 11);
  });

  test('preserves direct stationary retrograde state', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 0);
    final result = WesternNatalPlacements.build(
      states: [
        state(AstroBody.mercury, 10, speed: 0.5),
        state(AstroBody.venus, 20, speed: 0.00001),
        state(AstroBody.mars, 30, speed: -0.2),
      ],
      houses: houses,
    );

    expect(result.forBody(AstroBody.mercury).motion, ApparentMotion.direct);
    expect(result.forBody(AstroBody.venus).motion, ApparentMotion.stationary);
    expect(result.forBody(AstroBody.mars).motion, ApparentMotion.retrograde);
  });

  test('rejects duplicate bodies and mixed provenance', () {
    final houses = EqualHouseSystems.equal(ascendantLongitude: 0);
    expect(
      () => WesternNatalPlacements.build(
        states: [state(AstroBody.sun, 10), state(AstroBody.sun, 20)],
        houses: houses,
      ),
      throwsStateError,
    );
    expect(
      () => WesternNatalPlacements.build(
        states: [
          state(AstroBody.sun, 10),
          state(AstroBody.moon, 20, source: 'other'),
        ],
        houses: houses,
      ),
      throwsStateError,
    );
  });
}
