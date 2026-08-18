import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/moon_phase_factor.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';

void main() {
  test('DailySnapshot moon-phase factor uses exact ephemeris provenance', () {
    final factor = MoonPhaseDailyFactor(
      engineVersion: 'moon-phase-1',
      ephemeris: _FixtureProvider(),
    ).build(jdTt: 2460000.5);

    expect(factor.kind, DailyFactorKind.moonPhase);
    expect(factor.sourceEngineId, 'moon_phase');
    expect(factor.sourceEngineVersion, 'moon-phase-1');
    expect(factor.resultId, contains('fullMoon'));
    expect(factor.resultId, contains('fixture|fixture-v1'));
  });

  test('empty engine version is rejected', () {
    expect(
      () => MoonPhaseDailyFactor(
        engineVersion: ' ',
        ephemeris: _FixtureProvider(),
      ).build(jdTt: 2460000.5),
      throwsStateError,
    );
  });
}

final class _FixtureProvider implements EphemerisProvider {
  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2450000,
        endJdTt: 2470000,
        sourceId: 'fixture',
        dataVersion: 'fixture-v1',
        checksumSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    coverage.requireContains(jdTt);
    final longitude = switch (body) {
      AstroBody.sun => 12.0,
      AstroBody.moon => 192.0,
      _ => throw UnsupportedError('fixture only supports Sun/Moon'),
    };
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: body == AstroBody.moon ? 0.00257 : 1,
      longitudeSpeedDegreesPerDay: body == AstroBody.moon ? 13.2 : 0.9856,
      sourceId: 'fixture',
      dataVersion: 'fixture-v1',
    );
  }
}
