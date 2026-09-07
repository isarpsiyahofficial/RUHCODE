import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hour_guidance.dart';
import 'package:ruh_code/src/calculation_core/planetary_hours/planetary_hours.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  PlanetaryHourGuidanceRule rule(ClassicalPlanet planet) =>
      PlanetaryHourGuidanceRule(
        planet: planet,
        quality: '${planet.name}-quality',
        interpretation: '${planet.name}-interpretation',
        proAction: '${planet.name}-pro-action',
        doNot: '${planet.name}-do-not',
        mantra: '${planet.name}-mantra',
        sourceId: 'fixture-source',
        version: 'fixture-v1',
      );

  test('RC-0135 requires a complete seven-planet guidance catalog', () {
    expect(
      () => PlanetaryHourGuidanceCatalog(
        ClassicalPlanet.values.skip(1).map(rule),
      ),
      throwsArgumentError,
    );
  });

  test('RC-0135 rejects empty editorial/provenance fields', () {
    expect(
      () => PlanetaryHourGuidanceRule(
        planet: ClassicalPlanet.sun,
        quality: '',
        interpretation: 'interpretation',
        proAction: 'action',
        doNot: 'do-not',
        mantra: 'mantra',
        sourceId: 'source',
        version: 'v1',
      ),
      throwsArgumentError,
    );
  });

  test('RC-0135 binds every hour to planet/time/guidance/provenance fields', () {
    final hours = PlanetaryHours.forDate(
      date: CivilDate(2026, 8, 17),
      latitudeDegrees: 41.0082,
      longitudeDegrees: 28.9784,
    );
    final catalog = PlanetaryHourGuidanceCatalog(
      ClassicalPlanet.values.map(rule),
    );

    final items = PlanetaryHourGuidance.build(hours: hours, catalog: catalog);
    expect(items, hasLength(24));
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final slot = hours.slots[i];
      expect(item.planet, slot.ruler);
      expect(item.startUtc, slot.startUtc);
      expect(item.endUtc, slot.endUtc);
      expect(item.quality, isNotEmpty);
      expect(item.interpretation, isNotEmpty);
      expect(item.proAction, isNotEmpty);
      expect(item.doNot, isNotEmpty);
      expect(item.mantra, isNotEmpty);
      expect(item.sourceId, 'fixture-source');
      expect(item.version, 'fixture-v1');
    }
  });
}
