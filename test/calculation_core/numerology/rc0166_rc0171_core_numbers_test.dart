import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('RC-0166..RC-0171 Pythagorean core numbers', () {
    test('Life Path, Expression, Soul Urge, Personality, Birthday and Maturity are calculated independently', () {
      final result = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(2000, 1, 1),
        fullName: 'AB',
        policy: PersonalCycleReductionPolicy.singleDigit,
      );

      // 2000-01-01 => reduced month 1 + day 1 + year 2 = Life Path 4.
      expect(result.lifePath, 4);
      // Pythagorean A=1, B=2.
      expect(result.expression, 3);
      expect(result.soulUrge, 1);
      expect(result.personality, 2);
      expect(result.birthday, 1);
      expect(result.maturity, 7);

      expect(result.lifePathTrace.provenance, 'life_path.reduced_month_day_year_sum');
      expect(result.expressionTrace.provenance, 'expression.full_name_value_sum');
      expect(result.soulUrgeTrace.provenance, 'soul_urge.vowel_value_sum');
      expect(result.personalityTrace.provenance, 'personality.consonant_value_sum');
      expect(result.birthdayTrace.provenance, 'birthday.calendar_day');
      expect(result.maturityTrace.provenance, 'maturity.life_path_plus_expression');
    });

    test('Turkish letters are explicitly normalized instead of silently deleted', () {
      final normalized = PythagoreanNameNormalizer.normalize('Çağrı Şen');
      expect(normalized, 'CAGRI SEN'.replaceAll(' ', ''));
    });
  });
}
