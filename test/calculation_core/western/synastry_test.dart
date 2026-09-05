import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_chart.dart';
import 'package:ruh_code/src/calculation_core/western/synastry.dart';

EclipticState state({
  required AstroBody body,
  required double jd,
  required double longitude,
  required double speed,
  String sourceId = 'fixture',
  String dataVersion = '1',
}) => EclipticState(
  body: body,
  jdTt: jd,
  longitudeDegrees: longitude,
  latitudeDegrees: 0,
  distanceAu: 1,
  longitudeSpeedDegreesPerDay: speed,
  sourceId: sourceId,
  dataVersion: dataVersion,
);

WesternNatalChart chart({
  required double jd,
  required List<EclipticState> states,
}) => WesternNatalChartAssembler.build(
  states: states,
  houses: EqualHouseSystems.equal(ascendantLongitude: 0),
);

void main() {
  test('RC-0069 and RC-0070 compare two complete natal snapshots without merging them', () {
    final personA = chart(
      jd: 2451545.0,
      states: [
        state(body: AstroBody.sun, jd: 2451545.0, longitude: 10, speed: 1),
        state(body: AstroBody.moon, jd: 2451545.0, longitude: 80, speed: 13),
      ],
    );
    final personB = chart(
      jd: 2455000.0,
      states: [
        state(body: AstroBody.mars, jd: 2455000.0, longitude: 100, speed: 0.5),
        state(body: AstroBody.venus, jd: 2455000.0, longitude: 10, speed: 1.2),
      ],
    );

    final comparison = WesternSynastry.compare(personA: personA, personB: personB);
    expect(comparison.personAJdTt, 2451545.0);
    expect(comparison.personBJdTt, 2455000.0);
    expect(
      comparison.aspects.any(
        (hit) =>
            hit.personABody == AstroBody.sun &&
            hit.personBBody == AstroBody.mars &&
            hit.aspect.name == 'square',
      ),
      isTrue,
    );
    expect(
      comparison.aspects.any(
        (hit) =>
            hit.personABody == AstroBody.sun &&
            hit.personBBody == AstroBody.venus &&
            hit.aspect.name == 'conjunction',
      ),
      isTrue,
    );
  });

  test('synastry rejects mismatched ephemeris provenance', () {
    final personA = chart(
      jd: 2451545.0,
      states: [state(body: AstroBody.sun, jd: 2451545.0, longitude: 10, speed: 1)],
    );
    final personB = chart(
      jd: 2455000.0,
      states: [
        state(
          body: AstroBody.sun,
          jd: 2455000.0,
          longitude: 20,
          speed: 1,
          dataVersion: '2',
        ),
      ],
    );
    expect(
      () => WesternSynastry.compare(personA: personA, personB: personB),
      throwsStateError,
    );
  });
}
