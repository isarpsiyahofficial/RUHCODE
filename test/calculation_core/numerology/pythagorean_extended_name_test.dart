import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_extended_name.dart';

void main() {
  group('PythagoreanExtendedNameEngine', () {
    test('computes Balance, Karmic Lessons and Hidden Passion explicitly', () {
      final result = PythagoreanExtendedNameEngine.calculate(
        fullName: 'İbrahim Yeşilyurt',
      );

      expect(result.normalizedName, 'IBRAHIMYESILYURT');
      expect(result.balance, 7);
      expect(result.karmicLessons, <int>[6]);
      expect(result.hiddenPassions, <int>[9]);
      expect(result.valueFrequencies[9], 5);
    });

    test('hyphen creates a separate Balance initial but not unsupported data', () {
      final result = PythagoreanExtendedNameEngine.calculate(
        fullName: 'Ada-Lale Kaya',
      );

      expect(result.normalizedName, 'ADALALEKAYA');
      expect(result.balance, greaterThanOrEqualTo(1));
      expect(result.balance, lessThanOrEqualTo(33));
    });

    test('unsupported characters are rejected by canonical name normalizer', () {
      expect(
        () => PythagoreanExtendedNameEngine.calculate(fullName: 'Ada 王'),
        throwsFormatException,
      );
    });

    test('frequency map always covers exact Pythagorean values 1 through 9', () {
      final result = PythagoreanExtendedNameEngine.calculate(fullName: 'Ada Kaya');
      expect(result.valueFrequencies.keys.toList(), <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
  });
}
