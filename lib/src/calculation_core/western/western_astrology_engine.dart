import '../../domain/models/core_models.dart';
import '../calculation_engine.dart';
import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';
import 'natal_aspects.dart';
import 'natal_chart.dart';

final class WesternAstrologyInput {
  const WesternAstrologyInput({
    required this.manifest,
    required this.states,
    required this.houses,
    this.orbPolicy,
    this.stationaryThresholdDegreesPerDay = 1e-4,
  });

  final CalculationManifest manifest;
  final List<EclipticState> states;
  final HouseCusps houses;
  final AspectOrbPolicy? orbPolicy;
  final double stationaryThresholdDegreesPerDay;
}

final class WesternAstrologyEngine
    implements CalculationEngine<WesternAstrologyInput, WesternNatalChart> {
  const WesternAstrologyEngine();

  @override
  String get engineId => 'western-astrology';

  @override
  String get engineVersion => '1.0.0';

  @override
  Future<CalculationResult<WesternNatalChart>> calculate(
    WesternAstrologyInput input,
  ) async {
    if (input.manifest.engineId != engineId) {
      throw StateError('Western astrology manifest engineId mismatch.');
    }
    if (input.manifest.validity != CalculationValidity.valid) {
      throw StateError('Western astrology requires a valid calculation manifest.');
    }
    if (input.states.isEmpty) {
      throw StateError('Western astrology requires ephemeris states.');
    }

    final chart = WesternNatalChartAssembler.build(
      states: input.states,
      houses: input.houses,
      orbPolicy: input.orbPolicy,
      stationaryThresholdDegreesPerDay:
          input.stationaryThresholdDegreesPerDay,
    );

    if (chart.dataVersion != input.manifest.dataVersion) {
      throw StateError('Western astrology ephemeris/manifest dataVersion mismatch.');
    }

    return CalculationResult<WesternNatalChart>(
      manifest: input.manifest,
      value: chart,
    );
  }
}
