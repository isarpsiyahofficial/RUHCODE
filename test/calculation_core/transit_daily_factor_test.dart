import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/transit_factor.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/transits/transit_aspects.dart';

void main() {
  test('builds deterministic transit DailyFactorReference', () {
    final factor = TransitDailyFactor(
      engineVersion: '1.0.0',
      ephemeris: _FakeEphemeris(),
    ).build(
      jdTt: 2460000.5,
      natalPoints: <NatalPoint>[
        NatalPoint(body: AstroBody.sun, longitudeDegrees: 10),
      ],
      transitBodies: const <AstroBody>[AstroBody.saturn],
    );

    expect(factor.kind, DailyFactorKind.transit);
    expect(factor.sourceEngineId, 'western_transit_aspects');
    expect(factor.sourceEngineVersion, '1.0.0');
    expect(factor.resultId, contains('saturn:square:sun:0.000000'));
    expect(factor.resultId, contains('test-ephemeris'));
  });

  test('rejects empty engine version', () {
    expect(
      () => TransitDailyFactor(
        engineVersion: ' ',
        ephemeris: _FakeEphemeris(),
      ).build(
        jdTt: 2460000.5,
        natalPoints: <NatalPoint>[
          NatalPoint(body: AstroBody.sun, longitudeDegrees: 10),
        ],
        transitBodies: const <AstroBody>[AstroBody.saturn],
      ),
      throwsStateError,
    );
  });
}

final class _FakeEphemeris implements EphemerisProvider {
  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2400000,
        endJdTt: 2600000,
        sourceId: 'test-ephemeris',
        dataVersion: '1',
        checksumSha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) => EclipticState(
        body: body,
        jdTt: jdTt,
        longitudeDegrees: body == AstroBody.saturn ? 100 : 0,
        latitudeDegrees: 0,
        distanceAu: 1,
        longitudeSpeedDegreesPerDay: 0.05,
        sourceId: 'test-ephemeris',
        dataVersion: '1',
      );
}
