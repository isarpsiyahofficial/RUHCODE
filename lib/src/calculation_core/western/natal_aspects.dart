import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

enum MajorAspect {
  conjunction(0),
  sextile(60),
  square(90),
  trine(120),
  quincunx(150),
  opposition(180);

  const MajorAspect(this.exactAngleDegrees);
  final double exactAngleDegrees;
}

final class AspectOrbPolicy {
  AspectOrbPolicy({
    Map<MajorAspect, double>? maximumOrbDegrees,
    Map<AstroBody, Map<MajorAspect, double>>? bodyAspectOverrides,
  })  : maximumOrbDegrees = Map.unmodifiable(
          maximumOrbDegrees ??
              const {
                MajorAspect.conjunction: 8.0,
                MajorAspect.sextile: 5.0,
                MajorAspect.square: 7.0,
                MajorAspect.trine: 7.0,
                MajorAspect.quincunx: 3.0,
                MajorAspect.opposition: 8.0,
              },
        ),
        bodyAspectOverrides = Map.unmodifiable({
          for (final entry in (bodyAspectOverrides ?? const <AstroBody, Map<MajorAspect, double>>{}).entries)
            entry.key: Map<MajorAspect, double>.unmodifiable(entry.value),
        }) {
    validate();
  }

  final Map<MajorAspect, double> maximumOrbDegrees;
  final Map<AstroBody, Map<MajorAspect, double>> bodyAspectOverrides;

  void validate() {
    for (final aspect in MajorAspect.values) {
      final orb = maximumOrbDegrees[aspect];
      if (orb == null || !orb.isFinite || orb < 0 || orb > 30) {
        throw StateError('Every supported aspect requires a finite orb in [0, 30].');
      }
    }
    for (final bodyEntry in bodyAspectOverrides.entries) {
      for (final aspectEntry in bodyEntry.value.entries) {
        if (!MajorAspect.values.contains(aspectEntry.key)) {
          throw StateError('Unsupported aspect override for ${bodyEntry.key}.');
        }
        final orb = aspectEntry.value;
        if (!orb.isFinite || orb < 0 || orb > 30) {
          throw StateError('Body/aspect orb overrides must be finite and in [0, 30].');
        }
      }
    }
  }

  double forAspect(MajorAspect aspect) => maximumOrbDegrees[aspect]!;

  double forBodies(MajorAspect aspect, AstroBody bodyA, AstroBody bodyB) {
    final base = forAspect(aspect);
    final a = bodyAspectOverrides[bodyA]?[aspect];
    final b = bodyAspectOverrides[bodyB]?[aspect];
    if (a == null && b == null) return base;
    if (a == null) return b!;
    if (b == null) return a;
    return a > b ? a : b;
  }
}

final class NatalAspectHit {
  const NatalAspectHit({
    required this.bodyA,
    required this.bodyB,
    required this.aspect,
    required this.separationDegrees,
    required this.orbDegrees,
  });

  final AstroBody bodyA;
  final AstroBody bodyB;
  final MajorAspect aspect;
  final double separationDegrees;
  final double orbDegrees;
}

final class NatalAspectSet {
  NatalAspectSet({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<NatalAspectHit> aspects,
  }) : aspects = List<NatalAspectHit>.unmodifiable(aspects);

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final List<NatalAspectHit> aspects;
}

abstract final class WesternNatalAspects {
  static NatalAspectSet build({
    required NatalPlacementSet placements,
    AspectOrbPolicy? orbPolicy,
  }) {
    if (placements.placements.length < 2) {
      return NatalAspectSet(
        jdTt: placements.jdTt,
        sourceId: placements.sourceId,
        dataVersion: placements.dataVersion,
        aspects: const [],
      );
    }

    final policy = orbPolicy ?? AspectOrbPolicy();
    policy.validate();
    final hits = <NatalAspectHit>[];

    for (var i = 0; i < placements.placements.length - 1; i++) {
      final a = placements.placements[i];
      for (var j = i + 1; j < placements.placements.length; j++) {
        final b = placements.placements[j];
        final separation = _shortestSeparation(a.longitudeDegrees, b.longitudeDegrees);
        MajorAspect? bestAspect;
        var bestOrb = double.infinity;

        for (final aspect in MajorAspect.values) {
          final orb = (separation - aspect.exactAngleDegrees).abs();
          final allowedOrb = policy.forBodies(aspect, a.body, b.body);
          if (orb <= allowedOrb && orb < bestOrb) {
            bestAspect = aspect;
            bestOrb = orb;
          }
        }

        if (bestAspect != null) {
          hits.add(
            NatalAspectHit(
              bodyA: a.body,
              bodyB: b.body,
              aspect: bestAspect,
              separationDegrees: separation,
              orbDegrees: bestOrb,
            ),
          );
        }
      }
    }

    return NatalAspectSet(
      jdTt: placements.jdTt,
      sourceId: placements.sourceId,
      dataVersion: placements.dataVersion,
      aspects: hits,
    );
  }

  static double _shortestSeparation(double a, double b) {
    final difference = (a - b).abs() % 360.0;
    return difference > 180.0 ? 360.0 - difference : difference;
  }
}
