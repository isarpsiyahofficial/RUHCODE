import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hour_guidance.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  List<PlanetaryHourWeekdayGuidanceRule> variedRules() => [
        for (final weekday in CivilWeekday.values)
          for (final planet in ClassicalPlanet.values)
            PlanetaryHourWeekdayGuidanceRule(
              weekday: weekday,
              planet: planet,
              interpretation: '${weekday.name}-${planet.name}-interpretation',
              sourceId: 'fixture-source',
              version: 'fixture-v1',
            ),
      ];

  test('RC-0136 requires complete 7x7 weekday and planet coverage', () {
    final rules = variedRules()..removeLast();
    expect(
      () => PlanetaryHourWeekdayGuidanceCatalog(rules),
      throwsArgumentError,
    );
  });

  test('RC-0136 rejects one identical interpretation for a planet across all weekdays', () {
    final rules = <PlanetaryHourWeekdayGuidanceRule>[
      for (final weekday in CivilWeekday.values)
        for (final planet in ClassicalPlanet.values)
          PlanetaryHourWeekdayGuidanceRule(
            weekday: weekday,
            planet: planet,
            interpretation: planet == ClassicalPlanet.sun
                ? 'same-sun-interpretation'
                : '${weekday.name}-${planet.name}-interpretation',
            sourceId: 'fixture-source',
            version: 'fixture-v1',
          ),
    ];
    expect(
      () => PlanetaryHourWeekdayGuidanceCatalog(rules),
      throwsArgumentError,
    );
  });

  test('RC-0136 binds the active civil weekday and planet to every rendered hour item', () {
    final hours = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 17),
      latitudeDegrees: 41.0082,
      longitudeDegrees: 28.9784,
    );
    final catalog = PlanetaryHourWeekdayGuidanceCatalog(variedRules());

    final items = PlanetaryHourWeekdayGuidance.build(
      hours: hours,
      catalog: catalog,
    );

    expect(items, hasLength(24));
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final slot = hours.slots[i];
      expect(item.weekday, hours.date.weekday);
      expect(item.planet, slot.ruler);
      expect(item.startUtc, slot.startUtc);
      expect(item.endUtc, slot.endUtc);
      expect(
        item.interpretation,
        '${hours.date.weekday.name}-${slot.ruler.name}-interpretation',
      );
      expect(item.sourceId, 'fixture-source');
      expect(item.version, 'fixture-v1');
    }
  });
}
