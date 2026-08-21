import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/chaldean_name.dart';

void main() {
  group('ChaldeanNameEngine', () {
    test('uses the independent Chaldean table', () {
      expect(ChaldeanNameEngine.letterValue('A'), 1);
      expect(ChaldeanNameEngine.letterValue('I'), 1);
      expect(ChaldeanNameEngine.letterValue('J'), 1);
      expect(ChaldeanNameEngine.letterValue('F'), 8);
      expect(ChaldeanNameEngine.letterValue('P'), 8);
      expect(ChaldeanNameEngine.letterValue('Z'), 7);
    });

    test('is observably different from the Pythagorean mapping', () {
      expect(ChaldeanNameEngine.letterValue('I'), 1);
      expect(ChaldeanNameEngine.letterValue('R'), 2);
      expect(ChaldeanNameEngine.letterValue('Y'), 1);
    });

    test('calculates Turkish names after the explicit shared normalization', () {
      final result = ChaldeanNameEngine.calculate(fullName: 'İbrahim Yeşilyurt');

      expect(result.normalizedName, 'IBRAHIMYESILYURT');
      expect(result.compoundTotal, greaterThan(0));
      expect(result.reducedNumber, inInclusiveRange(1, 33));
    });

    test('rejects unsupported characters through the shared name policy', () {
      expect(
        () => ChaldeanNameEngine.calculate(fullName: 'Renée'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}