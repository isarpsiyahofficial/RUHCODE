import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanNameNormalizer', () {
    test('normalizes Turkish letters explicitly without silent deletion', () {
      expect(
        PythagoreanNameNormalizer.normalize('İbrahim Yeşilyurt'),
        'IBRAHIMYESILYURT',
      );
      expect(
        PythagoreanNameNormalizer.normalize("Çağrı Öztürk-Şen"),
        'CAGRIOZTURKSEN',
      );
    });

    test('rejects unsupported alphabet characters instead of guessing', () {
      expect(
        () => PythagoreanNameNormalizer.normalize('Renée'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => PythagoreanNameNormalizer.normalize('123'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PythagoreanProfileEngine', () {
    test('uses canonical repeating 1-9 A-Z letter values', () {
      expect(PythagoreanProfileEngine.letterValue('A'), 1);
      expect(PythagoreanProfileEngine.letterValue('I'), 9);
      expect(PythagoreanProfileEngine.letterValue('J'), 1);
      expect(PythagoreanProfileEngine.letterValue('R'), 9);
      expect(PythagoreanProfileEngine.letterValue('Z'), 8);
    });

    test('calculates core profile values deterministically', () {
      final result = PythagoreanProfileEngine.calculate(
        birthDate: const CivilDate(year: 1990, month: 5, day: 19),
        fullName: 'İbrahim Yeşilyurt',
      );

      expect(result.normalizedName, 'IBRAHIMYESILYURT');
      expect(result.lifePath, 7);
      expect(result.expression, 7);
      expect(result.soulUrge, 9);
      expect(result.personality, 7);
      expect(result.birthday, 1);
      expect(result.maturity, 5);
    });

    test('preserves master numbers only when policy requests it', () {
      final preserved = PythagoreanProfileEngine.calculate(
        birthDate: const CivilDate(year: 2000, month: 1, day: 11),
        fullName: 'AJA',
      );
      final reduced = PythagoreanProfileEngine.calculate(
        birthDate: const CivilDate(year: 2000, month: 1, day: 11),
        fullName: 'AJA',
        policy: PersonalCycleReductionPolicy.singleDigit,
      );

      expect(preserved.birthday, 11);
      expect(reduced.birthday, 2);
    });

    test('Y is treated consistently as a consonant in v1 policy', () {
      final result = PythagoreanProfileEngine.calculate(
        birthDate: const CivilDate(year: 1999, month: 8, day: 20),
        fullName: 'AY',
      );

      expect(result.soulUrge, 1);
      expect(result.personality, 7);
    });
  });
}