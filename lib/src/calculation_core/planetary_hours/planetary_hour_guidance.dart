import '../time/civil_calendar.dart';
import 'planetary_hours.dart';

final class PlanetaryHourGuidanceRule {
  PlanetaryHourGuidanceRule({
    required this.planet,
    required this.quality,
    required this.interpretation,
    required this.proAction,
    required this.doNot,
    required this.mantra,
    required this.sourceId,
    required this.version,
  }) {
    for (final field in <String, String>{
      'quality': quality,
      'interpretation': interpretation,
      'proAction': proAction,
      'doNot': doNot,
      'mantra': mantra,
      'sourceId': sourceId,
      'version': version,
    }.entries) {
      if (field.value.trim().isEmpty) {
        throw ArgumentError.value(field.value, field.key, 'must not be empty');
      }
    }
  }

  final ClassicalPlanet planet;
  final String quality;
  final String interpretation;
  final String proAction;
  final String doNot;
  final String mantra;
  final String sourceId;
  final String version;
}

final class PlanetaryHourGuidanceCatalog {
  PlanetaryHourGuidanceCatalog(Iterable<PlanetaryHourGuidanceRule> rules)
      : _rules = _validated(rules);

  final Map<ClassicalPlanet, PlanetaryHourGuidanceRule> _rules;

  static Map<ClassicalPlanet, PlanetaryHourGuidanceRule> _validated(
    Iterable<PlanetaryHourGuidanceRule> rules,
  ) {
    final map = <ClassicalPlanet, PlanetaryHourGuidanceRule>{};
    for (final rule in rules) {
      if (map.containsKey(rule.planet)) {
        throw ArgumentError('duplicate guidance rule for ${rule.planet.name}');
      }
      map[rule.planet] = rule;
    }
    final missing = ClassicalPlanet.values.where((planet) => !map.containsKey(planet)).toList();
    if (missing.isNotEmpty) {
      throw ArgumentError(
        'guidance catalog must cover all classical planets; missing: '
        '${missing.map((e) => e.name).join(', ')}',
      );
    }
    return Map.unmodifiable(map);
  }

  PlanetaryHourGuidanceRule forPlanet(ClassicalPlanet planet) => _rules[planet]!;
}

final class PlanetaryHourGuidanceItem {
  const PlanetaryHourGuidanceItem({
    required this.planet,
    required this.startUtc,
    required this.endUtc,
    required this.quality,
    required this.interpretation,
    required this.proAction,
    required this.doNot,
    required this.mantra,
    required this.sourceId,
    required this.version,
  });

  final ClassicalPlanet planet;
  final DateTime startUtc;
  final DateTime endUtc;
  final String quality;
  final String interpretation;
  final String proAction;
  final String doNot;
  final String mantra;
  final String sourceId;
  final String version;
}

abstract final class PlanetaryHourGuidance {
  static List<PlanetaryHourGuidanceItem> build({
    required PlanetaryHoursResult hours,
    required PlanetaryHourGuidanceCatalog catalog,
  }) {
    if (!hours.isAvailable || hours.slots.length != 24) {
      throw StateError('planetary hours must be available with exactly 24 slots');
    }

    final items = <PlanetaryHourGuidanceItem>[];
    for (final slot in hours.slots) {
      if (!slot.startUtc.isBefore(slot.endUtc)) {
        throw StateError('planetary-hour slot has an invalid time range');
      }
      final rule = catalog.forPlanet(slot.ruler);
      items.add(
        PlanetaryHourGuidanceItem(
          planet: slot.ruler,
          startUtc: slot.startUtc,
          endUtc: slot.endUtc,
          quality: rule.quality,
          interpretation: rule.interpretation,
          proAction: rule.proAction,
          doNot: rule.doNot,
          mantra: rule.mantra,
          sourceId: rule.sourceId,
          version: rule.version,
        ),
      );
    }
    return List.unmodifiable(items);
  }
}

