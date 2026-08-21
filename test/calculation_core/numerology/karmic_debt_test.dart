import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/karmic_debt.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_cycles.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanKarmicDebtEngine', () {
    test('detects only canonical compounds with exact provenance', () {
      final findings = PythagoreanKarmicDebtEngine.detect(<KarmicDebtObservation>[
        const KarmicDebtObservation(
          metric: KarmicDebtMetric.lifePath,
          compoundValue: 13,
          reducedValue: 4,
          provenance: 'life_path.birth_date_digit_sum',
        ),
        const KarmicDebtObservation(
          metric: KarmicDebtMetric.expression,
          compoundValue: 14,
          reducedValue: 5,
          provenance: 'expression.full_name_value_sum',
        ),
        const KarmicDebtObservation(
          metric: KarmicDebtMetric.soulUrge,
          compoundValue: 16,
          reducedValue: 7,
          provenance: 'soul_urge.vowel_value_sum',
        ),
        const KarmicDebtObservation(
          metric: KarmicDebtMetric.birthday,
          compoundValue: 19,
          reducedValue: 1,
          provenance: 'birthday.calendar_day',
        ),
      ]);

      expect(findings.map((e) => e.compoundValue).toList(), <int>[13, 14, 16, 19]);
      expect(findings.map((e) => e.reducedValue).toList(), <int>[4, 5, 7, 1]);
    });

    test('builds observations only from compounds actually seen upstream', () {
      final profile = PythagoreanProfileEngine.calculate(
        birthDate: const CivilDate(year: 1990, month: 5, day: 19),
        fullName: 'İbrahim Yeşilyurt',
      );

      final observations = PythagoreanKarmicDebtEngine.observationsFromProfile(profile);
      final findings = PythagoreanKarmicDebtEngine.detect(observations);

      expect(
        observations.map((item) => item.metric).toSet(),
        <KarmicDebtMetric>{
          KarmicDebtMetric.expression,
          KarmicDebtMetric.birthday,
          KarmicDebtMetric.maturity,
        },
      );
      expect(
        findings.map((item) => item.compoundValue).toSet(),
        <int>{16, 19, 14},
      );
      expect(
        findings
            .firstWhere((item) => item.metric == KarmicDebtMetric.expression)
            .provenance,
        'expression.full_name_value_sum',
      );
    });

    test('builds cycle debt only from an observed cycle compound', () {
      final cycles = PythagoreanPersonalCycleEngine.calculate(
        birthDate: const CivilDate(year: 1990, month: 5, day: 19),
        targetDate: const CivilDate(year: 2026, month: 1, day: 5),
      );

      final observations =
          PythagoreanKarmicDebtEngine.observationsFromPersonalCycles(cycles);
      final findings = PythagoreanKarmicDebtEngine.detect(observations);

      expect(cycles.personalDayTrace.steps, <int>[13, 4]);
      expect(observations, hasLength(1));
      expect(observations.single.metric, KarmicDebtMetric.personalDay);
      expect(observations.single.compoundValue, 13);
      expect(observations.single.provenance, 'personal_cycle.personal_day');
      expect(findings.single.reducedValue, 4);
    });

    test('reduced value alone never invents a Karmic Debt compound', () {
      final findings = PythagoreanKarmicDebtEngine.detect(<KarmicDebtObservation>[
        const KarmicDebtObservation(
          metric: KarmicDebtMetric.lifePath,
          compoundValue: 22,
          reducedValue: 4,
          provenance: 'life_path.birth_date_digit_sum',
        ),
      ]);

      expect(findings, isEmpty);
    });

    test('rejects mismatched compound and reduced values', () {
      expect(
        () => PythagoreanKarmicDebtEngine.detect(<KarmicDebtObservation>[
          const KarmicDebtObservation(
            metric: KarmicDebtMetric.lifePath,
            compoundValue: 13,
            reducedValue: 5,
            provenance: 'life_path.birth_date_digit_sum',
          ),
        ]),
        throwsStateError,
      );
    });

    test('rejects duplicate metric observations', () {
      expect(
        () => PythagoreanKarmicDebtEngine.detect(<KarmicDebtObservation>[
          const KarmicDebtObservation(
            metric: KarmicDebtMetric.birthday,
            compoundValue: 13,
            reducedValue: 4,
            provenance: 'birthday.calendar_day',
          ),
          const KarmicDebtObservation(
            metric: KarmicDebtMetric.birthday,
            compoundValue: 14,
            reducedValue: 5,
            provenance: 'birthday.calendar_day',
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('requires non-empty provenance', () {
      expect(
        () => PythagoreanKarmicDebtEngine.detect(<KarmicDebtObservation>[
          const KarmicDebtObservation(
            metric: KarmicDebtMetric.expression,
            compoundValue: 14,
            reducedValue: 5,
            provenance: '   ',
          ),
        ]),
        throwsFormatException,
      );
    });
  });
}
