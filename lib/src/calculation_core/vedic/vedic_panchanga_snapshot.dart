import 'vedic_engine.dart';
import 'vedic_panchanga.dart';
import 'vedic_vara.dart';

final class VedicPanchangaSnapshot {
  const VedicPanchangaSnapshot({
    required this.core,
    required this.vara,
  });

  final VedicPanchangaCore core;
  final VedicVaraResult vara;
}

/// RC-0112: assembles all five Panchanga limbs from a sidereal Sun/Moon
/// snapshot plus a sunrise-boundary Vara calculation.
abstract final class VedicPanchangaAssembler {
  static VedicPanchangaSnapshot calculate({
    required VedicCalculationSnapshot vedicSnapshot,
    required double queryJdUt1,
    required double latitudeDegrees,
    required double longitudeDegrees,
    required SunriseBoundaryProvider sunriseProvider,
  }) {
    final core = VedicPanchanga.calculateFromSnapshot(vedicSnapshot);
    final vara = VedicVaraCalculator.calculate(
      queryJdUt1: queryJdUt1,
      latitudeDegrees: latitudeDegrees,
      longitudeDegrees: longitudeDegrees,
      sunriseProvider: sunriseProvider,
    );
    return VedicPanchangaSnapshot(core: core, vara: vara);
  }
}
