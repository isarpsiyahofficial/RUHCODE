import '../time/civil_calendar.dart';
import 'personal_day.dart';

final class PythagoreanPinnacleChallengeResult {
  const PythagoreanPinnacleChallengeResult({
    required this.birthDate,
    required this.policy,
    required this.lifePath,
    required this.pinnacles,
    required this.challenges,
    required this.firstPeriodEndAgeInclusive,
    required this.secondPeriodEndAgeInclusive,
    required this.thirdPeriodEndAgeInclusive,
  });

  final CivilDate birthDate;
  final PersonalCycleReductionPolicy policy;
  final int lifePath;
  final List<int> pinnacles;
  final List<int> challenges;

  /// The first Pinnacle/Challenge period runs from birth through this age.
  final int firstPeriodEndAgeInclusive;

  /// The second period is the following nine-year span, inclusive.
  final int secondPeriodEndAgeInclusive;

  /// The third period is the following nine-year span, inclusive.
  /// The fourth period begins at the next birthday and has no fixed end.
  final int thirdPeriodEndAgeInclusive;
}

abstract final class PythagoreanPinnacleChallengeEngine {
  static const String engineId = 'numerology.pythagorean.pinnacles-challenges';
  static const String engineVersion = '1';

  static PythagoreanPinnacleChallengeResult calculate({
    required CivilDate birthDate,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
  }) {
    final month = PythagoreanPersonalDayEngine.reduce(
      birthDate.month,
      policy: policy,
    );
    final day = PythagoreanPersonalDayEngine.reduce(
      birthDate.day,
      policy: policy,
    );
    final year = PythagoreanPersonalDayEngine.reduce(
      birthDate.year,
      policy: policy,
    );
    final lifePath = PythagoreanPersonalDayEngine.reduce(
      month + day + year,
      policy: policy,
    );

    int pinnacle(int value) => PythagoreanPersonalDayEngine.reduce(
          value,
          policy: policy,
        );

    final p1 = pinnacle(month + day);
    final p2 = pinnacle(day + year);
    final p3 = pinnacle(p1 + p2);
    final p4 = pinnacle(month + year);

    // Challenges are differences, not additive master-number expressions.
    // Their canonical range is therefore reduced to 0..9 without preserving
    // 11/22/33. A zero challenge is meaningful and must not be rejected.
    int challengeDifference(int left, int right) {
      final difference = (left - right).abs();
      if (difference == 0) return 0;
      return PythagoreanPersonalDayEngine.reduce(
        difference,
        policy: PersonalCycleReductionPolicy.singleDigit,
      );
    }

    final c1 = challengeDifference(day, month);
    final c2 = challengeDifference(year, day);
    final c3 = challengeDifference(c1, c2);
    final c4 = challengeDifference(year, month);

    final firstEnd = 36 - lifePath;
    if (firstEnd < 0) {
      throw StateError('Life Path yields an invalid first-period boundary.');
    }

    return PythagoreanPinnacleChallengeResult(
      birthDate: birthDate,
      policy: policy,
      lifePath: lifePath,
      pinnacles: List<int>.unmodifiable(<int>[p1, p2, p3, p4]),
      challenges: List<int>.unmodifiable(<int>[c1, c2, c3, c4]),
      firstPeriodEndAgeInclusive: firstEnd,
      secondPeriodEndAgeInclusive: firstEnd + 9,
      thirdPeriodEndAgeInclusive: firstEnd + 18,
    );
  }
}
