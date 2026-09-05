import '../ephemeris/ephemeris.dart';
import 'natal_aspects.dart';
import 'natal_chart.dart';
import 'natal_placements.dart';

final class TransitPlacement {
  const TransitPlacement({
    required this.body,
    required this.longitudeDegrees,
    required this.longitudeSpeedDegreesPerDay,
    required this.sign,
    required this.degreeInSign,
    required this.motion,
  });

  final AstroBody body;
  final double longitudeDegrees;
  final double longitudeSpeedDegreesPerDay;
  final TropicalZodiacSign sign;
  final double degreeInSign;
  final ApparentMotion motion;
}

final class WesternTransitChart {
  WesternTransitChart({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<TransitPlacement> placements,
  }) : placements = List<TransitPlacement>.unmodifiable(placements);

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final List<TransitPlacement> placements;

  TransitPlacement forBody(AstroBody body) =>
      placements.singleWhere((placement) => placement.body == body);

  static WesternTransitChart build({
    required List<EclipticState> states,
    double stationaryThresholdDegreesPerDay = 1e-4,
  }) {
    if (states.isEmpty) {
      throw ArgumentError.value(states, 'states', 'At least one transit ephemeris state is required.');
    }
    if (!stationaryThresholdDegreesPerDay.isFinite ||
        stationaryThresholdDegreesPerDay <= 0) {
      throw RangeError('Stationary threshold must be positive and finite.');
    }

    final first = states.first;
    first.validate();
    final seenBodies = <AstroBody>{};
    final placements = <TransitPlacement>[];
    for (final state in states) {
      state.validate();
      if (!seenBodies.add(state.body)) {
        throw StateError('Duplicate ephemeris body in transit input: ${state.body.name}.');
      }
      if ((state.jdTt - first.jdTt).abs() > 1e-12) {
        throw StateError('All transit ephemeris states must use the same TT instant.');
      }
      if (state.sourceId != first.sourceId || state.dataVersion != first.dataVersion) {
        throw StateError('All transit ephemeris states must share source/version provenance.');
      }
      final signIndex = (state.longitudeDegrees / 30.0).floor();
      placements.add(
        TransitPlacement(
          body: state.body,
          longitudeDegrees: state.longitudeDegrees,
          longitudeSpeedDegreesPerDay: state.longitudeSpeedDegreesPerDay,
          sign: TropicalZodiacSign.values[signIndex],
          degreeInSign: state.longitudeDegrees - signIndex * 30.0,
          motion: state.motion(
            stationaryThresholdDegreesPerDay: stationaryThresholdDegreesPerDay,
          ),
        ),
      );
    }
    placements.sort((a, b) => a.body.index.compareTo(b.body.index));
    return WesternTransitChart(
      jdTt: first.jdTt,
      sourceId: first.sourceId,
      dataVersion: first.dataVersion,
      placements: placements,
    );
  }
}

final class TransitNatalAspectHit {
  const TransitNatalAspectHit({
    required this.transitBody,
    required this.natalBody,
    required this.aspect,
    required this.separationDegrees,
    required this.orbDegrees,
    required this.phase,
  });

  final AstroBody transitBody;
  final AstroBody natalBody;
  final MajorAspect aspect;
  final double separationDegrees;
  final double orbDegrees;
  final AspectPhase phase;
}

final class NatalTransitComparison {
  NatalTransitComparison({
    required this.natalJdTt,
    required this.transitJdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<TransitNatalAspectHit> aspects,
  }) : aspects = List<TransitNatalAspectHit>.unmodifiable(aspects);

  final double natalJdTt;
  final double transitJdTt;
  final String sourceId;
  final String dataVersion;
  final List<TransitNatalAspectHit> aspects;
}

abstract final class WesternNatalTransit {
  static NatalTransitComparison compare({
    required WesternNatalChart natal,
    required WesternTransitChart transit,
    AspectOrbPolicy? orbPolicy,
  }) {
    if (natal.sourceId != transit.sourceId ||
        natal.dataVersion != transit.dataVersion) {
      throw StateError('Natal/transit comparison requires matching ephemeris provenance.');
    }
    final policy = orbPolicy ?? AspectOrbPolicy();
    policy.validate();
    final hits = <TransitNatalAspectHit>[];

    for (final transitPlacement in transit.placements) {
      for (final natalPlacement in natal.placements.placements) {
        final separation = _shortestSeparation(
          transitPlacement.longitudeDegrees,
          natalPlacement.longitudeDegrees,
        );
        MajorAspect? bestAspect;
        var bestOrb = double.infinity;
        for (final aspect in MajorAspect.values) {
          final orb = (separation - aspect.exactAngleDegrees).abs();
          final allowed = policy.forBodies(
            aspect,
            transitPlacement.body,
            natalPlacement.body,
          );
          if (orb <= allowed && orb < bestOrb) {
            bestAspect = aspect;
            bestOrb = orb;
          }
        }
        if (bestAspect != null) {
          hits.add(
            TransitNatalAspectHit(
              transitBody: transitPlacement.body,
              natalBody: natalPlacement.body,
              aspect: bestAspect,
              separationDegrees: separation,
              orbDegrees: bestOrb,
              phase: WesternNatalAspects.phaseFor(
                longitudeA: transitPlacement.longitudeDegrees,
                longitudeB: natalPlacement.longitudeDegrees,
                speedA: transitPlacement.longitudeSpeedDegreesPerDay,
                speedB: 0,
                aspect: bestAspect,
              ),
            ),
          );
        }
      }
    }

    return NatalTransitComparison(
      natalJdTt: natal.jdTt,
      transitJdTt: transit.jdTt,
      sourceId: transit.sourceId,
      dataVersion: transit.dataVersion,
      aspects: hits,
    );
  }

  static double _shortestSeparation(double a, double b) {
    final difference = (a - b).abs() % 360.0;
    return difference > 180.0 ? 360.0 - difference : difference;
  }
}
