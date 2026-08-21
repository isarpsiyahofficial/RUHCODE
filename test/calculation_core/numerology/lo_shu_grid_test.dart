import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/lo_shu_grid.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('LoShuGridEngine', () {
    test('uses canonical 4-9-2 / 3-5-7 / 8-1-6 layout', () {
      final result = LoShuGridEngine.calculate(
        CivilDate(1990, 5, 19),
      );

      expect(result.canonicalGrid, const <List<int>>[
        <int>[4, 9, 2],
        <int>[3, 5, 7],
        <int>[8, 1, 6],
      ]);
    });

    test('counts exact birth-date digits and ignores zero', () {
      final result = LoShuGridEngine.calculate(
        CivilDate(1990, 5, 19),
      );

      expect(result.countOf(1), 2);
      expect(result.countOf(9), 3);
      expect(result.countOf(5), 1);
      expect(result.countOf(2), 0);
      expect(result.counts.values.reduce((a, b) => a + b), 6);
    });

    test('leap-day input remains an exact Gregorian date input', () {
      final result = LoShuGridEngine.calculate(
        CivilDate(2028, 2, 29),
      );

      expect(result.countOf(2), 4);
      expect(result.countOf(9), 1);
      expect(result.countOf(8), 1);
      expect(result.counts.values.reduce((a, b) => a + b), 6);
    });

    test('rejects non-grid lookup values', () {
      final result = LoShuGridEngine.calculate(
        CivilDate(2000, 1, 1),
      );
      expect(() => result.countOf(0), throwsRangeError);
      expect(() => result.countOf(10), throwsRangeError);
    });
  });
}
