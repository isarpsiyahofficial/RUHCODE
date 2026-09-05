import '../ephemeris/ephemeris.dart';
import 'natal_aspects.dart';
import 'transit_chart.dart';

final class ImportantTransitEvent {
  const ImportantTransitEvent({
    required this.jdTt,
    required this.transitBody,
    required this.natalBody,
    required this.aspect,
    required this.orbDegrees,
    required this.phase,
  });

  final double jdTt;
  final AstroBody transitBody;
  final AstroBody natalBody;
  final MajorAspect aspect;
  final double orbDegrees;
  final AspectPhase phase;
}

final class ImportantTransitPolicy {
  ImportantTransitPolicy({
    Set<MajorAspect>? aspects,
    this.maximumOrbDegrees = 2.0,
  }) : aspects = Set<MajorAspect>.unmodifiable(
          aspects ??
              const {
                MajorAspect.conjunction,
                MajorAspect.square,
                MajorAspect.trine,
                MajorAspect.opposition,
              },
        ) {
    if (this.aspects.isEmpty) {
      throw StateError('Important-transit policy must contain at least one aspect.');
    }
    if (!maximumOrbDegrees.isFinite || maximumOrbDegrees < 0 || maximumOrbDegrees > 30) {
      throw RangeError('Important-transit maximum orb must be finite and in [0, 30].');
    }
  }

  final Set<MajorAspect> aspects;
  final double maximumOrbDegrees;
}

abstract final class WesternTransitTimeline {
  static List<ImportantTransitEvent> build({
    required List<NatalTransitComparison> comparisons,
    ImportantTransitPolicy? policy,
  }) {
    final activePolicy = policy ?? ImportantTransitPolicy();
    final events = <ImportantTransitEvent>[];
    String? sourceId;
    String? dataVersion;

    for (final comparison in comparisons) {
      if (!comparison.transitJdTt.isFinite) {
        throw StateError('Transit timeline requires finite TT instants.');
      }
      sourceId ??= comparison.sourceId;
      dataVersion ??= comparison.dataVersion;
      if (comparison.sourceId != sourceId || comparison.dataVersion != dataVersion) {
        throw StateError('Transit timeline comparisons must share ephemeris provenance.');
      }
      for (final hit in comparison.aspects) {
        if (!activePolicy.aspects.contains(hit.aspect) ||
            hit.orbDegrees > activePolicy.maximumOrbDegrees) {
          continue;
        }
        events.add(
          ImportantTransitEvent(
            jdTt: comparison.transitJdTt,
            transitBody: hit.transitBody,
            natalBody: hit.natalBody,
            aspect: hit.aspect,
            orbDegrees: hit.orbDegrees,
            phase: hit.phase,
          ),
        );
      }
    }

    events.sort((a, b) {
      final byTime = a.jdTt.compareTo(b.jdTt);
      if (byTime != 0) return byTime;
      final byOrb = a.orbDegrees.compareTo(b.orbDegrees);
      if (byOrb != 0) return byOrb;
      final byTransit = a.transitBody.index.compareTo(b.transitBody.index);
      if (byTransit != 0) return byTransit;
      return a.natalBody.index.compareTo(b.natalBody.index);
    });
    return List<ImportantTransitEvent>.unmodifiable(events);
  }
}
