import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

final class SecondaryProgressionResult {
  SecondaryProgressionResult({
    required this.natalJdTt,
    required this.ageYears,
    required this.progressedJdTt,
    required this.sourceId,
    required this.dataVersion,
    required List<EclipticState> states,
  }) : states = List<EclipticState>.unmodifiable(states);

  final double natalJdTt;
  final double ageYears;
  final double progressedJdTt;
  final String sourceId;
  final String dataVersion;
  final List<EclipticState> states;
}

/// Secondary progressions using the conventional day-for-year mapping:
/// one ephemeris day after birth corresponds to one year of life.
///
/// The caller supplies an explicit age; device time and inferred current age are
/// never used. Planet positions are sampled from the versioned ephemeris at the
/// exact progressed TT instant.
abstract final class WesternSecondaryProgressions {
  static SecondaryProgressionResult calculate({
    required double natalJdTt,
    required double ageYears,
    required Iterable<AstroBody> bodies,
    required EphemerisProvider ephemeris,
  }) {
    if (!natalJdTt.isFinite || !ageYears.isFinite || ageYears < 0) {
      throw RangeError('Natal TT and non-negative finite age are required.');
    }
    final requested = bodies.toList(growable: false);
    if (requested.isEmpty || requested.toSet().length != requested.length) {
      throw ArgumentError('Progression bodies must be non-empty and unique.');
    }

    final progressedJdTt = natalJdTt + ageYears;
    ephemeris.coverage.requireContains(natalJdTt);
    ephemeris.coverage.requireContains(progressedJdTt);

    final states = <EclipticState>[];
    for (final body in requested) {
      final state = ephemeris.stateAt(body: body, jdTt: progressedJdTt);
      _requireStateMatches(
        state: state,
        body: body,
        jdTt: progressedJdTt,
        ephemeris: ephemeris,
      );
      states.add(state);
    }
    states.sort((a, b) => a.body.index.compareTo(b.body.index));

    return SecondaryProgressionResult(
      natalJdTt: natalJdTt,
      ageYears: ageYears,
      progressedJdTt: progressedJdTt,
      sourceId: ephemeris.coverage.sourceId,
      dataVersion: ephemeris.coverage.dataVersion,
      states: states,
    );
  }
}

final class SolarArcPlacement {
  const SolarArcPlacement({
    required this.body,
    required this.natalLongitudeDegrees,
    required this.directedLongitudeDegrees,
  });

  final AstroBody body;
  final double natalLongitudeDegrees;
  final double directedLongitudeDegrees;
}

final class SolarArcResult {
  SolarArcResult({
    required this.natalJdTt,
    required this.progressedJdTt,
    required this.arcDegrees,
    required this.sourceId,
    required this.dataVersion,
    required List<SolarArcPlacement> placements,
  }) : placements = List<SolarArcPlacement>.unmodifiable(placements);

  final double natalJdTt;
  final double progressedJdTt;
  final double arcDegrees;
  final String sourceId;
  final String dataVersion;
  final List<SolarArcPlacement> placements;
}

/// Directs every natal longitude by the same arc travelled by the secondary
/// progressed Sun. This keeps Solar Arc distinct from transits and from simply
/// multiplying a mean daily solar motion by age.
abstract final class WesternSolarArc {
  static SolarArcResult calculate({
    required NatalPlacementSet natal,
    required double ageYears,
    required EphemerisProvider ephemeris,
  }) {
    if (!ageYears.isFinite || ageYears < 0) {
      throw RangeError('Solar Arc age must be non-negative and finite.');
    }
    if (natal.sourceId != ephemeris.coverage.sourceId ||
        natal.dataVersion != ephemeris.coverage.dataVersion) {
      throw StateError('Natal and ephemeris provenance must match for Solar Arc.');
    }
    final sun = natal.forBody(AstroBody.sun);
    final progressedJdTt = natal.jdTt + ageYears;
    ephemeris.coverage.requireContains(natal.jdTt);
    ephemeris.coverage.requireContains(progressedJdTt);
    final progressedSun = ephemeris.stateAt(body: AstroBody.sun, jdTt: progressedJdTt);
    _requireStateMatches(
      state: progressedSun,
      body: AstroBody.sun,
      jdTt: progressedJdTt,
      ephemeris: ephemeris,
    );

    final arc = _normalize360(progressedSun.longitudeDegrees - sun.longitudeDegrees);
    final placements = natal.placements
        .map(
          (placement) => SolarArcPlacement(
            body: placement.body,
            natalLongitudeDegrees: placement.longitudeDegrees,
            directedLongitudeDegrees: _normalize360(placement.longitudeDegrees + arc),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.body.index.compareTo(b.body.index));

    return SolarArcResult(
      natalJdTt: natal.jdTt,
      progressedJdTt: progressedJdTt,
      arcDegrees: arc,
      sourceId: natal.sourceId,
      dataVersion: natal.dataVersion,
      placements: placements,
    );
  }
}

final class AnnualProfectionResult {
  const AnnualProfectionResult({
    required this.ageYears,
    required this.activatedHouse,
    required this.natalAscendantSign,
    required this.activatedSign,
  });

  final int ageYears;
  final int activatedHouse;
  final TropicalZodiacSign natalAscendantSign;
  final TropicalZodiacSign activatedSign;
}

/// Traditional annual profections: age zero activates the first house/sign;
/// each birthday advances one house/sign and the cycle repeats every 12 years.
abstract final class WesternAnnualProfections {
  static AnnualProfectionResult calculate({
    required int ageYears,
    required double natalAscendantLongitudeDegrees,
  }) {
    if (ageYears < 0) {
      throw RangeError('Annual profection age cannot be negative.');
    }
    if (!natalAscendantLongitudeDegrees.isFinite ||
        natalAscendantLongitudeDegrees < 0 ||
        natalAscendantLongitudeDegrees >= 360) {
      throw RangeError('Natal Ascendant longitude must be normalized to [0, 360).');
    }

    final natalSignIndex = (natalAscendantLongitudeDegrees / 30.0).floor();
    final offset = ageYears % 12;
    final activatedSignIndex = (natalSignIndex + offset) % 12;
    return AnnualProfectionResult(
      ageYears: ageYears,
      activatedHouse: offset + 1,
      natalAscendantSign: TropicalZodiacSign.values[natalSignIndex],
      activatedSign: TropicalZodiacSign.values[activatedSignIndex],
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
    throw StateError('Predictive-technique ephemeris body/instant/provenance mismatch.');
  }
}

double _normalize360(double value) {
  var normalized = value % 360.0;
  if (normalized < 0) normalized += 360.0;
  return normalized;
}
