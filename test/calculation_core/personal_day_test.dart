import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanPersonalDayEngine', () {
    test('single-digit policy produces deterministic 2026 example', () {
      final result = PythagoreanPersonalDayEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        targetDate: CivilDate(2026, 8, 16),
      );

      expect(result.universalYear, 1);
      expect(result.personalYear, 7);
      expect(result.personalMonth, 6);
      expect(result.personalDay, 4);
      expect(result.policy, PersonalCycleReductionPolicy.singleDigit);
    });

    test('master-number policy preserves 22 at final reduction', () {
      final result = PythagoreanPersonalDayEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        targetDate: CivilDate(2026, 8, 16),
        policy: PersonalCycleReductionPolicy.preserveMasterNumbers,
      );

      expect(result.universalYear, 1);
      expect(result.personalYear, 7);
      expect(result.personalMonth, 6);
      expect(result.personalDay, 22);
    });

    test('different calendar year is recomputed independently', () {
      final first = PythagoreanPersonalDayEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        targetDate: CivilDate(2026, 8, 16),
      );
      final second = PythagoreanPersonalDayEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        targetDate: CivilDate(2027, 8, 16),
      );

      expect(first.personalDay, 4);
      expect(second.personalDay, 5);
      expect(first.targetDate, isNot(second.targetDate));
    });

    test('leap day is accepted through strict CivilDate', () {
      final result = PythagoreanPersonalDayEngine.calculate(
        birthDate: CivilDate(1992, 2, 29),
        targetDate: CivilDate(2028, 2, 29),
      );

      expect(result.targetDate.isoKey, '2028-02-29');
      expect(result.personalDay, inInclusiveRange(1, 9));
    });

    test('reduction rejects non-positive values', () {
      expect(
        () => PythagoreanPersonalDayEngine.reduce(0),
        throwsRangeError,
      );
    });
  });
}
