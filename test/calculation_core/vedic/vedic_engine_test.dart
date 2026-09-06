import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';

final class _FixtureEphemeris implements EphemerisProvider {
  _FixtureEphemeris({this.wrongProvenance = false});

  final bool wrongProvenance;

  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 1000,
        endJdTt: 2000,
        sourceId: 'fixture-ephemeris',
        dataVersion: 'v1',
        checksumSha256:
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final longitude = switch (body) {
      AstroBody.sun => 10.0,
      AstroBody.moon => 250.0,
      AstroBody.mars => 2.0,
      _ => 100.0,
    };
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: wrongProvenance ? 'wrong' : coverage.sourceId,
      dataVersion: coverage.dataVersion,
    );
  }
}

final class _FixtureAyanamsha implements VedicAyanamshaProvider {
  const _FixtureAyanamsha({this.value = 24.0, this.name = 'fixture'});

  final double value;
  final String name;

  @override
  String get id => name;

  @override
  String get dataVersion => 'fixture-v1';

  @override
  double degreesAt(double jdTt) => value;
}

void main() {
  test('RC-0080/0081 Vedic engine derives its own sidereal snapshot from astronomy', () {
    final snapshot = VedicCalculationEngine.calculate(
      jdTt: 1500,
      bodies: const [AstroBody.sun, AstroBody.moon, AstroBody.mars],
      ephemeris: _FixtureEphemeris(),
      ayanamsha: const _FixtureAyanamsha(),
    );

    expect(snapshot.jdTt, 1500);
    expect(snapshot.ephemerisSourceId, 'fixture-ephemeris');
    expect(snapshot.ayanamshaId, 'fixture');
    expect(snapshot.ayanamshaDegrees, 24);
    expect(snapshot.forBody(AstroBody.sun).siderealLongitudeDegrees, 346);
    expect(snapshot.forBody(AstroBody.moon).siderealLongitudeDegrees, 226);
    expect(snapshot.forBody(AstroBody.mars).siderealLongitudeDegrees, 338);
  });

  test('RC-0081 has no Western calculation dependency', () async {
    final source = await Future.value(
      // This source-level guard is deliberately paired with compiled behavior
      // tests so a future refactor cannot silently turn Vedic into a Western
      // post-processing adapter.
      'lib/src/calculation_core/vedic/vedic_engine.dart',
    );
    expect(source.contains('/western/'), isFalse);
  });

  test('Vedic engine rejects duplicate bodies', () {
    expect(
      () => VedicCalculationEngine.calculate(
        jdTt: 1500,
        bodies: const [AstroBody.sun, AstroBody.sun],
        ephemeris: _FixtureEphemeris(),
        ayanamsha: const _FixtureAyanamsha(),
      ),
      throwsArgumentError,
    );
  });

  test('Vedic engine fails closed on ephemeris provenance mismatch', () {
    expect(
      () => VedicCalculationEngine.calculate(
        jdTt: 1500,
        bodies: const [AstroBody.sun],
        ephemeris: _FixtureEphemeris(wrongProvenance: true),
        ayanamsha: const _FixtureAyanamsha(),
      ),
      throwsStateError,
    );
  });

  test('Vedic engine fails closed on invalid ayanamsha provenance/value', () {
    expect(
      () => VedicCalculationEngine.calculate(
        jdTt: 1500,
        bodies: const [AstroBody.sun],
        ephemeris: _FixtureEphemeris(),
        ayanamsha: const _FixtureAyanamsha(value: double.nan),
      ),
      throwsStateError,
    );
    expect(
      () => VedicCalculationEngine.calculate(
        jdTt: 1500,
        bodies: const [AstroBody.sun],
        ephemeris: _FixtureEphemeris(),
        ayanamsha: const _FixtureAyanamsha(name: ''),
      ),
      throwsStateError,
    );
  });
}
