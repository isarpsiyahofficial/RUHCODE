import '../ephemeris/ephemeris.dart';
import 'natal_aspects.dart';
import 'natal_chart.dart';

final class SynastryAspectHit {
  const SynastryAspectHit({
    required this.personABody,
    required this.personBBody,
    required this.aspect,
    required this.separationDegrees,
    required this.orbDegrees,
    required this.phase,
  });

  final AstroBody personABody;
  final AstroBody personBBody;
  final MajorAspect aspect;
  final double separationDegrees;
  final double orbDegrees;
  final AspectPhase phase;
}

final class WesternSynastryComparison {
  WesternSynastryComparison({
    required this.personAJdTt,
    required this.personBJdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<SynastryAspectHit> aspects,
  }) : aspects = List<SynastryAspectHit>.unmodifiable(aspects);

  final double personAJdTt;
  final double personBJdTt;
  final String sourceId;
  final String dataVersion;
  final List<SynastryAspectHit> aspects;
}

abstract final class WesternSynastry {
  static WesternSynastryComparison compare({
    required WesternNatalChart personA,
    required WesternNatalChart personB,
    AspectOrbPolicy? orbPolicy,
  }) {
    if (personA.sourceId != personB.sourceId ||
        personA.dataVersion != personB.dataVersion) {
      throw StateError(
        'Synastry comparison requires matching ephemeris provenance.',
      );
    }

    final policy = orbPolicy ?? AspectOrbPolicy();
    policy.validate();
    final hits = <SynastryAspectHit>[];

    for (final a in personA.placements.placements) {
      for (final b in personB.placements.placements) {
        final separation = _shortestSeparation(
          a.longitudeDegrees,
          b.longitudeDegrees,
        );
        MajorAspect? bestAspect;
        var bestOrb = double.infinity;
        for (final aspect in MajorAspect.values) {
          final orb = (separation - aspect.exactAngleDegrees).abs();
          final allowed = policy.forBodies(aspect, a.body, b.body);
          if (orb <= allowed && orb < bestOrb) {
            bestAspect = aspect;
            bestOrb = orb;
          }
        }
        if (bestAspect == null) continue;

        hits.add(
          SynastryAspectHit(
            personABody: a.body,
            personBBody: b.body,
            aspect: bestAspect,
            separationDegrees: separation,
            orbDegrees: bestOrb,
            phase: WesternNatalAspects.phaseFor(
              longitudeA: a.longitudeDegrees,
              longitudeB: b.longitudeDegrees,
              speedA: a.longitudeSpeedDegreesPerDay,
              speedB: b.longitudeSpeedDegreesPerDay,
              aspect: bestAspect,
            ),
          ),
        );
      }
    }

    hits.sort((left, right) {
      final byA = left.personABody.index.compareTo(right.personABody.index);
      if (byA != 0) return byA;
      final byB = left.personBBody.index.compareTo(right.personBBody.index);
      if (byB != 0) return byB;
      return left.aspect.index.compareTo(right.aspect.index);
    });

    return WesternSynastryComparison(
      personAJdTt: personA.jdTt,
      personBJdTt: personB.jdTt,
      sourceId: personA.sourceId,
      dataVersion: personA.dataVersion,
      aspects: hits,
    );
  }

  static double _shortestSeparation(double a, double b) {
    final difference = (a - b).abs() % 360.0;
    return difference > 180.0 ? 360.0 - difference : difference;
  }
}
