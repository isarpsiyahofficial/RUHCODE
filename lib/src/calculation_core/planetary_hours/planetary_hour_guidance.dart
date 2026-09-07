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
