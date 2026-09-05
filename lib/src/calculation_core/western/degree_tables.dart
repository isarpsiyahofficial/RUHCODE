import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';
import 'natal_placements.dart';

final class PlanetDegreeRow {
  const PlanetDegreeRow({
    required this.body,
    required this.longitudeDegrees,
    required this.sign,
    required this.degreeInSign,
    required this.houseNumber,
  });

  final AstroBody body;
  final double longitudeDegrees;
  final TropicalZodiacSign sign;
  final double degreeInSign;
  final int houseNumber;
}

final class HouseDegreeRow {
  const HouseDegreeRow({
    required this.houseNumber,
    required this.cuspLongitudeDegrees,
    required this.sign,
    required this.degreeInSign,
  });

  final int houseNumber;
  final double cuspLongitudeDegrees;
  final TropicalZodiacSign sign;
  final double degreeInSign;
}

abstract final class WesternDegreeTables {
  static List<PlanetDegreeRow> planets(NatalPlacementSet placements) =>
      List<PlanetDegreeRow>.unmodifiable(
        placements.placements.map(
          (placement) => PlanetDegreeRow(
            body: placement.body,
            longitudeDegrees: placement.longitudeDegrees,
            sign: placement.sign,
            degreeInSign: placement.degreeInSign,
            houseNumber: placement.houseNumber,
          ),
        ),
      );

  static List<HouseDegreeRow> houses(HouseCusps houses) =>
      List<HouseDegreeRow>.unmodifiable(
        List<HouseDegreeRow>.generate(12, (index) {
          final houseNumber = index + 1;
          final longitude = houses.cusp(houseNumber);
          final signIndex = (longitude / 30.0).floor();
          return HouseDegreeRow(
            houseNumber: houseNumber,
            cuspLongitudeDegrees: longitude,
            sign: TropicalZodiacSign.values[signIndex],
            degreeInSign: longitude - signIndex * 30.0,
          );
        }, growable: false),
      );
}
