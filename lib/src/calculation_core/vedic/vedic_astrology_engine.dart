import '../../domain/models/core_models.dart';
import '../calculation_engine.dart';
import '../ephemeris/ephemeris.dart';

final class VedicAstrologyInput {
  const VedicAstrologyInput({
    required this.manifest,
    required this.states,
    required this.ayanamshaDegrees,
  });

  final CalculationManifest manifest;
  final List<EclipticState> states;
  final double ayanamshaDegrees;
}

final class VedicPlacement {
  const VedicPlacement({
    required this.body,
    required this.tropicalLongitudeDegrees,
    required this.siderealLongitudeDegrees,
    required this.latitudeDegrees,
    required this.distanceAu,
    required this.longitudeSpeedDegreesPerDay,
  });

  final AstroBody body;
  final double tropicalLongitudeDegrees;
  final double siderealLongitudeDegrees;
  final double latitudeDegrees;
  final double distanceAu;
  final double longitudeSpeedDegreesPerDay;
}

final class VedicChart {
  const VedicChart({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDegrees,
    required this.placements,
  });

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final String ayanamshaId;
  final double ayanamshaDegrees;
  final List<VedicPlacement> placements;
}

final class VedicAstrologyEngine
    implements CalculationEngine<VedicAstrologyInput, VedicChart> {
  const VedicAstrologyEngine();

  @override
  String get engineId => 'vedic-astrology';

  @override
  String get engineVersion => '1.0.0';

  @override
  Future<CalculationResult<VedicChart>> calculate(VedicAstrologyInput input) async {
    final manifest = input.manifest;
    if (manifest.engineId != engineId) {
      throw StateError('Vedic astrology manifest engineId mismatch.');
    }
    if (manifest.validity != CalculationValidity.valid) {
      throw StateError('Vedic astrology requires a valid calculation manifest.');
    }
    if (manifest.zodiacSystemId != 'sidereal') {
      throw StateError('Vedic astrology requires an explicit sidereal zodiac manifest.');
    }
    final ayanamshaId = manifest.ayanamshaId?.trim() ?? '';
    if (ayanamshaId.isEmpty) {
      throw StateError('Vedic astrology requires an explicit ayanamsha identifier.');
    }
    if (!input.ayanamshaDegrees.isFinite ||
        input.ayanamshaDegrees < 0 ||
        input.ayanamshaDegrees >= 360) {
      throw RangeError('Vedic ayanamsha must be finite and normalized to [0, 360).');
    }
    if (input.states.isEmpty) {
      throw StateError('Vedic astrology requires ephemeris states.');
    }

    final first = input.states.first;
    if (first.dataVersion != manifest.dataVersion) {
      throw StateError('Vedic astrology ephemeris/manifest dataVersion mismatch.');
    }

    final seenBodies = <AstroBody>{};
    final placements = <VedicPlacement>[];
    for (final state in input.states) {
      state.validate();
      if (!seenBodies.add(state.body)) {
        throw StateError('Vedic astrology ephemeris body set contains duplicates.');
      }
      if ((state.jdTt - first.jdTt).abs() > 1e-12 ||
          state.sourceId != first.sourceId ||
          state.dataVersion != first.dataVersion) {
        throw StateError('Vedic astrology requires same-instant ephemeris provenance.');
      }
      if (state.dataVersion != manifest.dataVersion) {
        throw StateError('Vedic astrology ephemeris/manifest dataVersion mismatch.');
      }

      placements.add(
        VedicPlacement(
          body: state.body,
          tropicalLongitudeDegrees: state.longitudeDegrees,
          siderealLongitudeDegrees: _normalizeDegrees(
            state.longitudeDegrees - input.ayanamshaDegrees,
          ),
          latitudeDegrees: state.latitudeDegrees,
          distanceAu: state.distanceAu,
          longitudeSpeedDegreesPerDay: state.longitudeSpeedDegreesPerDay,
        ),
      );
    }

    final chart = VedicChart(
      jdTt: first.jdTt,
      sourceId: first.sourceId,
      dataVersion: first.dataVersion,
      ayanamshaId: ayanamshaId,
      ayanamshaDegrees: input.ayanamshaDegrees,
      placements: List<VedicPlacement>.unmodifiable(placements),
    );

    return CalculationResult<VedicChart>(manifest: manifest, value: chart);
  }

  static double _normalizeDegrees(double value) {
    final normalized = value % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }
}
