import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/chinese/chinese_year.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  TabulatedChineseNewYearBoundaryProvider verifiedFixtureProvider() {
    return TabulatedChineseNewYearBoundaryProvider(
      sourceId: 'timeanddate-china-holiday-fixture',
      dataVersion: '2024-2026-fixture-v1',
      boundaries: {
        2024: CivilDate(2024, 2, 10),
        2025: CivilDate(2025, 1, 29),
        2026: CivilDate(2026, 2, 17),
      },
    );
  }

  test('uses previous Chinese year before Chinese New Year boundary', () {
    final engine = ChineseZodiacYearEngine(boundaries: verifiedFixtureProvider());

    final result = engine.calculate(CivilDate(2024, 2, 9));

    expect(result.chineseYear, 2023);
    expect(result.animal, ChineseZodiacAnimal.rabbit);
    expect(result.element, ChineseFiveElement.water);
    expect(result.polarity, ChinesePolarity.yin);
    expect(result.chineseNewYearBoundary, CivilDate(2024, 2, 10));
  });

  test('switches Chinese zodiac exactly on Chinese New Year boundary', () {
    final engine = ChineseZodiacYearEngine(boundaries: verifiedFixtureProvider());

    final result = engine.calculate(CivilDate(2024, 2, 10));

    expect(result.chineseYear, 2024);
    expect(result.sexagenaryIndex, 40);
    expect(result.animal, ChineseZodiacAnimal.dragon);
    expect(result.element, ChineseFiveElement.wood);
    expect(result.polarity, ChinesePolarity.yang);
  });

  test('maps 2025 to Wood Yin Snake only from January 29 onward', () {
    final engine = ChineseZodiacYearEngine(boundaries: verifiedFixtureProvider());

    final before = engine.calculate(CivilDate(2025, 1, 28));
    final onBoundary = engine.calculate(CivilDate(2025, 1, 29));

    expect(before.chineseYear, 2024);
    expect(before.animal, ChineseZodiacAnimal.dragon);
    expect(onBoundary.chineseYear, 2025);
    expect(onBoundary.animal, ChineseZodiacAnimal.snake);
    expect(onBoundary.element, ChineseFiveElement.wood);
    expect(onBoundary.polarity, ChinesePolarity.yin);
  });

  test('maps 2026 Chinese New Year to Fire Yang Horse', () {
    final engine = ChineseZodiacYearEngine(boundaries: verifiedFixtureProvider());

    final before = engine.calculate(CivilDate(2026, 2, 16));
    final onBoundary = engine.calculate(CivilDate(2026, 2, 17));

    expect(before.chineseYear, 2025);
    expect(before.animal, ChineseZodiacAnimal.snake);
    expect(onBoundary.chineseYear, 2026);
    expect(onBoundary.animal, ChineseZodiacAnimal.horse);
    expect(onBoundary.element, ChineseFiveElement.fire);
    expect(onBoundary.polarity, ChinesePolarity.yang);
  });

  test('fails closed when a verified Chinese New Year boundary is unavailable', () {
    final engine = ChineseZodiacYearEngine(boundaries: verifiedFixtureProvider());

    expect(
      () => engine.calculate(CivilDate(2027, 1, 1)),
      throwsA(isA<StateError>()),
    );
  });

  test('tabulated provider rejects a boundary stored under the wrong year', () {
    expect(
      () => TabulatedChineseNewYearBoundaryProvider(
        sourceId: 'fixture',
        dataVersion: 'bad-v1',
        boundaries: {2025: CivilDate(2024, 2, 10)},
      ),
      throwsArgumentError,
    );
  });
}
