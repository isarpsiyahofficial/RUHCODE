import '../time/civil_calendar.dart';

enum PersonalCycleReductionPolicy {
  singleDigit,
  preserveMasterNumbers,
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
  });

  final CivilDate birthDate;
  final CivilDate targetDate;
  final PersonalCycleReductionPolicy policy;
  final int universalYear;
  final int personalYear;
  final int personalMonth;
  final int personalDay;
}

abstract final class PythagoreanPersonalDayEngine {
  static const String engineId = 'numerology.pythagorean.personal-day';
  static const String engineVersion = '1';
  static const Set<int> masterNumbers = <int>{11, 22, 33};

  static PersonalDayResult calculate({
    required CivilDate birthDate,
    required CivilDate targetDate,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    final universalYear = reduce(targetDate.year, policy: policy);
    final personalYear = reduce(
      birthDate.month + birthDate.day + universalYear,
      policy: policy,
    );
    final personalMonth = reduce(
      personalYear + targetDate.month,
      policy: policy,
    );
    final personalDay = reduce(
      personalMonth + targetDate.day,
      policy: policy,
    );

    return PersonalDayResult(
      birthDate: birthDate,
      targetDate: targetDate,
      policy: policy,
      universalYear: universalYear,
      personalYear: personalYear,
      personalMonth: personalMonth,
      personalDay: personalDay,
    );
  }

  static int reduce(
    int value, {
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.singleDigit,
  }) {
    if (value <= 0) {
      throw RangeError.value(value, 'value', 'Must be positive.');
    }

    var current = value;
    while (current > 9) {
      if (policy == PersonalCycleReductionPolicy.preserveMasterNumbers &&
          masterNumbers.contains(current)) {
        return current;
      }
      current = _digitSum(current);
    }
    return current;
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
