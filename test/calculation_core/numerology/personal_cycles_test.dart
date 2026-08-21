import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/personal_day_factor.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_cycles.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanPersonalCycleEngine', () {
    final birthDate = CivilDate(1990, 5, 19);
    final targetDate = CivilDate(2026, 8, 16);

    test('exposes year, month and day from one exact-date calculation', () {
      final result = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
      );
      expect(result.universalYear, 1);
      expect(result.personalYear, 7);
      expect(result.personalMonth, 6);
      expect(result.personalDay, 4);
      expect(result.targetDate.isoKey, '2026-08-16');
    });

    test('preserves exact compound reduction traces for cycle provenance', () {
      final result = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
      );
      expect(result.universalYearTrace.steps, <int>[2026, 10, 1]);
      expect(result.personalYearTrace.steps, <int>[25, 7]);
      expect(result.personalMonthTrace.steps, <int>[15, 6]);
      expect(result.personalDayTrace.steps, <int>[22, 4]);
      expect(result.personalDayTrace.provenance, 'personal_cycle.personal_day');
    });

    test('master-number policy is explicit and deterministic', () {
      final result = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
        policy: PersonalCycleReductionPolicy.preserveMasterNumbers,
      );
      expect(result.personalYear, 7);
      expect(result.personalMonth, 6);
      expect(result.personalDay, 22);
      expect(result.personalDayTrace.steps, <int>[22]);
    });

    test('public cycle API remains in parity with DailySnapshot adapter', () {
      final cycle = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
      );
      const factor = PersonalDayDailyFactor();
      final dailyReference = factor.build(
        birthDate: birthDate,
        targetDate: targetDate,
      );
      expect(
        dailyReference.resultId,
        'personal-day|${targetDate.isoKey}|${cycle.personalDay}|'
        'py-${cycle.personalYear}|pm-${cycle.personalMonth}|singleDigit',
      );
    });

    test('different calendar years cannot collapse to the same target date', () {
      final nextYear = CivilDate(2027, 8, 16);
      final first = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: targetDate,
      );
      final second = PythagoreanPersonalCycleEngine.calculate(
        birthDate: birthDate,
        targetDate: nextYear,
      );
      expect(first.targetDate.isoKey, isNot(second.targetDate.isoKey));
      expect(first.personalYear, isNot(second.personalYear));
    });
  });
}
