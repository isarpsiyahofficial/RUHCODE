import '../ephemeris/ephemeris.dart';

enum TransitAspectType {
  conjunction(0),
  sextile(60),
  square(90),
  trine(120),
  opposition(180);

  const TransitAspectType(this.exactAngleDegrees);
  final double exactAngleDegrees;
}

final class NatalPoint {
  NatalPoint({required this.body, required this.longitudeDegrees}) {
    if (!longitudeDegrees.isFinite || longitudeDegrees < 0 || longitudeDegrees >= 360) {
      throw RangeError('Natal longitude must be normalized to [0, 360).');
    }
  }

  final AstroBody body;
  final double longitudeDegrees;
}

final class TransitAspectOrbPolicy {
  const TransitAspectOrbPolicy({
    this.conjunction = 3,
    this.sextile = 2,
    this.square = 3,
    this.trine = 3,
    this.opposition = 3,
  });

  final double conjunction;
  final double sextile;
  final double square;
  final double trine;
  final double opposition;

  double forAspect(TransitAspectType aspect) => switch (aspect) {
        TransitAspectType.conjunction => conjunction,
        TransitAspectType.sextile => sextile,
        TransitAspectType.square => square,
        TransitAspectType.trine => trine,
        TransitAspectType.opposition => opposition,
      };

  void validate() {
    for (final value in <double>[conjunction, sextile, square, trine, opposition]) {
      if (!value.isFinite || value <= 0 || value > 15) {
        throw RangeError('Transit aspect orbs must be finite and within (0, 15].');
      }
    }
  }
}

final class TransitAspectMatch {
  const TransitAspectMatch({
    required this.transitBody,
    required this.natalBody,
    required this.aspect,
    required this.separationDegrees,
    required this.orbDegrees,
    required this.transitLongitudeDegrees,
    required this.natalLongitudeDegrees,
    required this.sourceId,
    required this.dataVersion,
  });

  final AstroBody transitBody;
  final AstroBody natalBody;
  final TransitAspectType aspect;
  final double separationDegrees;
  final double orbDegrees;
  final double transitLongitudeDegrees;
  final double natalLongitudeDegrees;
  final String sourceId;
  final String dataVersion;
}

final class TransitAspectEngine {
  TransitAspectEngine(
    this.ephemeris, {
    this.orbPolicy = const TransitAspectOrbPolicy(),
  }) {
    orbPolicy.validate();
  }

  final EphemerisProvider ephemeris;
  final TransitAspectOrbPolicy orbPolicy;

  List<TransitAspectMatch> calculate({
    required double jdTt,
    required Iterable<NatalPoint> natalPoints,
    required Iterable<AstroBody> transitBodies,
  }) {
    final natal = natalPoints.toList(growable: false);
    final bodies = transitBodies.toSet().toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    if (natal.isEmpty || bodies.isEmpty) {
      return const <TransitAspectMatch>[];
    }

    final matches = <TransitAspectMatch>[];
    for (final transitBody in bodies) {
      final state = ephemeris.stateAt(body: transitBody, jdTt: jdTt);
      for (final point in natal) {
        final separation = _smallestAngularSeparation(
          state.longitudeDegrees,
          point.longitudeDegrees,
        );
        for (final aspect in TransitAspectType.values) {
          final orb = (separation - aspect.exactAngleDegrees).abs();
          if (orb <= orbPolicy.forAspect(aspect)) {
            matches.add(
              TransitAspectMatch(
                transitBody: transitBody,
                natalBody: point.body,
                aspect: aspect,
                separationDegrees: separation,
                orbDegrees: orb,
                transitLongitudeDegrees: state.longitudeDegrees,
                natalLongitudeDegrees: point.longitudeDegrees,
                sourceId: state.sourceId,
                dataVersion: state.dataVersion,
              ),
            );
          }
        }
      }
    }

    matches.sort((a, b) {
      final byOrb = a.orbDegrees.compareTo(b.orbDegrees);
      if (byOrb != 0) return byOrb;
      final byTransit = a.transitBody.index.compareTo(b.transitBody.index);
      if (byTransit != 0) return byTransit;
      final byNatal = a.natalBody.index.compareTo(b.natalBody.index);
      if (byNatal != 0) return byNatal;
      return a.aspect.index.compareTo(b.aspect.index);
    });
    return List<TransitAspectMatch>.unmodifiable(matches);
  }

  static double _smallestAngularSeparation(double a, double b) {
    final difference = (a - b).abs() % 360;
    return difference > 180 ? 360 - difference : difference;
  }
}
