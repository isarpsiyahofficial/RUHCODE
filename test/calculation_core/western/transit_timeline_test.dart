import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/western/natal_aspects.dart';
import 'package:ruh_code/src/calculation_core/western/transit_chart.dart';
import 'package:ruh_code/src/calculation_core/western/transit_timeline.dart';

NatalTransitComparison comparison({
  required double jd,
  required MajorAspect aspect,
  required double orb,
  String sourceId = 'fixture',
  String dataVersion = '1',
}) => NatalTransitComparison(
  natalJdTt: 2451545.0,
  transitJdTt: jd,
  sourceId: sourceId,
  dataVersion: dataVersion,
  aspects: [
    TransitNatalAspectHit(
      transitBody: AstroBody.mars,
      natalBody: AstroBody.sun,
      aspect: aspect,
      separationDegrees: aspect.exactAngleDegrees + orb,
      orbDegrees: orb,
      phase: AspectPhase.applying,
    ),
  ],
);

void main() {
  test('RC-0068 filters important aspects and sorts events chronologically', () {
    final events = WesternTransitTimeline.build(
      comparisons: [
        comparison(jd: 2460002.5, aspect: MajorAspect.square, orb: 1.0),
        comparison(jd: 2460000.5, aspect: MajorAspect.trine, orb: 0.5),
        comparison(jd: 2460001.5, aspect: MajorAspect.sextile, orb: 0.1),
      ],
    );
    expect(events.length, 2);
    expect(events.first.jdTt, 2460000.5);
    expect(events.last.jdTt, 2460002.5);
  });

  test('custom important-transit policy is explicit and deterministic', () {
    final events = WesternTransitTimeline.build(
      comparisons: [
        comparison(jd: 2460000.5, aspect: MajorAspect.sextile, orb: 0.4),
      ],
      policy: ImportantTransitPolicy(
        aspects: {MajorAspect.sextile},
        maximumOrbDegrees: 0.5,
      ),
    );
    expect(events.single.aspect, MajorAspect.sextile);
  });

  test('timeline rejects mixed ephemeris provenance', () {
    expect(
      () => WesternTransitTimeline.build(
        comparisons: [
          comparison(jd: 2460000.5, aspect: MajorAspect.square, orb: 0.5),
          comparison(
            jd: 2460001.5,
            aspect: MajorAspect.square,
            orb: 0.5,
            dataVersion: '2',
          ),
        ],
      ),
      throwsStateError,
    );
  });
}
