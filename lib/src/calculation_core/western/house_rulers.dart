import '../ephemeris/ephemeris.dart';
import 'equal_house_systems.dart';
import 'natal_placements.dart';

/// Classical tropical rulership for one natal house cusp.
///
/// The ruler is derived from the zodiac sign containing the exact house cusp,
/// not from a planet placement. Classical rulers are intentionally used here
/// so the result remains deterministic and does not silently change when
/// modern co-rulers are introduced elsewhere in the product.
final class HouseRuler {
  const HouseRuler({
    required this.houseNumber,
    required this.cuspLongitudeDegrees,
    required this.cuspSign,
    required this.ruler,
  });

  final int houseNumber;
  final double cuspLongitudeDegrees;
  final TropicalZodiacSign cuspSign;
  final AstroBody ruler;
}

final class HouseRulerSet {
  HouseRulerSet(List<HouseRuler> rulers)
      : rulers = List<HouseRuler>.unmodifiable(rulers) {
    if (rulers.length != 12) {
      throw StateError('A natal chart must expose exactly 12 house rulers.');
    }
    final houseNumbers = rulers.map((item) => item.houseNumber).toSet();
    if (houseNumbers.length != 12 ||
        !List<int>.generate(12, (index) => index + 1)
            .every(houseNumbers.contains)) {
      throw StateError('House rulers must cover houses 1 through 12 exactly once.');
    }
  }

  final List<HouseRuler> rulers;

  HouseRuler forHouse(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw RangeError.range(houseNumber, 1, 12, 'houseNumber');
    }
    return rulers.singleWhere((item) => item.houseNumber == houseNumber);
  }
}

abstract final class WesternHouseRulers {
  static HouseRulerSet build({required HouseCusps houses}) {
    return HouseRulerSet(
      List<HouseRuler>.generate(12, (index) {
        final houseNumber = index + 1;
        final cusp = houses.cusp(houseNumber);
        final sign = TropicalZodiacSign.values[(cusp / 30.0).floor()];
        return HouseRuler(
          houseNumber: houseNumber,
          cuspLongitudeDegrees: cusp,
          cuspSign: sign,
          ruler: classicalRulerFor(sign),
        );
      }, growable: false),
    );
  }

  static AstroBody classicalRulerFor(TropicalZodiacSign sign) {
    return switch (sign) {
      TropicalZodiacSign.aries => AstroBody.mars,
      TropicalZodiacSign.taurus => AstroBody.venus,
      TropicalZodiacSign.gemini => AstroBody.mercury,
      TropicalZodiacSign.cancer => AstroBody.moon,
      TropicalZodiacSign.leo => AstroBody.sun,
      TropicalZodiacSign.virgo => AstroBody.mercury,
      TropicalZodiacSign.libra => AstroBody.venus,
      TropicalZodiacSign.scorpio => AstroBody.mars,
      TropicalZodiacSign.sagittarius => AstroBody.jupiter,
      TropicalZodiacSign.capricorn => AstroBody.saturn,
      TropicalZodiacSign.aquarius => AstroBody.saturn,
      TropicalZodiacSign.pisces => AstroBody.jupiter,
    };
  }
}
