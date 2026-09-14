import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_compatibility.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

BaziPillar _pillar(BaziPillarKind kind, int index) {
  final value = SexagenaryCycle.at(index);
  return BaziPillar(
    kind: kind,
    stem: value.stem,
    branch: value.branch,
    sexagenaryCycleIndex: value.cycleIndex,
  );
}

BaziFourPillarsSnapshot _snapshot(int offset) => BaziFourPillarsSnapshot(
      birthInstantUtc: DateTime.utc(1990, 1, 1).add(Duration(days: offset)),
      year: _pillar(BaziPillarKind.year, offset),
      month: _pillar(BaziPillarKind.month, offset + 1),
      day: _pillar(BaziPillarKind.day, offset + 2),
      hour: _pillar(BaziPillarKind.hour, offset + 3),
      sourceId: 'fixture:bazi-four-pillars',
      version: '1.0.0-test',
      conventionId: 'fixture-convention',
    );

void main() {
  group('RC-0158 BaZi future compatibility extension point', () {
    test('versioned rules can extend compatibility without changing BaZi core', () {
      final result = BaziCompatibilityEngine.evaluate(
        a: _snapshot(0),
        b: _snapshot(10),
        rules: <BaziCompatibilityRule>[
          BaziCompatibilityRule(
            id: 'fixture-rule-a',
            version: '1.0.0',
            sourceId: 'fixture:rule-a',
            maxScore: 60,
            evaluate: (_, __) => 40,
          ),
          BaziCompatibilityRule(
            id: 'fixture-rule-b',
            version: '2.0.0',
            sourceId: 'fixture:rule-b',
            maxScore: 40,
            evaluate: (_, __) => 25,
          ),
        ],
      );

      expect(result.results, hasLength(2));
      expect(result.score, 65);
      expect(result.maxScore, 100);
      expect(result.results.first.sourceId, 'fixture:rule-a');
      expect(result.results.last.version, '2.0.0');
    });

    test('duplicate rule identities and invalid scores fail closed', () {
      BaziCompatibilityRule rule(String source, double score) =>
          BaziCompatibilityRule(
            id: 'same-rule',
            version: '1.0.0',
            sourceId: source,
            maxScore: 10,
            evaluate: (_, __) => score,
          );

      expect(
        () => BaziCompatibilityEngine.evaluate(
          a: _snapshot(0),
          b: _snapshot(1),
          rules: <BaziCompatibilityRule>[
            rule('fixture:a', 5),
            rule('fixture:b', 5),
          ],
        ),
        throwsStateError,
      );

      expect(
        () => BaziCompatibilityEngine.evaluate(
          a: _snapshot(0),
          b: _snapshot(1),
          rules: <BaziCompatibilityRule>[
            BaziCompatibilityRule(
              id: 'overflow-rule',
              version: '1.0.0',
              sourceId: 'fixture:overflow',
              maxScore: 10,
              evaluate: (_, __) => 11,
            ),
          ],
        ),
        throwsStateError,
      );
    });
  });
}
