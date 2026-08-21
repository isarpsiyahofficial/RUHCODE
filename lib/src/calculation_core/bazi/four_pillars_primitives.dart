import 'hidden_stems.dart';
import 'sexagenary_cycle.dart';

final class BaZiFourPillars {
  const BaZiFourPillars({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });

  final SexagenaryPillar year;
  final SexagenaryPillar month;
  final SexagenaryPillar day;
  final SexagenaryPillar hour;

  List<SexagenaryPillar> get orderedPillars =>
      List<SexagenaryPillar>.unmodifiable(<SexagenaryPillar>[
        year,
        month,
        day,
        hour,
      ]);

  /// Day Master (日主) is the Heavenly Stem of the already-verified Day Pillar.
  /// This primitive deliberately does not derive the Day Pillar from a date.
  HeavenlyStem get dayMaster => day.stem;
}

final class BaZiElementDistribution {
  BaZiElementDistribution._({
    required Map<WuXingElement, int> visible,
    required Map<WuXingElement, int> hiddenStemOccurrences,
  })  : visible = Map<WuXingElement, int>.unmodifiable(visible),
        hiddenStemOccurrences =
            Map<WuXingElement, int>.unmodifiable(hiddenStemOccurrences);

  /// Unweighted count of the 8 visible symbols: four stems + four branches.
  final Map<WuXingElement, int> visible;

  /// Unweighted occurrence count across canonical Hidden Stems.
  /// Kept separate because school-specific weighting must not be invented.
  final Map<WuXingElement, int> hiddenStemOccurrences;
}

final class BaZiPolarityDistribution {
  BaZiPolarityDistribution._(Map<YinYang, int> visible)
      : visible = Map<YinYang, int>.unmodifiable(visible);

  /// Unweighted count of Yin/Yang across the 8 visible pillar symbols.
  final Map<YinYang, int> visible;
}

abstract final class BaZiFourPillarsPrimitives {
  static BaZiElementDistribution elementDistribution(BaZiFourPillars pillars) {
    final visible = _zeroElementCounts();
    final hidden = _zeroElementCounts();

    for (final pillar in pillars.orderedPillars) {
      visible[pillar.stem.element] = visible[pillar.stem.element]! + 1;
      visible[pillar.branch.element] = visible[pillar.branch.element]! + 1;
      for (final hiddenStem in BaZiHiddenStems.of(pillar.branch)) {
        hidden[hiddenStem.element] = hidden[hiddenStem.element]! + 1;
      }
    }

    return BaZiElementDistribution._(
      visible: visible,
      hiddenStemOccurrences: hidden,
    );
  }

  static BaZiPolarityDistribution polarityDistribution(BaZiFourPillars pillars) {
    final counts = <YinYang, int>{YinYang.yang: 0, YinYang.yin: 0};
    for (final pillar in pillars.orderedPillars) {
      counts[pillar.stem.polarity] = counts[pillar.stem.polarity]! + 1;
      counts[pillar.branch.polarity] = counts[pillar.branch.polarity]! + 1;
    }
    return BaZiPolarityDistribution._(counts);
  }

  static Map<WuXingElement, int> _zeroElementCounts() =>
      <WuXingElement, int>{
        for (final element in WuXingElement.values) element: 0,
      };
}
