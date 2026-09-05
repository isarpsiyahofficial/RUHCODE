import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/composite_chart.dart';
import 'package:ruh_code/src/calculation_core/western/natal_placements.dart';

void main() {
  NatalPlacement placement(AstroBody body, double longitude) {
    final signIndex = (longitude / 30).floor() % 12;
    return NatalPlacement(
      body: body,
      longitudeDegrees: longitude,
      longitudeSpeedDegreesPerDay: 1,
      sign: TropicalZodiacSign.values[signIndex],
      degreeInSign: longitude - signIndex * 30,
      houseNumber: 1,
      motion: ApparentMotion.direct,
    );
  }

  NatalPlacementSet set({
    required double jd,
    required List<NatalPlacement> placements,
    String source = 'de440s',
    String version = 'v1',
  }) => NatalPlacementSet(
    jdTt: jd,
    sourceId: source,
    dataVersion: version,
    placements: placements,
  );

  test('uses shortest circular midpoint across Aries boundary', () {
    final chart = WesternCompositeChartBuilder.build(
      personA: set(
        jd: 2451545,
        placements: [placement(AstroBody.sun, 350)],
      ),
      personB: set(
        jd: 2452000,
        placements: [placement(AstroBody.sun, 10)],
      ),
    );

    final sun = chart.forBody(AstroBody.sun);
    expect(sun.longitudeDegrees, closeTo(0, 1e-12));
    expect(sun.sign, TropicalZodiacSign.aries);
    expect(sun.degreeInSign, closeTo(0, 1e-12));
    expect(chart.personAJdTt, 2451545);
    expect(chart.personBJdTt, 2452000);
  });

  test('creates deterministic midpoints for identical body sets', () {
    final chart = WesternCompositeChartBuilder.build(
      personA: set(
        jd: 1,
        placements: [
          placement(AstroBody.sun, 20),
          placement(AstroBody.moon, 80),
        ],
      ),
      personB: set(
        jd: 2,
        placements: [
          placement(AstroBody.sun, 40),
          placement(AstroBody.moon, 100),
        ],
      ),
    );

    expect(chart.forBody(AstroBody.sun).longitudeDegrees, 30);
    expect(chart.forBody(AstroBody.moon).longitudeDegrees, 90);
    expect(chart.placements.map((e) => e.body).toList(), [
      AstroBody.sun,
      AstroBody.moon,
    ]..sort((a, b) => a.index.compareTo(b.index)));
  });

  test('fails closed for mismatched provenance', () {
    expect(
      () => WesternCompositeChartBuilder.build(
        personA: set(
          jd: 1,
          placements: [placement(AstroBody.sun, 10)],
          source: 'a',
        ),
        personB: set(
          jd: 2,
          placements: [placement(AstroBody.sun, 20)],
          source: 'b',
        ),
      ),
      throwsStateError,
    );
  });

  test('fails closed for unequal body sets', () {
    expect(
      () => WesternCompositeChartBuilder.build(
        personA: set(
          jd: 1,
          placements: [placement(AstroBody.sun, 10)],
        ),
        personB: set(
          jd: 2,
          placements: [placement(AstroBody.moon, 20)],
        ),
      ),
      throwsStateError,
    );
  });
}
