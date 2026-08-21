import '../time/civil_calendar.dart';

enum PersonalCycleReductionPolicy {
  singleDigit,
  preserveMasterNumbers,
}

final class PersonalCycleReductionTrace {
  const PersonalCycleReductionTrace({
    required this.sourceValue,
    required this.steps,
    required this.reducedValue,
    required this.provenance,
  });

  final int sourceValue;
  final List<int> steps;
  final int reducedValue;
  final String provenance;

  Iterable<int> get observedCompounds sync* {
    for (final value in steps) {
      if (value > 9) yield value;
    }
  }
}

final class PersonalDayResult {
  const PersonalDayResult({
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

abstract final class PythagoreanPersonalDayEngine {
  static const String engineId = 'numerology.pythagorean.personal-day';
  static const String engineVersion = '2';
  static const Set<int> masterNumbers = <int>{11, 22, 33};

  static PersonalDayResult calculate({
    required CivilDate birthDate,
    required CivilDate targetDate,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    final universalYearTrace = traceReduction(
      targetDate.year,
      policy: policy,
      provenance: 'personal_cycle.universal_year',
    );
    final personalYearTrace = traceReduction(
      birthDate.month + birthDate.day + universalYearTrace.reducedValue,
      policy: policy,
      provenance: 'personal_cycle.personal_year',
    );
    final personalMonthTrace = traceReduction(
      personalYearTrace.reducedValue + targetDate.month,
      policy: policy,
      provenance: 'personal_cycle.personal_month',
    );
    final personalDayTrace = traceReduction(
      personalMonthTrace.reducedValue + targetDate.day,
      policy: policy,
      provenance: 'personal_cycle.personal_day',
    );

    return PersonalDayResult(
      birthDate: birthDate,
      targetDate: targetDate,
      policy: policy,
      universalYear: universalYearTrace.reducedValue,
      personalYear: personalYearTrace.reducedValue,
      personalMonth: personalMonthTrace.reducedValue,
      personalDay: personalDayTrace.reducedValue,
      universalYearTrace: universalYearTrace,
      personalYearTrace: personalYearTrace,
      personalMonthTrace: personalMonthTrace,
      personalDayTrace: personalDayTrace,
    );
  }

  static int reduce(
    int value, {
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    return traceReduction(
      value,
      policy: policy,
      provenance: 'numerology.reduction',
    ).reducedValue;
  }

  static PersonalCycleReductionTrace traceReduction(
    int value, {
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
    required String provenance,
  }) {
    if (value <= 0) {
      throw RangeError.value(value, 'value', 'Must be positive.');
    }
    if (provenance.trim().isEmpty) {
      throw const FormatException('Reduction provenance cannot be blank.');
    }

    final steps = <int>[value];
    var current = value;
    while (current > 9) {
      if (policy == PersonalCycleReductionPolicy.preserveMasterNumbers &&
          masterNumbers.contains(current)) {
        break;
      }
      current = _digitSum(current);
      steps.add(current);
    }

    return PersonalCycleReductionTrace(
      sourceValue: value,
      steps: List<int>.unmodifiable(steps),
      reducedValue: current,
      provenance: provenance,
    );
  }

  static int _digitSum(int value) {
    var remaining = value;
    var sum = 0;
    while (remaining > 0) {
      sum += remaining % 10;
      remaining ~/= 10;
    }
    return sum;
  }
}
