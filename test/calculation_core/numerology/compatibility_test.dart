import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/compatibility.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_profile.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanCompatibilityEngine', () {
    test('compares the six canonical profile numbers without hidden scoring', () {
      final left = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );
      final right = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(1992, 4, 24),
        fullName: 'Ayşe Yılmaz',
      );

      final result = PythagoreanCompatibilityEngine.compare(
        left: left,
        right: right,
      );

      expect(result.comparisons.length, 6);
      expect(
        result.comparisons.map((item) => item.metric).toList(),
        NumerologyCompatibilityMetric.values,
      );
      for (final item in result.comparisons) {
        expect(item.absoluteDifference, (item.leftValue - item.rightValue).abs());
        expect(item.exactMatch, item.leftValue == item.rightValue);
      }
      expect(
        result.exactMatchCount,
        result.comparisons.where((item) => item.exactMatch).length,
      );
    });

    test('identical profiles produce six exact matches', () {
      final profile = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );

      final result = PythagoreanCompatibilityEngine.compare(
        left: profile,
        right: profile,
      );

      expect(result.exactMatchCount, 6);
      expect(result.comparisons.every((item) => item.absoluteDifference == 0), isTrue);
    });

    test('rejects profiles calculated with different reduction policies', () {
      final left = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        policy: PersonalCycleReductionPolicy.preserveMasterNumbers,
      );
      final right = PythagoreanProfileEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        policy: PersonalCycleReductionPolicy.singleDigit,
      );

      expect(
        () => PythagoreanCompatibilityEngine.compare(left: left, right: right),
        throwsArgumentError,
      );
    });
  });
}
