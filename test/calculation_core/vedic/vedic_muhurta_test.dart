import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_muhurta.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_panchanga.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_panchanga_snapshot.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_vara.dart';

VedicPanchangaSnapshot _snapshot() => VedicPanchangaSnapshot(
      core: const VedicPanchangaCore(
        jdTt: 2460000.5,
        siderealSunLongitudeDegrees: 10,
        siderealMoonLongitudeDegrees: 100,
        tithiIndex: 8,
        tithiInPaksha: 8,
        paksha: VedicPaksha.shukla,
        nakshatraIndex: 9,
        yogaIndex: 10,
        karanaHalfTithiIndex: 15,
        karana: VedicKarana.bava,
        ephemerisSourceId: 'fixture-ephemeris',
        ephemerisDataVersion: '1',
        ayanamshaId: 'fixture-ayanamsha',
        ayanamshaDataVersion: '1',
      ),
      vara: const VedicVaraResult(
        vara: VedicVara.somavara,
        sunriseJdUt1: 2460000.25,
        sourceId: 'fixture-sunrise',
        dataVersion: '1',
      ),
    );

void main() {
  test('evaluates explicit Panchanga-based Muhurta rules independently', () {
    final result = VedicMuhurtaEngine.evaluate(
      panchanga: _snapshot(),
      rules: [
        MuhurtaRule(
          id: 'fixture-tithi',
          version: '1',
          sourceId: 'test-only',
          field: MuhurtaPanchangaField.tithi,
          acceptedValues: const {8},
          points: 2,
        ),
        MuhurtaRule(
          id: 'fixture-vara',
          version: '1',
          sourceId: 'test-only',
          field: MuhurtaPanchangaField.vara,
          acceptedValues: const {2},
          points: 3,
        ),
      ],
    );
    expect(result.totalPoints, 5);
    expect(result.maxPoints, 5);
    expect(result.ruleResults.every((rule) => rule.matched), isTrue);
    expect(result.sunriseSourceId, 'fixture-sunrise');
  });

  test('keeps nonmatching rule visible with zero awarded points', () {
    final result = VedicMuhurtaEngine.evaluate(
      panchanga: _snapshot(),
      rules: [
        MuhurtaRule(
          id: 'fixture-nakshatra',
          version: '1',
          sourceId: 'test-only',
          field: MuhurtaPanchangaField.nakshatra,
          acceptedValues: const {1},
          points: 4,
        ),
      ],
    );
    expect(result.totalPoints, 0);
    expect(result.ruleResults.single.observedValue, 9);
  });

  test('fails closed on duplicate Muhurta rule ids', () {
    MuhurtaRule rule() => MuhurtaRule(
          id: 'same',
          version: '1',
          sourceId: 'test-only',
          field: MuhurtaPanchangaField.yoga,
          acceptedValues: const {10},
          points: 1,
        );
    expect(
      () => VedicMuhurtaEngine.evaluate(
        panchanga: _snapshot(),
        rules: [rule(), rule()],
      ),
      throwsStateError,
    );
  });
}
