import '../ephemeris/ephemeris.dart';
import 'vedic_engine.dart';

/// Explicit lunar-node policy for Vedic Rahu/Ketu calculations.
///
/// The caller must choose mean or true node. The calculation never silently
/// swaps policies, which keeps RC-0086/RC-0087 reproducible and auditable.
enum VedicNodeMode {
  mean(AstroBody.meanNode),
  trueNode(AstroBody.trueNode);

  const VedicNodeMode(this.ephemerisBody);

  final AstroBody ephemerisBody;
}

final class VedicNodePoint {
  const VedicNodePoint({
    required this.siderealLongitudeDegrees,
    required this.longitudeSpeedDegreesPerDay,
  });

  final double siderealLongitudeDegrees;
  final double longitudeSpeedDegreesPerDay;
}

/// Provenance-preserving Rahu/Ketu pair derived from one explicit node policy.
///
/// Rahu is the selected sidereal lunar-node placement supplied by the
/// independent Vedic engine. Ketu is the exact antipode of that same node,
/// preserving the node's angular speed. This layer does not fabricate a node
/// position or mix mean/true node inputs.
final class VedicRahuKetu {
  VedicRahuKetu._({
    required this.jdTt,
    required this.mode,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.rahu,
    required this.ketu,
  });

  final double jdTt;
  final VedicNodeMode mode;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final VedicNodePoint rahu;
  final VedicNodePoint ketu;

  static VedicRahuKetu fromSnapshot({
    required VedicCalculationSnapshot snapshot,
    required VedicNodeMode mode,
  }) {
    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty) {
      throw StateError('Vedic node snapshot provenance must be explicit.');
    }

    final matches = snapshot.placements
        .where((placement) => placement.body == mode.ephemerisBody)
        .toList(growable: false);
    if (matches.length != 1) {
      throw StateError(
        'Vedic ${mode.name} node calculation requires exactly one node placement.',
      );
    }

    final node = matches.single;
    _requireFiniteNormalized(node);
    final ketuLongitude = _normalize360(
      node.siderealLongitudeDegrees + 180.0,
    );

    return VedicRahuKetu._(
      jdTt: snapshot.jdTt,
      mode: mode,
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
      rahu: VedicNodePoint(
        siderealLongitudeDegrees: node.siderealLongitudeDegrees,
        longitudeSpeedDegreesPerDay: node.longitudeSpeedDegreesPerDay,
      ),
      ketu: VedicNodePoint(
        siderealLongitudeDegrees: ketuLongitude,
        longitudeSpeedDegreesPerDay: node.longitudeSpeedDegreesPerDay,
      ),
    );
  }
}

void _requireFiniteNormalized(VedicPlacement placement) {
  if (!placement.siderealLongitudeDegrees.isFinite ||
      placement.siderealLongitudeDegrees < 0 ||
      placement.siderealLongitudeDegrees >= 360 ||
      !placement.longitudeSpeedDegreesPerDay.isFinite) {
    throw StateError('Vedic node placement must be normalized and finite.');
  }
}

double _normalize360(double value) {
  var normalized = value % 360.0;
  if (normalized < 0) normalized += 360.0;
  return normalized;
}
