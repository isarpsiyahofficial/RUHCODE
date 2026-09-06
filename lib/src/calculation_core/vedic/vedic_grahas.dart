import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

/// Canonical classical Grahas covered by RC-0085.
/// Rahu and Ketu remain separate RC-0086/RC-0087 requirements.
const List<AstroBody> canonicalClassicalGrahas = <AstroBody>[
  AstroBody.sun,
  AstroBody.moon,
  AstroBody.mercury,
  AstroBody.venus,
  AstroBody.mars,
  AstroBody.jupiter,
  AstroBody.saturn,
];

final class VedicGrahaSet {
  VedicGrahaSet._({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required List<VedicPlacement> placements,
  }) : placements = List<VedicPlacement>.unmodifiable(placements);

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final List<VedicPlacement> placements;

  VedicPlacement forGraha(AstroBody body) {
    if (!canonicalClassicalGrahas.contains(body)) {
      throw ArgumentError.value(body, 'body', 'Not a classical Graha.');
    }
    return placements.singleWhere((placement) => placement.body == body);
  }

  static VedicGrahaSet fromSnapshot(VedicCalculationSnapshot snapshot) {
    final byBody = <AstroBody, VedicPlacement>{};
    for (final placement in snapshot.placements) {
      if (byBody.containsKey(placement.body)) {
        throw StateError('Duplicate Vedic placement for ${placement.body.name}.');
      }
      byBody[placement.body] = placement;
    }

    final missing = canonicalClassicalGrahas
        .where((body) => !byBody.containsKey(body))
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw StateError(
        'RC-0085 Graha set is incomplete: ${missing.map((body) => body.name).join(', ')}',
      );
    }

    final placements = canonicalClassicalGrahas
        .map((body) => byBody[body]!)
        .toList(growable: false);
    for (final placement in placements) {
      if (!placement.siderealLongitudeDegrees.isFinite ||
          placement.siderealLongitudeDegrees < 0 ||
          placement.siderealLongitudeDegrees >= 360 ||
          !placement.longitudeSpeedDegreesPerDay.isFinite) {
        throw StateError('Graha placement is not normalized/finite.');
      }
    }

    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty) {
      throw StateError('Graha snapshot provenance must be explicit.');
    }

    return VedicGrahaSet._(
      jdTt: snapshot.jdTt,
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
      placements: placements,
    );
  }
}
