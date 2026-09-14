import '../ephemeris/ephemeris.dart';
import 'aspect_grid.dart';
import 'degree_tables.dart';
import 'equal_house_systems.dart';
import 'essential_dignities.dart';
import 'house_rulers.dart';
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
    required this.planetDegreeTable,
    required this.houseDegreeTable,
    required this.dignities,
    required this.houseRulers,
  });

  final double jdTt;
  final String sourceId;
  final String dataVersion;
  final HouseCusps houses;
  final NatalPlacementSet placements;
  final NatalAspectSet aspects;
  final NatalAspectGrid aspectGrid;
  final List<PlanetDegreeRow> planetDegreeTable;
  final List<HouseDegreeRow> houseDegreeTable;
  final EssentialDignitySet dignities;
  final HouseRulerSet houseRulers;
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
    final planetDegreeTable = WesternDegreeTables.planets(placements);
    final houseDegreeTable = WesternDegreeTables.houses(houses);
    final dignities = WesternEssentialDignities.build(placements: placements);
    final houseRulers = WesternHouseRulers.build(houses: houses);

    _validateDerivedBodySets(
      placements: placements,
      aspectGrid: aspectGrid,
      planetDegreeTable: planetDegreeTable,
      dignities: dignities,
    );
    _validateHouseDegreeTable(houseDegreeTable);

    return WesternNatalChart(
      jdTt: placements.jdTt,
      sourceId: placements.sourceId,
      dataVersion: placements.dataVersion,
      houses: houses,
      placements: placements,
      aspects: aspects,
      aspectGrid: aspectGrid,
      planetDegreeTable: planetDegreeTable,
      houseDegreeTable: houseDegreeTable,
      dignities: dignities,
      houseRulers: houseRulers,
    );
  }

  static void _validateDerivedBodySets({
    required NatalPlacementSet placements,
    required NatalAspectGrid aspectGrid,
    required List<PlanetDegreeRow> planetDegreeTable,
    required EssentialDignitySet dignities,
  }) {
    final placementBodies = placements.placements.map((item) => item.body).toSet();
    final gridBodies = aspectGrid.bodies.toSet();
    final tableBodies = planetDegreeTable.map((item) => item.body).toSet();
    final dignityBodies = dignities.assessments.map((item) => item.body).toSet();

    if (placementBodies.length != placements.placements.length) {
      throw StateError('Natal placement body set contains duplicates.');
    }
    if (gridBodies.length != aspectGrid.bodies.length ||
        !gridBodies.containsAll(placementBodies) ||
        !placementBodies.containsAll(gridBodies)) {
      throw StateError('Natal aspect-grid body set does not match placements.');
    }
    if (tableBodies.length != planetDegreeTable.length ||
        !tableBodies.containsAll(placementBodies) ||
        !placementBodies.containsAll(tableBodies)) {
      throw StateError('Natal planet-degree table body set does not match placements.');
    }
    if (dignityBodies.length != dignities.assessments.length ||
        !dignityBodies.containsAll(placementBodies) ||
        !placementBodies.containsAll(dignityBodies)) {
      throw StateError('Natal dignity body set does not match placements.');
    }
  }

  static void _validateHouseDegreeTable(List<HouseDegreeRow> houseDegreeTable) {
    if (houseDegreeTable.length != 12) {
      throw StateError('Natal house-degree table must contain exactly 12 houses.');
    }
    final houseNumbers = houseDegreeTable.map((item) => item.houseNumber).toSet();
    final expected = Set<int>.from(List<int>.generate(12, (index) => index + 1));
    if (houseNumbers.length != 12 || !houseNumbers.containsAll(expected)) {
      throw StateError('Natal house-degree table must contain houses 1 through 12 exactly once.');
    }
  }
}
