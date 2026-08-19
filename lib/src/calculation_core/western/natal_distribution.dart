import '../ephemeris/ephemeris.dart';
import 'natal_placements.dart';

enum WesternElement { fire, earth, air, water }
enum WesternModality { cardinal, fixed, mutable }

final class PlacementWeightPolicy {
  PlacementWeightPolicy({Map<AstroBody, double>? weights})
      : weights = Map.unmodifiable(
          weights ?? {for (final body in AstroBody.values) body: 1.0},
        ) {
    validate();
  }

  final Map<AstroBody, double> weights;

  void validate() {
    for (final body in AstroBody.values) {
      final weight = weights[body];
      if (weight == null || !weight.isFinite || weight < 0) {
        throw StateError('Every AstroBody requires a finite non-negative distribution weight.');
      }
    }
    if (weights.values.every((weight) => weight == 0)) {
      throw StateError('Distribution weight policy cannot be all zero.');
    }
  }

  double forBody(AstroBody body) => weights[body]!;
}

final class WesternNatalDistribution {
  WesternNatalDistribution({
    required Map<WesternElement, double> elementWeights,
    required Map<WesternModality, double> modalityWeights,
  })  : elementWeights = Map.unmodifiable(elementWeights),
        modalityWeights = Map.unmodifiable(modalityWeights);

  final Map<WesternElement, double> elementWeights;
  final Map<WesternModality, double> modalityWeights;

  double get totalElementWeight => elementWeights.values.fold(0, (a, b) => a + b);
  double get totalModalityWeight => modalityWeights.values.fold(0, (a, b) => a + b);

  double elementPercent(WesternElement element) =>
      totalElementWeight == 0 ? 0 : (elementWeights[element]! / totalElementWeight) * 100;

  double modalityPercent(WesternModality modality) =>
      totalModalityWeight == 0 ? 0 : (modalityWeights[modality]! / totalModalityWeight) * 100;
}

abstract final class WesternNatalDistributionEngine {
  static WesternNatalDistribution build({
    required NatalPlacementSet placements,
    PlacementWeightPolicy? weightPolicy,
  }) {
    final policy = weightPolicy ?? PlacementWeightPolicy();
    policy.validate();
    final elements = {for (final e in WesternElement.values) e: 0.0};
    final modalities = {for (final m in WesternModality.values) m: 0.0};

    for (final placement in placements.placements) {
      final weight = policy.forBody(placement.body);
      if (weight == 0) continue;
      elements[_elementFor(placement.sign)] = elements[_elementFor(placement.sign)]! + weight;
      modalities[_modalityFor(placement.sign)] = modalities[_modalityFor(placement.sign)]! + weight;
    }

    return WesternNatalDistribution(
      elementWeights: elements,
      modalityWeights: modalities,
    );
  }

  static WesternElement _elementFor(TropicalZodiacSign sign) {
    return switch (sign) {
      TropicalZodiacSign.aries || TropicalZodiacSign.leo || TropicalZodiacSign.sagittarius => WesternElement.fire,
      TropicalZodiacSign.taurus || TropicalZodiacSign.virgo || TropicalZodiacSign.capricorn => WesternElement.earth,
      TropicalZodiacSign.gemini || TropicalZodiacSign.libra || TropicalZodiacSign.aquarius => WesternElement.air,
      TropicalZodiacSign.cancer || TropicalZodiacSign.scorpio || TropicalZodiacSign.pisces => WesternElement.water,
    };
  }

  static WesternModality _modalityFor(TropicalZodiacSign sign) {
    return switch (sign) {
      TropicalZodiacSign.aries || TropicalZodiacSign.cancer || TropicalZodiacSign.libra || TropicalZodiacSign.capricorn => WesternModality.cardinal,
      TropicalZodiacSign.taurus || TropicalZodiacSign.leo || TropicalZodiacSign.scorpio || TropicalZodiacSign.aquarius => WesternModality.fixed,
      TropicalZodiacSign.gemini || TropicalZodiacSign.virgo || TropicalZodiacSign.sagittarius || TropicalZodiacSign.pisces => WesternModality.mutable,
    };
  }
}
