import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

enum EssentialDignity {
  domicile,
  exaltation,
  detriment,
  fall,
}

final class EssentialDignityAssessment {
  EssentialDignityAssessment({
    required this.body,
    required this.sign,
    required Set<EssentialDignity> dignities,
  }) : dignities = Set<EssentialDignity>.unmodifiable(dignities);

  final AstroBody body;
  final TropicalZodiacSign sign;
  final Set<EssentialDignity> dignities;

  bool get hasClassicalDignity => dignities.isNotEmpty;
  bool has(EssentialDignity dignity) => dignities.contains(dignity);
}

final class EssentialDignitySet {
  EssentialDignitySet({required List<EssentialDignityAssessment> assessments})
      : assessments = List<EssentialDignityAssessment>.unmodifiable(assessments);

  final List<EssentialDignityAssessment> assessments;

  EssentialDignityAssessment forBody(AstroBody body) =>
      assessments.singleWhere((item) => item.body == body);
}

abstract final class WesternEssentialDignities {
  static const Map<AstroBody, Set<TropicalZodiacSign>> _domiciles = {
    AstroBody.sun: {TropicalZodiacSign.leo},
    AstroBody.moon: {TropicalZodiacSign.cancer},
    AstroBody.mercury: {TropicalZodiacSign.gemini, TropicalZodiacSign.virgo},
    AstroBody.venus: {TropicalZodiacSign.taurus, TropicalZodiacSign.libra},
    AstroBody.mars: {TropicalZodiacSign.aries, TropicalZodiacSign.scorpio},
    AstroBody.jupiter: {TropicalZodiacSign.sagittarius, TropicalZodiacSign.pisces},
    AstroBody.saturn: {TropicalZodiacSign.capricorn, TropicalZodiacSign.aquarius},
  };

  static const Map<AstroBody, TropicalZodiacSign> _exaltations = {
    AstroBody.sun: TropicalZodiacSign.aries,
    AstroBody.moon: TropicalZodiacSign.taurus,
    AstroBody.mercury: TropicalZodiacSign.virgo,
    AstroBody.venus: TropicalZodiacSign.pisces,
    AstroBody.mars: TropicalZodiacSign.capricorn,
    AstroBody.jupiter: TropicalZodiacSign.cancer,
    AstroBody.saturn: TropicalZodiacSign.libra,
  };

  static EssentialDignitySet build({required NatalPlacementSet placements}) {
    final assessments = placements.placements
        .map(
          (placement) => EssentialDignityAssessment(
            body: placement.body,
            sign: placement.sign,
            dignities: _for(placement.body, placement.sign),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.body.index.compareTo(b.body.index));
    return EssentialDignitySet(assessments: assessments);
  }

  static Set<TropicalZodiacSign> domicilesForBody(AstroBody body) =>
      Set<TropicalZodiacSign>.unmodifiable(
        _domiciles[body] ?? const <TropicalZodiacSign>{},
      );

  static Set<AstroBody> rulersOfSign(TropicalZodiacSign sign) {
    final rulers = _domiciles.entries
        .where((entry) => entry.value.contains(sign))
        .map((entry) => entry.key)
        .toSet();
    return Set<AstroBody>.unmodifiable(rulers);
  }

  static AstroBody? classicalRulerOfSign(TropicalZodiacSign sign) {
    final rulers = rulersOfSign(sign);
    if (rulers.isEmpty) {
      return null;
    }
    if (rulers.length != 1) {
      throw StateError('Classical rulership table is ambiguous for ${sign.name}.');
    }
    return rulers.single;
  }

  static Set<EssentialDignity> _for(AstroBody body, TropicalZodiacSign sign) {
    final domiciles = _domiciles[body];
    final exaltation = _exaltations[body];
    if (domiciles == null && exaltation == null) {
      return const <EssentialDignity>{};
    }

    final result = <EssentialDignity>{};
    if (domiciles?.contains(sign) ?? false) {
      result.add(EssentialDignity.domicile);
    }
    if (exaltation == sign) {
      result.add(EssentialDignity.exaltation);
    }
    if (domiciles?.any((domicile) => _opposite(domicile) == sign) ?? false) {
      result.add(EssentialDignity.detriment);
    }
    if (exaltation != null && _opposite(exaltation) == sign) {
      result.add(EssentialDignity.fall);
    }
    return result;
  }

  static TropicalZodiacSign _opposite(TropicalZodiacSign sign) =>
      TropicalZodiacSign.values[(sign.index + 6) % 12];
}
