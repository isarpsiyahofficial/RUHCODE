import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/equal_house_systems.dart';
import 'package:ruh_code/src/calculation_core/western/natal_chart.dart';
import 'package:ruh_code/src/calculation_core/western/natal_aspects.dart';
import 'package:ruh_code/src/pdf/pdf_western_chart_geometry.dart';

void main() {
  EclipticState state(AstroBody body, double longitude) => EclipticState(
        body: body,
        jdTt: 2461000.5,
        longitudeDegrees: longitude,
        latitudeDegrees: 0,
        distanceAu: 1,
        longitudeSpeedDegreesPerDay: 1,
        sourceId: 'test-ephemeris',
        dataVersion: 'v1',
      );

  WesternNatalChart chart() => WesternNatalChartAssembler.build(
        states: <EclipticState>[
          state(AstroBody.sun, 0),
          state(AstroBody.moon, 90),
          state(AstroBody.mars, 180),
        ],
        houses: EqualHouseSystems.equal(ascendantLongitude: 0),
        orbPolicy: AspectOrbPolicy(
          maximumOrbDegrees: const {
            MajorAspect.conjunction: 0,
            MajorAspect.sextile: 0,
            MajorAspect.square: 0,
            MajorAspect.trine: 0,
            MajorAspect.opposition: 0,
          },
        ),
      );

  test('ASC is anchored at 9 o clock and increasing longitude is counter-clockwise', () {
    final geometry = PdfWesternChartGeometryAdapter.fromChart(chart());

    final asc = geometry.houseRays.first.outer;
    expect(asc.x, closeTo(-1, 1e-12));
    expect(asc.y, closeTo(0, 1e-12));

    final moon = geometry.planetMarkers.singleWhere((item) => item.body == AstroBody.moon);
    expect(moon.position.x, closeTo(0, 1e-12));
    expect(moon.position.y, closeTo(PdfWesternChartGeometryAdapter.planetRadius, 1e-12));
  });

  test('geometry is derived from exact house, placement and aspect sets', () {
    final source = chart();
    final geometry = PdfWesternChartGeometryAdapter.fromChart(source);

    expect(geometry.jdTt, source.jdTt);
    expect(geometry.sourceId, source.sourceId);
    expect(geometry.dataVersion, source.dataVersion);
    expect(geometry.houseRays, hasLength(12));
    expect(geometry.planetMarkers, hasLength(3));
    expect(geometry.aspectChords, hasLength(source.aspects.aspects.length));

    final sunMoon = geometry.aspectChords.singleWhere(
      (item) => item.bodyA == AstroBody.sun && item.bodyB == AstroBody.moon,
    );
    expect(sunMoon.aspect, MajorAspect.square);
    expect(sunMoon.start.x, closeTo(-PdfWesternChartGeometryAdapter.aspectRadius, 1e-12));
    expect(sunMoon.start.y, closeTo(0, 1e-12));
    expect(sunMoon.end.x, closeTo(0, 1e-12));
    expect(sunMoon.end.y, closeTo(PdfWesternChartGeometryAdapter.aspectRadius, 1e-12));
  });
}
