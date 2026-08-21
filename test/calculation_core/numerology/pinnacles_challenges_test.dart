import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pinnacles_challenges.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanPinnacleChallengeEngine', () {
    const birthDate = CivilDate(year: 1990, month: 5, day: 19);

    test('calculates four Pinnacles and four Challenges deterministically', () {
      final result = PythagoreanPinnacleChallengeEngine.calculate(
        birthDate: birthDate,
      );

      expect(result.lifePath, 7);
      expect(result.pinnacles, <int>[6, 2, 8, 6]);
      expect(result.challenges, <int>[4, 0, 4, 4]);
    });

    test('period boundaries are explicit inclusive ages', () {
      final result = PythagoreanPinnacleChallengeEngine.calculate(
        birthDate: birthDate,
      );

      expect(result.firstPeriodEndAgeInclusive, 29);
      expect(result.secondPeriodEndAgeInclusive, 38);
      expect(result.thirdPeriodEndAgeInclusive, 47);
    });

    test('zero challenge remains zero instead of being rejected', () {
      final result = PythagoreanPinnacleChallengeEngine.calculate(
        birthDate: birthDate,
      );

      expect(result.challenges[1], 0);
    });

    test('single-digit policy is explicit and supported', () {
      final result = PythagoreanPinnacleChallengeEngine.calculate(
        birthDate: const CivilDate(year: 1984, month: 11, day: 22),
        policy: PersonalCycleReductionPolicy.singleDigit,
      );

      expect(result.pinnacles, hasLength(4));
      expect(result.challenges, hasLength(4));
      expect(result.pinnacles.every((value) => value >= 1 && value <= 9), isTrue);
      expect(result.challenges.every((value) => value >= 0 && value <= 9), isTrue);
    });
  });
}
