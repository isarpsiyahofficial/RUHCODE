import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/planetary_return.dart';

final class _LinearEphemeris implements EphemerisProvider {
  _LinearEphemeris({this.mismatchProvenance = false});

  final bool mismatchProvenance;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 1000,
        endJdTt: 5000,
        sourceId: 'fixture',
        dataVersion: 'v1',
        checksumSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final speed = switch (body) {
      AstroBody.sun => 1.0,
      AstroBody.moon => 12.0,
      AstroBody.mars => 0.5,
      _ => 0.25,
    };
    final base = switch (body) {
      AstroBody.sun => 350.0,
      AstroBody.moon => 300.0,
      AstroBody.mars => 20.0,
      _ => 0.0,
    };
    var longitude = (base + (jdTt - 1000) * speed) % 360.0;
    if (longitude < 0) longitude += 360.0;
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: speed,
      sourceId: mismatchProvenance ? 'wrong' : coverage.sourceId,
      dataVersion: coverage.dataVersion,
    );
  }
}

void main() {
  test('RC-0073 finds Solar Return across the 360-degree wrap', () {
    final result = WesternPlanetaryReturnSolver.findSolarReturn(
      natalSunLongitudeDegrees: 5,
      startJdTt: 1001,
      endJdTt: 1030,
      ephemeris: _LinearEphemeris(),
      sampleStepDays: 0.5,
    );

    expect(result.body, AstroBody.sun);
    expect(result.jdTt, closeTo(1015, 1e-6));
    expect(result.actualLongitudeDegrees, closeTo(5, 1e-6));
  });

  test('RC-0074 finds Lunar Return from the same exact-TT solver', () {
    final result = WesternPlanetaryReturnSolver.findLunarReturn(
      natalMoonLongitudeDegrees: 60,
      startJdTt: 1001,
      endJdTt: 1020,
      ephemeris: _LinearEphemeris(),
      sampleStepDays: 0.1,
    );

    expect(result.body, AstroBody.moon);
    expect(result.jdTt, closeTo(1010, 1e-6));
    expect(result.actualLongitudeDegrees, closeTo(60, 1e-6));
  });

  test('RC-0075 supports a non-luminary planetary return', () {
    final result = WesternPlanetaryReturnSolver.findFirst(
      body: AstroBody.mars,
      natalLongitudeDegrees: 30,
      startJdTt: 1001,
      endJdTt: 1040,
      ephemeris: _LinearEphemeris(),
      sampleStepDays: 0.5,
    );

    expect(result.body, AstroBody.mars);
    expect(result.jdTt, closeTo(1020, 1e-6));
  });

  test('does not mistake the plus/minus 180 branch cut for a return', () {
    expect(
      () => WesternPlanetaryReturnSolver.findFirst(
        body: AstroBody.sun,
        natalLongitudeDegrees: 170,
        startJdTt: 1001,
        endJdTt: 1010,
        ephemeris: _LinearEphemeris(),
        sampleStepDays: 1,
      ),
      throwsStateError,
    );
  });

  test('fails closed when ephemeris provenance does not match coverage', () {
    expect(
      () => WesternPlanetaryReturnSolver.findSolarReturn(
        natalSunLongitudeDegrees: 5,
        startJdTt: 1001,
        endJdTt: 1030,
        ephemeris: _LinearEphemeris(mismatchProvenance: true),
      ),
      throwsStateError,
    );
  });

  test('fails closed when no return exists in the supplied window', () {
    expect(
      () => WesternPlanetaryReturnSolver.findFirst(
        body: AstroBody.mars,
        natalLongitudeDegrees: 200,
        startJdTt: 1001,
        endJdTt: 1020,
        ephemeris: _LinearEphemeris(),
      ),
      throwsStateError,
    );
  });
}
