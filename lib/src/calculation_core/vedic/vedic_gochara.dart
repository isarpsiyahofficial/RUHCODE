import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

const List<AstroBody> canonicalGocharaBodies = <AstroBody>[
  AstroBody.sun,
  AstroBody.moon,
  AstroBody.mercury,
  AstroBody.venus,
  AstroBody.mars,
  AstroBody.jupiter,
  AstroBody.saturn,
  AstroBody.meanNode,
];

final class VedicGocharaSnapshot {
  const VedicGocharaSnapshot({required this.vedic});

  final VedicCalculationSnapshot vedic;

  VedicPlacement forBody(AstroBody body) => vedic.forBody(body);
}

/// RC-0111: computes a versioned sidereal Gochara snapshot at an explicit TT
/// instant. It intentionally reuses only the independent Vedic engine and its
/// ephemeris/ayanamsha provenance; no Western chart/transit layer is imported.
abstract final class VedicGochara {
  static VedicGocharaSnapshot calculate({
    required double jdTt,
    required EphemerisProvider ephemeris,
    required VedicAyanamshaProvider ayanamsha,
    Iterable<AstroBody> bodies = canonicalGocharaBodies,
  }) {
    final requested = bodies.toList(growable: false);
    if (requested.isEmpty || requested.toSet().length != requested.length) {
      throw ArgumentError('Gochara bodies must be non-empty and unique.');
    }

    final vedic = VedicCalculationEngine.calculate(
      jdTt: jdTt,
      bodies: requested,
      ephemeris: ephemeris,
      ayanamsha: ayanamsha,
    );
    return VedicGocharaSnapshot(vedic: vedic);
  }
}
