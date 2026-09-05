import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';
import 'natal_placements.dart';

enum WesternRulershipScheme { traditional, modern }

final class WesternHouseRuler {
  const WesternHouseRuler({
    required this.houseNumber,
    required this.cuspSign,
    required this.ruler,
    required this.scheme,
  });

  final int houseNumber;
  final TropicalZodiacSign cuspSign;
  final AstroBody ruler;
  final WesternRulershipScheme scheme;
}

abstract final class WesternRulerships {
  static const Map<TropicalZodiacSign, AstroBody> traditional = {
    TropicalZodiacSign.aries: AstroBody.mars,
    TropicalZodiacSign.taurus: AstroBody.venus,
    TropicalZodiacSign.gemini: AstroBody.mercury,
    TropicalZodiacSign.cancer: AstroBody.moon,
    TropicalZodiacSign.leo: AstroBody.sun,
    TropicalZodiacSign.virgo: AstroBody.mercury,
    TropicalZodiacSign.libra: AstroBody.venus,
    TropicalZodiacSign.scorpio: AstroBody.mars,
    TropicalZodiacSign.sagittarius: AstroBody.jupiter,
    TropicalZodiacSign.capricorn: AstroBody.saturn,
    TropicalZodiacSign.aquarius: AstroBody.saturn,
    TropicalZodiacSign.pisces: AstroBody.jupiter,
  };

  static const Map<TropicalZodiacSign, AstroBody> modern = {
    TropicalZodiacSign.aries: AstroBody.mars,
    TropicalZodiacSign.taurus: AstroBody.venus,
    TropicalZodiacSign.gemini: AstroBody.mercury,
    TropicalZodiacSign.cancer: AstroBody.moon,
    TropicalZodiacSign.leo: AstroBody.sun,
    TropicalZodiacSign.virgo: AstroBody.mercury,
    TropicalZodiacSign.libra: AstroBody.venus,
    TropicalZodiacSign.scorpio: AstroBody.pluto,
    TropicalZodiacSign.sagittarius: AstroBody.jupiter,
    TropicalZodiacSign.capricorn: AstroBody.saturn,
    TropicalZodiacSign.aquarius: AstroBody.uranus,
    TropicalZodiacSign.pisces: AstroBody.neptune,
  };

  static AstroBody rulerForSign(
    TropicalZodiacSign sign, {
    WesternRulershipScheme scheme = WesternRulershipScheme.modern,
  }) {
    final catalog = scheme == WesternRulershipScheme.traditional
        ? traditional
        : modern;
    final ruler = catalog[sign];
    if (ruler == null) {
      throw StateError('No ruler configured for $sign under $scheme.');
    }
    return ruler;
  }

  static Set<TropicalZodiacSign> signsRuledBy(
    AstroBody body, {
    WesternRulershipScheme scheme = WesternRulershipScheme.modern,
  }) {
    final catalog = scheme == WesternRulershipScheme.traditional
        ? traditional
        : modern;
    return Set.unmodifiable({
      for (final entry in catalog.entries)
        if (entry.value == body) entry.key,
    });
  }

  static WesternHouseRuler rulerForHouse(
    HouseCusps houses,
    int houseNumber, {
    WesternRulershipScheme scheme = WesternRulershipScheme.modern,
  }) {
    final cuspLongitude = houses.cusp(houseNumber);
    final signIndex = (cuspLongitude / 30.0).floor();
    final sign = TropicalZodiacSign.values[signIndex];
    return WesternHouseRuler(
      houseNumber: houseNumber,
      cuspSign: sign,
      ruler: rulerForSign(sign, scheme: scheme),
      scheme: scheme,
    );
  }

  static List<WesternHouseRuler> rulersForAllHouses(
    HouseCusps houses, {
    WesternRulershipScheme scheme = WesternRulershipScheme.modern,
  }) => List.unmodifiable([
        for (var house = 1; house <= 12; house++)
          rulerForHouse(houses, house, scheme: scheme),
      ]);
}
