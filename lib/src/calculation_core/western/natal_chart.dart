import '../ephemeris/ephemeris.dart';
import 'aspect_grid.dart';
import 'equal_house_systems.dart';
import 'essential_dignities.dart';
import 'natal_aspects.dart';
import 'natal_placements.dart';

final class WesternNatalChart {
  const WesternNatalChart({
    required this.jdTt,
    required this.sourceId,
    required this.dataVersion,
    required this.houses,
    required this.placements,
    required this.aspects,
    required this.aspectGrid,
    required this.dignities,
  });

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final HouseCusps houses;
  final NatalPlacementSet placements;
  final NatalAspectSet aspects;
  final NatalAspectGrid aspectGrid;
  final EssentialDignitySet dignities;
}

abstract final class WesternNatalChartAssembler {
  static WesternNatalChart build({
    required List<EclipticState> states,
    required HouseCusps houses,
    AspectOrbPolicy? orbPolicy,
    double stationaryThresholdDegreesPerDay = 1e-4,
  }) {
    final placements = WesternNatalPlacements.build(
      states: states,
      houses: houses,
      stationaryThresholdDegreesPerDay: stationaryThresholdDegreesPerDay,
    );
    final aspects = WesternNatalAspects.build(
      placements: placements,
      orbPolicy: orbPolicy,
    );

    if ((placements.jdTt - aspects.jdTt).abs() > 1e-12 ||
        placements.sourceId != aspects.sourceId ||
        placements.dataVersion != aspects.dataVersion) {
      throw StateError('Natal placements/aspects provenance mismatch.');
    }

    final aspectGrid = WesternAspectGrid.build(
      placements: placements,
      aspects: aspects,
    );
    final dignities = WesternEssentialDignities.build(placements: placements);

    return WesternNatalChart(
      jdTt: placements.jdTt,
      sourceId: placements.sourceId,
      dataVersion: placements.dataVersion,
      houses: houses,
      placements: placements,
      aspects: aspects,
      aspectGrid: aspectGrid,
      dignities: dignities,
    );
  }
}
