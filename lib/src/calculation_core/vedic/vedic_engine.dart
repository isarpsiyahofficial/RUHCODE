import '../ephemeris/ephemeris.dart';

/// Ayanamsha is a Vedic-engine concern. Implementations must be independently
/// versioned and must not call into the Western astrology calculation layer.
abstract interface class VedicAyanamshaProvider {
  String get id;
  String get dataVersion;

  /// Returns the ayanamsha in degrees for the exact TT instant.
  double degreesAt(double jdTt);
}

final class VedicPlacement {
  const VedicPlacement({
    required this.body,
    required this.siderealLongitudeDegrees,
    required this.longitudeSpeedDegreesPerDay,
  });

  final AstroBody body;
  final double siderealLongitudeDegrees;
  final double longitudeSpeedDegreesPerDay;
}

final class VedicCalculationSnapshot {
  VedicCalculationSnapshot({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.ayanamshaDegrees,
    required List<VedicPlacement> placements,
  }) : placements = List<VedicPlacement>.unmodifiable(placements);

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final double ayanamshaDegrees;
  final List<VedicPlacement> placements;

  VedicPlacement forBody(AstroBody body) =>
      placements.singleWhere((placement) => placement.body == body);
}

/// Independent Vedic calculation boundary.
///
/// This engine consumes only the shared astronomical ephemeris and a Vedic
/// ayanamsha policy. It intentionally has no dependency on the Western engine,
/// Western zodiac models, Western houses, Western aspects or Western chart
/// assemblers. Shared astronomical observations are transformed into a Vedic
/// snapshot inside this namespace instead of taking a Western chart and
/// applying a post-processing offset to it.
abstract final class VedicCalculationEngine {
  static VedicCalculationSnapshot calculate({
    required double jdTt,
    required Iterable<AstroBody> bodies,
    required EphemerisProvider ephemeris,
    required VedicAyanamshaProvider ayanamsha,
  }) {
    if (!jdTt.isFinite) {
      throw RangeError('Vedic calculation requires a finite TT instant.');
    }
    ephemeris.coverage.requireContains(jdTt);

    final requested = bodies.toList(growable: false);
    if (requested.isEmpty || requested.toSet().length != requested.length) {
      throw ArgumentError('Vedic calculation bodies must be non-empty and unique.');
    }
    if (ayanamsha.id.trim().isEmpty || ayanamsha.dataVersion.trim().isEmpty) {
      throw StateError('Vedic ayanamsha provenance must be explicit.');
    }

    final ayanamshaDegrees = ayanamsha.degreesAt(jdTt);
    if (!ayanamshaDegrees.isFinite ||
        ayanamshaDegrees < 0 ||
        ayanamshaDegrees >= 360) {
      throw StateError('Vedic ayanamsha must be normalized to [0, 360).');
    }

    final placements = <VedicPlacement>[];
    for (final body in requested) {
      final state = ephemeris.stateAt(body: body, jdTt: jdTt);
      _requireStateMatches(
        state: state,
        body: body,
        jdTt: jdTt,
        ephemeris: ephemeris,
      );
      placements.add(
        VedicPlacement(
          body: body,
          siderealLongitudeDegrees:
              _normalize360(state.longitudeDegrees - ayanamshaDegrees),
          longitudeSpeedDegreesPerDay: state.longitudeSpeedDegreesPerDay,
        ),
      );
    }
    placements.sort((a, b) => a.body.index.compareTo(b.body.index));

    return VedicCalculationSnapshot(
      jdTt: jdTt,
      ephemerisSourceId: ephemeris.coverage.sourceId,
      ephemerisDataVersion: ephemeris.coverage.dataVersion,
      ayanamshaId: ayanamsha.id,
      ayanamshaDataVersion: ayanamsha.dataVersion,
      ayanamshaDegrees: ayanamshaDegrees,
      placements: placements,
    );
  }
}

void _requireStateMatches({
  required EclipticState state,
  required AstroBody body,
  required double jdTt,
  required EphemerisProvider ephemeris,
}) {
  if (state.body != body ||
      (state.jdTt - jdTt).abs() > 1e-12 ||
      state.sourceId != ephemeris.coverage.sourceId ||
      state.dataVersion != ephemeris.coverage.dataVersion) {
    throw StateError('Vedic ephemeris body/instant/provenance mismatch.');
  }
  if (!state.longitudeDegrees.isFinite ||
      state.longitudeDegrees < 0 ||
      state.longitudeDegrees >= 360 ||
      !state.longitudeSpeedDegreesPerDay.isFinite) {
    throw StateError('Vedic ephemeris state is not normalized/finite.');
  }
}

double _normalize360(double value) {
  var normalized = value % 360.0;
  if (normalized < 0) normalized += 360.0;
  return normalized;
}
