import '../time/civil_calendar.dart';
import 'personal_day.dart';

/// Public, deterministic Pythagorean cycle snapshot for one exact target date.
///
/// Personal Year, Month and Day are deliberately exposed from one calculation
/// so callers cannot accidentally mix reduction policies or target dates.
final class PythagoreanPersonalCycleResult {
  const PythagoreanPersonalCycleResult({
    required this.birthDate,
    required this.targetDate,
    required this.policy,
    required this.universalYear,
    required this.personalYear,
    required this.personalMonth,
    required this.personalDay,
    required this.universalYearTrace,
    required this.personalYearTrace,
    required this.personalMonthTrace,
    required this.personalDayTrace,
  });

  final CivilDate birthDate;
  final CivilDate targetDate;
  final PersonalCycleReductionPolicy policy;
  final int universalYear;
  final int personalYear;
  final int personalMonth;
  final int personalDay;
  final PersonalCycleReductionTrace universalYearTrace;
  final PersonalCycleReductionTrace personalYearTrace;
  final PersonalCycleReductionTrace personalMonthTrace;
  final PersonalCycleReductionTrace personalDayTrace;
}

abstract final class PythagoreanPersonalCycleEngine {
  static const String engineId = 'numerology.pythagorean.personal-cycles';
  static const String engineVersion = '2';

  static PythagoreanPersonalCycleResult calculate({
    required CivilDate birthDate,
    required CivilDate targetDate,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    final legacy = PythagoreanPersonalDayEngine.calculate(
      birthDate: birthDate,
      targetDate: targetDate,
      policy: policy,
    );

    return PythagoreanPersonalCycleResult(
      birthDate: legacy.birthDate,
      targetDate: legacy.targetDate,
      policy: legacy.policy,
      universalYear: legacy.universalYear,
      personalYear: legacy.personalYear,
      personalMonth: legacy.personalMonth,
      personalDay: legacy.personalDay,
      universalYearTrace: legacy.universalYearTrace,
      personalYearTrace: legacy.personalYearTrace,
      personalMonthTrace: legacy.personalMonthTrace,
      personalDayTrace: legacy.personalDayTrace,
    );
  }
}
