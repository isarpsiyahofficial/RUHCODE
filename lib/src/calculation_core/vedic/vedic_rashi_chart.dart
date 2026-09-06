import 'vedic_engine.dart';
import 'vedic_lagna.dart';

final class VedicRashiPlacement {
  const VedicRashiPlacement({
    required this.placement,
    required this.rashiIndex,
    required this.degreesWithinRashi,
    required this.wholeSignHouse,
  });

  final VedicPlacement placement;
  final int rashiIndex;
  final double degreesWithinRashi;
  final int wholeSignHouse;
}

final class VedicRashiChart {
  VedicRashiChart({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.lagnaRashiIndex,
    required List<VedicRashiPlacement> placements,
  }) : placements = List<VedicRashiPlacement>.unmodifiable(placements);

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final int lagnaRashiIndex;
  final List<VedicRashiPlacement> placements;
}

/// RC-0090 Rashi chart + RC-0091 Vedic Whole Sign house assignment.
abstract final class VedicRashiChartBuilder {
  static VedicRashiChart build({
    required VedicCalculationSnapshot snapshot,
    required VedicLagnaResult lagna,
  }) {
    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty) {
      throw StateError('Rashi chart requires explicit Vedic provenance.');
    }
    if (snapshot.ayanamshaId != lagna.ayanamshaId ||
        snapshot.ayanamshaDataVersion != lagna.ayanamshaDataVersion) {
      throw StateError('Rashi chart ayanamsha provenance mismatch.');
    }
    if (lagna.rashiIndex < 0 || lagna.rashiIndex > 11) {
      throw StateError('Lagna Rashi index must be within the 12-sign cycle.');
    }
    if (snapshot.placements.isEmpty) {
      throw StateError('Rashi chart requires at least one Graha placement.');
    }

    final seenBodies = <Object>{};
    final result = <VedicRashiPlacement>[];
    for (final placement in snapshot.placements) {
      final longitude = placement.siderealLongitudeDegrees;
      if (!seenBodies.add(placement.body)) {
        throw StateError('Rashi chart contains duplicate Graha placements.');
      }
      if (!longitude.isFinite || longitude < 0 || longitude >= 360) {
        throw StateError('Rashi chart requires normalized sidereal longitudes.');
      }
      final rashiIndex = (longitude / 30.0).floor();
      final house = ((rashiIndex - lagna.rashiIndex + 12) % 12) + 1;
      result.add(
        VedicRashiPlacement(
          placement: placement,
          rashiIndex: rashiIndex,
          degreesWithinRashi: longitude % 30.0,
          wholeSignHouse: house,
        ),
      );
    }
    result.sort((a, b) => a.placement.body.index.compareTo(b.placement.body.index));

    return VedicRashiChart(
      jdTt: snapshot.jdTt,
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
      lagnaRashiIndex: lagna.rashiIndex,
      placements: result,
    );
  }
}
