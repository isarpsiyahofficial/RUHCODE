import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

enum VedicPaksha { shukla, krishna }

enum VedicKarana {
  kimstughna,
  bava,
  balava,
  kaulava,
  taitila,
  garaja,
  vanija,
  vishti,
  shakuni,
  chatushpada,
  naga,
}

final class VedicPanchangaCore {
  const VedicPanchangaCore({
    required this.jdTt,
    required this.siderealSunLongitudeDegrees,
    required this.siderealMoonLongitudeDegrees,
    required this.tithiIndex,
    required this.tithiInPaksha,
    required this.paksha,
    required this.nakshatraIndex,
    required this.yogaIndex,
    required this.karanaHalfTithiIndex,
    required this.karana,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
  });

  final double jdTt;
  final double siderealSunLongitudeDegrees;
  final double siderealMoonLongitudeDegrees;
  final int tithiIndex;
  final int tithiInPaksha;
  final VedicPaksha paksha;
  final int nakshatraIndex;
  final int yogaIndex;
  final int karanaHalfTithiIndex;
  final VedicKarana karana;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
}

/// RC-0113/0115/0116/0117 calculation core.
///
/// Vara (RC-0114) is deliberately not synthesized here from a civil weekday:
/// Panchanga Vara needs the location-aware sunrise boundary, which is a
/// separate astronomical dependency. RC-0112 therefore remains incomplete
/// until that boundary is supplied and verified.
abstract final class VedicPanchanga {
  static const double nakshatraSpanDegrees = 360.0 / 27.0;
  static const double tithiSpanDegrees = 12.0;
  static const double karanaSpanDegrees = 6.0;

  static VedicPanchangaCore calculateFromSnapshot(
    VedicCalculationSnapshot snapshot,
  ) {
    _validateSnapshot(snapshot);
    final sun = snapshot.forBody(AstroBody.sun).siderealLongitudeDegrees;
    final moon = snapshot.forBody(AstroBody.moon).siderealLongitudeDegrees;

    final elongation = _normalize360(moon - sun);
    final tithiIndex = (elongation / tithiSpanDegrees).floor() + 1;
    final paksha = tithiIndex <= 15 ? VedicPaksha.shukla : VedicPaksha.krishna;
    final tithiInPaksha = ((tithiIndex - 1) % 15) + 1;
    final nakshatraIndex = (moon / nakshatraSpanDegrees).floor() + 1;
    final yogaIndex = (_normalize360(sun + moon) / nakshatraSpanDegrees).floor() + 1;
    final halfTithiIndex = (elongation / karanaSpanDegrees).floor() + 1;

    if (tithiIndex < 1 || tithiIndex > 30 ||
        nakshatraIndex < 1 || nakshatraIndex > 27 ||
        yogaIndex < 1 || yogaIndex > 27 ||
        halfTithiIndex < 1 || halfTithiIndex > 60) {
      throw StateError('Panchanga partition produced an out-of-range index.');
    }

    return VedicPanchangaCore(
      jdTt: snapshot.jdTt,
      siderealSunLongitudeDegrees: sun,
      siderealMoonLongitudeDegrees: moon,
      tithiIndex: tithiIndex,
      tithiInPaksha: tithiInPaksha,
      paksha: paksha,
      nakshatraIndex: nakshatraIndex,
      yogaIndex: yogaIndex,
      karanaHalfTithiIndex: halfTithiIndex,
      karana: _karanaForHalfTithi(halfTithiIndex),
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
    );
  }

  static VedicKarana _karanaForHalfTithi(int index) {
    if (index == 1) return VedicKarana.kimstughna;
    if (index == 58) return VedicKarana.shakuni;
    if (index == 59) return VedicKarana.chatushpada;
    if (index == 60) return VedicKarana.naga;

    const repeating = <VedicKarana>[
      VedicKarana.bava,
      VedicKarana.balava,
      VedicKarana.kaulava,
      VedicKarana.taitila,
      VedicKarana.garaja,
      VedicKarana.vanija,
      VedicKarana.vishti,
    ];
    return repeating[(index - 2) % repeating.length];
  }

  static void _validateSnapshot(VedicCalculationSnapshot snapshot) {
    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty) {
      throw StateError('Panchanga requires explicit TT and provenance.');
    }
    final bodies = snapshot.placements.map((p) => p.body).toList(growable: false);
    if (bodies.toSet().length != bodies.length ||
        !bodies.contains(AstroBody.sun) ||
        !bodies.contains(AstroBody.moon)) {
      throw StateError('Panchanga requires unique sidereal Sun and Moon placements.');
    }
    for (final placement in snapshot.placements) {
      final longitude = placement.siderealLongitudeDegrees;
      if (!longitude.isFinite || longitude < 0 || longitude >= 360) {
        throw StateError('Panchanga placements must be normalized to [0, 360).');
      }
    }
  }

  static double _normalize360(double value) {
    var normalized = value % 360.0;
    if (normalized < 0) normalized += 360.0;
    return normalized;
  }
}
