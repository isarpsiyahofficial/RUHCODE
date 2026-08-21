import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/karmic_debt.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanNumerologySnapshotEngine', () {
    test('assembles one consistent static snapshot', () {
      final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );

      expect(snapshot.profile.normalizedName, snapshot.extendedName.normalizedName);
      expect(snapshot.profile.lifePath, snapshot.pinnaclesChallenges.lifePath);
      expect(snapshot.birthDate, CivilDate(1990, 5, 19));
      expect(snapshot.personalCycles, isNull);
      expect(snapshot.targetDate, isNull);
      expect(snapshot.cycleKarmicDebt, isEmpty);
      expect(
        snapshot.profileKarmicDebt.map((item) => item.metric).toSet(),
        containsAll(<KarmicDebtMetric>{
          KarmicDebtMetric.expression,
          KarmicDebtMetric.birthday,
          KarmicDebtMetric.maturity,
        }),
      );
    });

    test('date-dependent cycles preserve the exact requested target date', () {
      final snapshot2026 = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 8, 16),
      );
      final snapshot2027 = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2027, 8, 16),
      );

      expect(snapshot2026.targetDate, CivilDate(2026, 8, 16));
      expect(snapshot2027.targetDate, CivilDate(2027, 8, 16));
      expect(snapshot2026.targetDate, isNot(snapshot2027.targetDate));
      expect(snapshot2026.personalCycles, isNotNull);
      expect(snapshot2027.personalCycles, isNotNull);
    });

    test('Karmic Debt findings retain upstream compound provenance', () {
      final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 1, 5),
      );

      final personalDayDebt = snapshot.cycleKarmicDebt.singleWhere(
        (item) => item.metric == KarmicDebtMetric.personalDay,
      );
      expect(personalDayDebt.compoundValue, 13);
      expect(personalDayDebt.reducedValue, 4);
      expect(personalDayDebt.provenance, 'personal_cycle.personal_day');
    });

    test('profile metrics stay unchanged when only target date changes', () {
      final first = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 8, 16),
      );
      final second = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2030, 2, 28),
      );

      expect(first.profile.lifePath, second.profile.lifePath);
      expect(first.profile.expression, second.profile.expression);
      expect(first.extendedName.balance, second.extendedName.balance);
      expect(first.pinnaclesChallenges.pinnacles, second.pinnaclesChallenges.pinnacles);
      expect(first.personalCycles!.targetDate, isNot(second.personalCycles!.targetDate));
    });
  });
}
