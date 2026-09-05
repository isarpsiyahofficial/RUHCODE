import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';
import 'natal_placements.dart';

final class WesternSunMoonAscendant {
  const WesternSunMoonAscendant({
    required this.sun,
    required this.moon,
    required this.ascendantLongitudeDegrees,
    required this.ascendantSign,
    required this.ascendantDegreeInSign,
  });

  final NatalPlacement sun;
  final NatalPlacement moon;
  final double ascendantLongitudeDegrees;
  final TropicalZodiacSign ascendantSign;
  final double ascendantDegreeInSign;
}

abstract final class WesternLuminariesAscendant {
  static WesternSunMoonAscendant build({
    required List<EclipticState> states,
    required HouseCusps houses,
    double stationaryThresholdDegreesPerDay = 1e-4,
  }) {
    final placements = WesternNatalPlacements.build(
      states: states,
      houses: houses,
      stationaryThresholdDegreesPerDay: stationaryThresholdDegreesPerDay,
    );
    final sun = placements.forBody(AstroBody.sun);
    final moon = placements.forBody(AstroBody.moon);
    final ascendant = houses.ascendantLongitude;
    if (!ascendant.isFinite || ascendant < 0.0 || ascendant >= 360.0) {
      throw StateError('Ascendant longitude must be finite and in [0, 360).');
    }
    final signIndex = (ascendant / 30.0).floor();
    return WesternSunMoonAscendant(
      sun: sun,
      moon: moon,
      ascendantLongitudeDegrees: ascendant,
      ascendantSign: TropicalZodiacSign.values[signIndex],
      ascendantDegreeInSign: ascendant - signIndex * 30.0,
    );
  }
}
