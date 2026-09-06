import '../ephemeris/ephemeris.dart';
import 'vedic_rashi_chart.dart';

enum VedicYogaRelationType {
  sameHouse,
  sameRashi,
  houseDistance,
}

final class VedicYogaRelation {
  const VedicYogaRelation.sameHouse(this.left, this.right)
      : type = VedicYogaRelationType.sameHouse,
        expectedDistance = null;

  const VedicYogaRelation.sameRashi(this.left, this.right)
      : type = VedicYogaRelationType.sameRashi,
        expectedDistance = null;

  const VedicYogaRelation.houseDistance(
    this.left,
    this.right,
    this.expectedDistance,
  ) : type = VedicYogaRelationType.houseDistance;

  final AstroBody left;
  final AstroBody right;
  final VedicYogaRelationType type;
  final int? expectedDistance;
}

final class VedicYogaDefinition {
  VedicYogaDefinition({
    required this.id,
    required this.version,
    required this.sourceId,
    required Iterable<AstroBody> requiredBodies,
    required Iterable<VedicYogaRelation> relations,
  })  : requiredBodies = List<AstroBody>.unmodifiable(requiredBodies),
        relations = List<VedicYogaRelation>.unmodifiable(relations) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Yoga definitions require explicit id/version/source provenance.');
    }
    if (this.requiredBodies.isEmpty ||
        this.requiredBodies.toSet().length != this.requiredBodies.length) {
      throw ArgumentError('Yoga required bodies must be non-empty and unique.');
    }
    if (this.relations.isEmpty) {
      throw ArgumentError('Yoga definitions must contain at least one explicit relation.');
    }
    final bodySet = this.requiredBodies.toSet();
    for (final relation in this.relations) {
      if (!bodySet.contains(relation.left) || !bodySet.contains(relation.right)) {
        throw ArgumentError('Yoga relation references a body outside requiredBodies.');
      }
      if (relation.type == VedicYogaRelationType.houseDistance &&
          (relation.expectedDistance == null ||
              relation.expectedDistance! < 1 ||
              relation.expectedDistance! > 12)) {
        throw ArgumentError('House distance must be within 1..12.');
      }
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final List<AstroBody> requiredBodies;
  final List<VedicYogaRelation> relations;
}

final class VedicYogaMatch {
  const VedicYogaMatch({
    required this.definitionId,
    required this.definitionVersion,
    required this.definitionSourceId,
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
  });

  final String definitionId;
  final String definitionVersion;
  final String definitionSourceId;
  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
}

/// RC-0118 professional Vedic-yoga evaluation boundary.
///
/// The engine deliberately does not ship an unverified hard-coded yoga catalog.
/// Professional definitions must be supplied as versioned, source-tagged rules;
/// the evaluator then applies those rules deterministically to the independent
/// sidereal Rashi/Whole-Sign chart. This prevents disputed or editorial rules
/// from being silently treated as calculation truth.
abstract final class VedicYogaEngine {
  static List<VedicYogaMatch> evaluate({
    required VedicRashiChart chart,
    required Iterable<VedicYogaDefinition> definitions,
  }) {
    _validateChart(chart);
    final catalog = definitions.toList(growable: false);
    if (catalog.isEmpty) {
      throw ArgumentError('At least one versioned yoga definition is required.');
    }
    final ids = <String>{};
    for (final definition in catalog) {
      if (!ids.add(definition.id)) {
        throw StateError('Duplicate yoga definition id: ${definition.id}.');
      }
    }

    final byBody = <AstroBody, VedicRashiPlacement>{
      for (final placement in chart.placements) placement.placement.body: placement,
    };
    final matches = <VedicYogaMatch>[];
    for (final definition in catalog) {
      if (!definition.requiredBodies.every(byBody.containsKey)) continue;
      final matchesAll = definition.relations.every(
        (relation) => _matchesRelation(relation, byBody),
      );
      if (!matchesAll) continue;
      matches.add(
        VedicYogaMatch(
          definitionId: definition.id,
          definitionVersion: definition.version,
          definitionSourceId: definition.sourceId,
          jdTt: chart.jdTt,
          ephemerisSourceId: chart.ephemerisSourceId,
          ephemerisDataVersion: chart.ephemerisDataVersion,
          ayanamshaId: chart.ayanamshaId,
          ayanamshaDataVersion: chart.ayanamshaDataVersion,
        ),
      );
    }
    return List<VedicYogaMatch>.unmodifiable(matches);
  }

  static bool _matchesRelation(
    VedicYogaRelation relation,
    Map<AstroBody, VedicRashiPlacement> byBody,
  ) {
    final left = byBody[relation.left]!;
    final right = byBody[relation.right]!;
    switch (relation.type) {
      case VedicYogaRelationType.sameHouse:
        return left.wholeSignHouse == right.wholeSignHouse;
      case VedicYogaRelationType.sameRashi:
        return left.rashiIndex == right.rashiIndex;
      case VedicYogaRelationType.houseDistance:
        final distance = ((right.wholeSignHouse - left.wholeSignHouse + 12) % 12) + 1;
        return distance == relation.expectedDistance;
    }
  }

  static void _validateChart(VedicRashiChart chart) {
    if (!chart.jdTt.isFinite ||
        chart.ephemerisSourceId.trim().isEmpty ||
        chart.ephemerisDataVersion.trim().isEmpty ||
        chart.ayanamshaId.trim().isEmpty ||
        chart.ayanamshaDataVersion.trim().isEmpty ||
        chart.lagnaRashiIndex < 0 ||
        chart.lagnaRashiIndex > 11 ||
        chart.placements.isEmpty) {
      throw StateError('Vedic yoga evaluation requires a valid provenance-tagged Rashi chart.');
    }
    final bodies = <AstroBody>{};
    for (final placement in chart.placements) {
      if (!bodies.add(placement.placement.body) ||
          placement.rashiIndex < 0 ||
          placement.rashiIndex > 11 ||
          placement.wholeSignHouse < 1 ||
          placement.wholeSignHouse > 12) {
        throw StateError('Vedic yoga chart contains invalid or duplicate placements.');
      }
    }
  }
}