final class PlanetaryHourWeekdayGuidanceRule {
  PlanetaryHourWeekdayGuidanceRule({
    required this.weekday,
    required this.planet,
    required this.interpretation,
    required this.sourceId,
    required this.version,
  }) {
    for (final field in <String, String>{
      'interpretation': interpretation,
      'sourceId': sourceId,
      'version': version,
    }.entries) {
      if (field.value.trim().isEmpty) {
        throw ArgumentError.value(field.value, field.key, 'must not be empty');
      }
    }
  }

  final CivilWeekday weekday;
  final ClassicalPlanet planet;
  final String interpretation;
  final String sourceId;
  final String version;
}

final class PlanetaryHourWeekdayGuidanceCatalog {
  PlanetaryHourWeekdayGuidanceCatalog(
    Iterable<PlanetaryHourWeekdayGuidanceRule> rules,
  ) : _rules = _validated(rules);

  final Map<String, PlanetaryHourWeekdayGuidanceRule> _rules;

  static String _key(CivilWeekday weekday, ClassicalPlanet planet) =>
      '${weekday.index}:${planet.index}';

  static Map<String, PlanetaryHourWeekdayGuidanceRule> _validated(
    Iterable<PlanetaryHourWeekdayGuidanceRule> rules,
  ) {
    final map = <String, PlanetaryHourWeekdayGuidanceRule>{};
    for (final rule in rules) {
      final key = _key(rule.weekday, rule.planet);
      if (map.containsKey(key)) {
        throw ArgumentError(
          'duplicate weekday guidance rule for ${rule.weekday.name}/${rule.planet.name}',
        );
      }
      map[key] = rule;
    }

    final missing = <String>[];
    for (final weekday in CivilWeekday.values) {
      for (final planet in ClassicalPlanet.values) {
        if (!map.containsKey(_key(weekday, planet))) {
          missing.add('${weekday.name}/${planet.name}');
        }
      }
    }
    if (missing.isNotEmpty) {
      throw ArgumentError(
        'weekday guidance catalog must cover all 7x7 day/planet combinations; missing: ${missing.join(', ')}',
      );
    }

    for (final planet in ClassicalPlanet.values) {
      final interpretations = CivilWeekday.values
          .map((weekday) => map[_key(weekday, planet)]!.interpretation.trim())
          .toSet();
      if (interpretations.length < 2) {
        throw ArgumentError(
          'weekday guidance for ${planet.name} must not repeat one identical interpretation across all seven days',
        );
      }
    }

    return Map.unmodifiable(map);
  }

  PlanetaryHourWeekdayGuidanceRule forWeekdayPlanet(
    CivilWeekday weekday,
    ClassicalPlanet planet,
  ) =>
      _rules[_key(weekday, planet)]!;
}

final class PlanetaryHourWeekdayGuidanceItem {
  const PlanetaryHourWeekdayGuidanceItem({
    required this.weekday,
    required this.planet,
    required this.startUtc,
    required this.endUtc,
    required this.interpretation,
    required this.sourceId,
    required this.version,
  });

  final CivilWeekday weekday;
  final ClassicalPlanet planet;
  final DateTime startUtc;
  final DateTime endUtc;
  final String interpretation;
  final String sourceId;
  final String version;
}

abstract final class PlanetaryHourWeekdayGuidance {
  static List<PlanetaryHourWeekdayGuidanceItem> build({
    required PlanetaryHoursResult hours,
    required PlanetaryHourWeekdayGuidanceCatalog catalog,
  }) {
    if (!hours.isAvailable || hours.slots.length != 24) {
      throw StateError('planetary hours must be available with exactly 24 slots');
    }

    final weekday = hours.date.weekday;
    final items = <PlanetaryHourWeekdayGuidanceItem>[];
    for (final slot in hours.slots) {
      if (!slot.startUtc.isBefore(slot.endUtc)) {
        throw StateError('planetary-hour slot has an invalid time range');
      }
      final rule = catalog.forWeekdayPlanet(weekday, slot.ruler);
      items.add(
        PlanetaryHourWeekdayGuidanceItem(
          weekday: weekday,
          planet: slot.ruler,
          startUtc: slot.startUtc,
          endUtc: slot.endUtc,
          interpretation: rule.interpretation,
          sourceId: rule.sourceId,
          version: rule.version,
        ),
      );
    }
    return List.unmodifiable(items);
  }
}
