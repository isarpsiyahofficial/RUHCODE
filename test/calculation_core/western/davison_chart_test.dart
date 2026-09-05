import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/davison_chart.dart';

final class _FakeEphemeris implements EphemerisProvider {
  @override
  EphemerisCoverage get coverage => const EphemerisCoverage(
        startJdTt: 1000,
        endJdTt: 3000,
        sourceId: 'fixture',
        dataVersion: 'v1',
        checksumSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );

  @override
  EclipticState stateAt({required AstroBody body, required double jdTt}) {
    final longitude = (body.index * 20.0 + jdTt / 100.0) % 360.0;
    return EclipticState(
      body: body,
      jdTt: jdTt,
      longitudeDegrees: longitude,
      latitudeDegrees: 0,
      distanceAu: 1,
      longitudeSpeedDegreesPerDay: 1,
      sourceId: coverage.sourceId,
      dataVersion: coverage.dataVersion,
    );
  }
}

void main() {
  test('uses real midpoint TT and freshly evaluates ephemeris states', () {
    final chart = WesternDavisonChartBuilder.build(
      personAJdTt: 2000,
      personALocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: 0),
      personBJdTt: 2200,
      personBLocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: 20),
      ephemeris: _FakeEphemeris(),
      bodies: const [AstroBody.sun, AstroBody.moon],
    );

    expect(chart.jdTt, 2100);
    expect(chart.personAJdTt, 2000);
    expect(chart.personBJdTt, 2200);
    expect(chart.location.latitudeDegrees, closeTo(0, 1e-10));
    expect(chart.location.longitudeDegrees, closeTo(10, 1e-10));
    expect(chart.forBody(AstroBody.sun).jdTt, 2100);
    expect(chart.forBody(AstroBody.sun).longitudeDegrees, closeTo(21, 1e-12));
  });

  test('uses spherical geographic midpoint across the date line', () {
    final chart = WesternDavisonChartBuilder.build(
      personAJdTt: 2000,
      personALocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: 170),
      personBJdTt: 2000,
      personBLocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: -170),
      ephemeris: _FakeEphemeris(),
      bodies: const [AstroBody.sun],
    );

    expect(chart.location.longitudeDegrees.abs(), closeTo(180, 1e-10));
  });

  test('fails closed for antipodal geographic midpoint', () {
    expect(
      () => WesternDavisonChartBuilder.build(
        personAJdTt: 2000,
        personALocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: 0),
        personBJdTt: 2100,
        personBLocation: const GeographicPoint(latitudeDegrees: 0, longitudeDegrees: 180),
        ephemeris: _FakeEphemeris(),
        bodies: const [AstroBody.sun],
      ),
      throwsStateError,
    );
  });

  test('fails closed for duplicate body requests', () {
    expect(
      () => WesternDavisonChartBuilder.build(
        personAJdTt: 2000,
        personALocation: const GeographicPoint(latitudeDegrees: 10, longitudeDegrees: 20),
        personBJdTt: 2100,
        personBLocation: const GeographicPoint(latitudeDegrees: 20, longitudeDegrees: 30),
        ephemeris: _FakeEphemeris(),
        bodies: const [AstroBody.sun, AstroBody.sun],
      ),
      throwsStateError,
    );
  });
}
