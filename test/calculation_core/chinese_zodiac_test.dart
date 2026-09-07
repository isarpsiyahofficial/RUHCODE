import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/chinese/chinese_zodiac.dart';

final class _FixtureChineseCalendar implements ChineseCalendarYearProvider {
  @override
  ChineseCalendarYearResolution resolveYear(DateTime instantUtc) {
    final cny2024 = DateTime.utc(2024, 2, 10);
    if (instantUtc.isBefore(cny2024)) {
      return ChineseCalendarYearResolution(
        sexagenaryCycleIndex: 39, // Gui-Mao: Water Yin Rabbit.
        startUtc: DateTime.utc(2023, 1, 22),
        nextStartUtc: cny2024,
        sourceId: 'fixture-chinese-calendar',
        version: 'fixture-v1',
      );
    }
    return ChineseCalendarYearResolution(
      sexagenaryCycleIndex: 40, // Jia-Chen: Wood Yang Dragon.
      startUtc: cny2024,
      nextStartUtc: DateTime.utc(2025, 1, 29),
      sourceId: 'fixture-chinese-calendar',
      version: 'fixture-v1',
    );
  }
}

final class _BrokenCalendar implements ChineseCalendarYearProvider {
  @override
  ChineseCalendarYearResolution resolveYear(DateTime instantUtc) =>
      ChineseCalendarYearResolution(
        sexagenaryCycleIndex: 40,
        startUtc: DateTime.utc(2024, 2, 10),
        nextStartUtc: DateTime.utc(2025, 1, 29),
        sourceId: 'broken-fixture',
        version: 'fixture-v1',
      );
}

void main() {
  test('RC-0137 exposes the canonical twelve-animal branch order', () {
    expect(
      ChineseZodiacEngine.animals,
      const <ChineseZodiacAnimal>[
        ChineseZodiacAnimal.rat,
        ChineseZodiacAnimal.ox,
        ChineseZodiacAnimal.tiger,
        ChineseZodiacAnimal.rabbit,
        ChineseZodiacAnimal.dragon,
        ChineseZodiacAnimal.snake,
        ChineseZodiacAnimal.horse,
        ChineseZodiacAnimal.goat,
        ChineseZodiacAnimal.monkey,
        ChineseZodiacAnimal.rooster,
        ChineseZodiacAnimal.dog,
        ChineseZodiacAnimal.pig,
      ],
    );
  });

  test('RC-0138..RC-0140 derive animal, element and Yin/Yang from the resolved cycle', () {
    final profile = ChineseZodiacEngine.calculate(
      birthInstantUtc: DateTime.utc(2024, 6, 1, 12),
      calendar: _FixtureChineseCalendar(),
    );

    expect(profile.animal, ChineseZodiacAnimal.dragon);
    expect(profile.heavenlyStem, HeavenlyStem.jia);
    expect(profile.element, ChineseElement.wood);
    expect(profile.yinYang, YinYang.yang);
    expect(profile.sexagenaryCycleIndex, 40);
    expect(profile.sourceId, 'fixture-chinese-calendar');
    expect(profile.version, 'fixture-v1');
  });

  test('RC-0141 keeps a pre-Chinese-New-Year birth in the preceding cycle year', () {
    final profile = ChineseZodiacEngine.calculate(
      birthInstantUtc: DateTime.utc(2024, 2, 9, 12),
      calendar: _FixtureChineseCalendar(),
    );

    expect(profile.animal, ChineseZodiacAnimal.rabbit);
    expect(profile.heavenlyStem, HeavenlyStem.gui);
    expect(profile.element, ChineseElement.water);
    expect(profile.yinYang, YinYang.yin);
    expect(profile.sexagenaryCycleIndex, 39);
  });

  test('RC-0141 changes cycle exactly at the provider year boundary', () {
    final profile = ChineseZodiacEngine.calculate(
      birthInstantUtc: DateTime.utc(2024, 2, 10),
      calendar: _FixtureChineseCalendar(),
    );
    expect(profile.animal, ChineseZodiacAnimal.dragon);
    expect(profile.yearStartUtc, DateTime.utc(2024, 2, 10));
  });

  test('Chinese zodiac core fails closed on local-time input', () {
    expect(
      () => ChineseZodiacEngine.calculate(
        birthInstantUtc: DateTime(2024, 6, 1, 12),
        calendar: _FixtureChineseCalendar(),
      ),
      throwsArgumentError,
    );
  });

  test('Chinese zodiac core fails closed when provider interval misses the instant', () {
    expect(
      () => ChineseZodiacEngine.calculate(
        birthInstantUtc: DateTime.utc(2024, 1, 1),
        calendar: _BrokenCalendar(),
      ),
      throwsStateError,
    );
  });

  test('Chinese-calendar resolution rejects missing provenance', () {
    expect(
      () => ChineseCalendarYearResolution(
        sexagenaryCycleIndex: 0,
        startUtc: DateTime.utc(1984, 2, 2),
        nextStartUtc: DateTime.utc(1985, 2, 20),
        sourceId: '',
        version: 'v1',
      ),
      throwsArgumentError,
    );
  });
}
