enum ChineseZodiacAnimal {
  rat,
  ox,
  tiger,
  rabbit,
  dragon,
  snake,
  horse,
  goat,
  monkey,
  rooster,
  dog,
  pig,
}

enum ChineseElement { wood, fire, earth, metal, water }

enum YinYang { yang, yin }

enum HeavenlyStem {
  jia,
  yi,
  bing,
  ding,
  wu,
  ji,
  geng,
  xin,
  ren,
  gui,
}

/// A resolved Chinese-calendar year interval supplied by an authoritative
/// calendar implementation. The interval is half-open: [startUtc, nextStartUtc).
///
/// The calculation core deliberately does not infer this interval from the
/// Gregorian year. That prevents births around Chinese New Year from silently
/// receiving the following year's zodiac animal.
final class ChineseCalendarYearResolution {
  ChineseCalendarYearResolution({
    required this.sexagenaryCycleIndex,
    required this.startUtc,
    required this.nextStartUtc,
    required this.sourceId,
    required this.version,
  }) {
    if (sexagenaryCycleIndex < 0 || sexagenaryCycleIndex >= 60) {
      throw ArgumentError.value(
        sexagenaryCycleIndex,
        'sexagenaryCycleIndex',
        'must be in 0..59 where 0 is Jia-Zi',
      );
    }
    if (!startUtc.isUtc || !nextStartUtc.isUtc) {
      throw ArgumentError('Chinese-calendar year boundaries must be UTC');
    }
    if (!startUtc.isBefore(nextStartUtc)) {
      throw ArgumentError('Chinese-calendar year interval must be increasing');
    }
    for (final field in <String, String>{
      'sourceId': sourceId,
      'version': version,
    }.entries) {
      if (field.value.trim().isEmpty) {
        throw ArgumentError.value(field.value, field.key, 'must not be empty');
      }
    }
  }

  /// 0 = Jia-Zi, 1 = Yi-Chou, ... 59 = Gui-Hai.
  final int sexagenaryCycleIndex;
  final DateTime startUtc;
  final DateTime nextStartUtc;
  final String sourceId;
  final String version;
}

abstract interface class ChineseCalendarYearProvider {
  ChineseCalendarYearResolution resolveYear(DateTime instantUtc);
}

final class ChineseZodiacProfile {
  const ChineseZodiacProfile({
    required this.animal,
    required this.element,
    required this.yinYang,
    required this.heavenlyStem,
    required this.sexagenaryCycleIndex,
    required this.yearStartUtc,
    required this.nextYearStartUtc,
    required this.sourceId,
    required this.version,
  });

  final ChineseZodiacAnimal animal;
  final ChineseElement element;
  final YinYang yinYang;
  final HeavenlyStem heavenlyStem;
  final int sexagenaryCycleIndex;
  final DateTime yearStartUtc;
  final DateTime nextYearStartUtc;
  final String sourceId;
  final String version;
}

/// RC-0137..RC-0141 Chinese-zodiac calculation core.
///
/// Canonical cycle ordering follows the 12 Earthly Branch animal sequence and
/// the 10 Heavenly Stems. The provider owns the Chinese New Year boundary;
/// therefore this engine never derives the zodiac from a Gregorian year alone.
abstract final class ChineseZodiacEngine {
  static const List<ChineseZodiacAnimal> animals = <ChineseZodiacAnimal>[
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
  ];

  static const List<HeavenlyStem> stems = <HeavenlyStem>[
    HeavenlyStem.jia,
    HeavenlyStem.yi,
    HeavenlyStem.bing,
    HeavenlyStem.ding,
    HeavenlyStem.wu,
    HeavenlyStem.ji,
    HeavenlyStem.geng,
    HeavenlyStem.xin,
    HeavenlyStem.ren,
    HeavenlyStem.gui,
  ];

  static const List<ChineseElement> _stemElements = <ChineseElement>[
    ChineseElement.wood,
    ChineseElement.wood,
    ChineseElement.fire,
    ChineseElement.fire,
    ChineseElement.earth,
    ChineseElement.earth,
    ChineseElement.metal,
    ChineseElement.metal,
    ChineseElement.water,
    ChineseElement.water,
  ];

  static ChineseZodiacProfile calculate({
    required DateTime birthInstantUtc,
    required ChineseCalendarYearProvider calendar,
  }) {
    if (!birthInstantUtc.isUtc) {
      throw ArgumentError.value(
        birthInstantUtc,
        'birthInstantUtc',
        'must be UTC',
      );
    }

    final resolved = calendar.resolveYear(birthInstantUtc);
    if (birthInstantUtc.isBefore(resolved.startUtc) ||
        !birthInstantUtc.isBefore(resolved.nextStartUtc)) {
      throw StateError(
        'calendar provider returned a year interval that does not contain the birth instant',
      );
    }

    final cycle = resolved.sexagenaryCycleIndex;
    final stemIndex = cycle % 10;
    final branchIndex = cycle % 12;

    return ChineseZodiacProfile(
      animal: animals[branchIndex],
      element: _stemElements[stemIndex],
      yinYang: stemIndex.isEven ? YinYang.yang : YinYang.yin,
      heavenlyStem: stems[stemIndex],
      sexagenaryCycleIndex: cycle,
      yearStartUtc: resolved.startUtc,
      nextYearStartUtc: resolved.nextStartUtc,
      sourceId: resolved.sourceId,
      version: resolved.version,
    );
  }
}
