import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_chart.dart';
import 'package:ruh_code/src/calculation_core/western/transit_chart.dart';

EclipticState state({
  required AstroBody body,
  required double jd,
  required double longitude,
  required double speed,
}) => EclipticState(
  body: body,
  jdTt: jd,
  longitudeDegrees: longitude,
  latitudeDegrees: 0,
  distanceAu: 1,
  longitudeSpeedDegreesPerDay: speed,
  sourceId: 'fixture',
  dataVersion: '1',
);

WesternNatalChart natalChart() => WesternNatalChartAssembler.build(
  states: [
    state(body: AstroBody.sun, jd: 2451545.0, longitude: 10, speed: 1),
    state(body: AstroBody.moon, jd: 2451545.0, longitude: 80, speed: 13),
  ],
  houses: EqualHouseSystems.equal(ascendantLongitude: 0),
);

void main() {
  test('RC-0063 builds deterministic transit chart from one explicit TT instant', () {
    final chart = WesternTransitChart.build(states: [
      state(body: AstroBody.sun, jd: 2460000.5, longitude: 40, speed: 1),
      state(body: AstroBody.mars, jd: 2460000.5, longitude: 190, speed: -0.4),
    ]);
    expect(chart.jdTt, 2460000.5);
    expect(chart.forBody(AstroBody.sun).degreeInSign, 10);
    expect(chart.forBody(AstroBody.mars).motion, ApparentMotion.retrograde);
  });

  test('RC-0065 and RC-0066 preserve any explicit historical/future TT instant', () {
    final past = WesternTransitChart.build(states: [
      state(body: AstroBody.sun, jd: 2400000.5, longitude: 1, speed: 1),
    ]);
    final future = WesternTransitChart.build(states: [
      state(body: AstroBody.sun, jd: 2500000.5, longitude: 2, speed: 1),
    ]);
    expect(past.jdTt, 2400000.5);
    expect(future.jdTt, 2500000.5);
  });

  test('RC-0064 and RC-0067 compare transit bodies against fixed natal positions', () {
    final transit = WesternTransitChart.build(states: [
      state(body: AstroBody.mars, jd: 2460000.5, longitude: 100, speed: 0.5),
    ]);
    final comparison = WesternNatalTransit.compare(
      natal: natalChart(),
      transit: transit,
    );
    final hit = comparison.aspects.singleWhere(
      (item) => item.transitBody == AstroBody.mars && item.natalBody == AstroBody.sun,
    );
    expect(hit.aspect.name, 'square');
    expect(hit.orbDegrees, closeTo(0, 1e-12));
    expect(comparison.natalJdTt, 2451545.0);
    expect(comparison.transitJdTt, 2460000.5);
  });

  test('transit chart rejects mixed instants and provenance', () {
    expect(
      () => WesternTransitChart.build(states: [
        state(body: AstroBody.sun, jd: 2460000.5, longitude: 40, speed: 1),
        state(body: AstroBody.moon, jd: 2460001.5, longitude: 80, speed: 13),
      ]),
      throwsStateError,
    );
  });
}
