import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/transits/transit_aspects.dart';

void main() {
  group('TransitAspectEngine', () {
    test('matches major aspects and sorts by exact orb', () {
      final provider = _FakeEphemeris(<AstroBody, double>{
        AstroBody.saturn: 100,
        AstroBody.jupiter: 10,
      });
      final engine = TransitAspectEngine(provider);

      final matches = engine.calculate(
        jdTt: 2460000.5,
        natalPoints: <NatalPoint>[
          NatalPoint(body: AstroBody.sun, longitudeDegrees: 10),
          NatalPoint(body: AstroBody.venus, longitudeDegrees: 190),
        ],
        transitBodies: const <AstroBody>[AstroBody.saturn, AstroBody.jupiter],
      );

      expect(matches.first.transitBody, AstroBody.jupiter);
      expect(matches.first.natalBody, AstroBody.sun);
      expect(matches.first.aspect, TransitAspectType.conjunction);
      expect(matches.first.orbDegrees, 0);

      expect(
        matches.any(
          (m) =>
              m.transitBody == AstroBody.saturn &&
              m.natalBody == AstroBody.sun &&
              m.aspect == TransitAspectType.square &&
              m.orbDegrees == 0,
        ),
        isTrue,
      );
      expect(
        matches.any(
          (m) =>
              m.transitBody == AstroBody.jupiter &&
              m.natalBody == AstroBody.venus &&
              m.aspect == TransitAspectType.opposition,
        ),
        isTrue,
      );
    });

    test('uses smallest angular separation across zero degrees', () {
      final provider = _FakeEphemeris(<AstroBody, double>{AstroBody.mars: 359});
      final matches = TransitAspectEngine(provider).calculate(
        jdTt: 2460000.5,
        natalPoints: <NatalPoint>[
          NatalPoint(body: AstroBody.moon, longitudeDegrees: 1),
        ],
        transitBodies: const <AstroBody>[AstroBody.mars],
      );

      expect(matches, hasLength(1));
      expect(matches.single.aspect, TransitAspectType.conjunction);
      expect(matches.single.separationDegrees, 2);
      expect(matches.single.orbDegrees, 2);
    });

    test('rejects invalid orb policy', () {
      expect(
        () => TransitAspectEngine(
          _FakeEphemeris(const <AstroBody, double>{}),
          orbPolicy: const TransitAspectOrbPolicy(square: 0),
        ),
        throwsRangeError,
      );
    });
  });
}

final class _FakeEphemeris implements EphemerisProvider {
  _FakeEphemeris(this.longitudes);

  final Map<AstroBody, double> longitudes;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 2400000,
        endJdTt: 2600000,
        sourceId: 'test-ephemeris',
        dataVersion: '1',
        checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final longitude = longitudes[body];
    if (longitude == null) {
      throw StateError('No test longitude for ${body.name}.');
    }
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: 'test-ephemeris',
      dataVersion: '1',
    );
  }
}
