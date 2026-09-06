import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_compatibility.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_rashi_chart.dart';

VedicRashiPlacement _placement(AstroBody body, int rashi) => VedicRashiPlacement(
      placement: VedicPlacement(
        body: body,
        siderealLongitudeDegrees: rashi * 30.0 + 1,
        longitudeSpeedDegreesPerDay: 1,
      ),
      rashiIndex: rashi,
      degreesWithinRashi: 1,
      wholeSignHouse: rashi + 1,
    );

VedicRashiChart _chart(int moonRashi) => VedicRashiChart(
      jdTt: 2460000.5,
      ephemerisSourceId: 'fixture-ephemeris',
      ephemerisDataVersion: '1',
      ayanamshaId: 'fixture-ayanamsha',
      ayanamshaDataVersion: '1',
      lagnaRashiIndex: 0,
      placements: [_placement(AstroBody.moon, moonRashi)],
    );

void main() {
  test('evaluates explicit versioned compatibility rules separately', () {
    final result = VedicCompatibilityEngine.evaluate(
      left: _chart(0),
      right: _chart(6),
      rules: [
        VedicCompatibilityRule(
          id: 'fixture-distance',
          version: '1',
          sourceId: 'test-only',
          leftBody: AstroBody.moon,
          rightBody: AstroBody.moon,
          allowedRelativeRashiDistances: const {7},
          points: 4,
        ),
      ],
    );
    expect(result.ruleResults.single.relativeRashiDistance, 7);
    expect(result.totalPoints, 4);
    expect(result.maxPoints, 4);
    expect(result.ruleResults.single.ruleSourceId, 'test-only');
  });

  test('does not award points when explicit rule does not match', () {
    final result = VedicCompatibilityEngine.evaluate(
      left: _chart(0),
      right: _chart(1),
      rules: [
        VedicCompatibilityRule(
          id: 'fixture-distance',
          version: '1',
          sourceId: 'test-only',
          leftBody: AstroBody.moon,
          rightBody: AstroBody.moon,
          allowedRelativeRashiDistances: const {7},
          points: 4,
        ),
      ],
    );
    expect(result.totalPoints, 0);
    expect(result.ruleResults.single.matched, isFalse);
  });

  test('fails closed on duplicate rule ids', () {
    VedicCompatibilityRule rule() => VedicCompatibilityRule(
          id: 'same',
          version: '1',
          sourceId: 'test-only',
          leftBody: AstroBody.moon,
          rightBody: AstroBody.moon,
          allowedRelativeRashiDistances: const {1},
          points: 1,
        );
    expect(
      () => VedicCompatibilityEngine.evaluate(
        left: _chart(0),
        right: _chart(0),
        rules: [rule(), rule()],
      ),
      throwsStateError,
    );
  });
}
