import 'bazi_four_pillars.dart';
import 'hidden_stems.dart';
import 'sexagenary_cycle.dart';

enum BaziTenGod {
  friend,
  robWealth,
  eatingGod,
  hurtingOfficer,
  indirectWealth,
  directWealth,
  sevenKillings,
  directOfficer,
  indirectResource,
  directResource,
}

final class BaziElementDistribution {
  const BaziElementDistribution({
    required this.counts,
    required this.methodId,
    required this.hiddenStemsSourceId,
    required this.hiddenStemsVersion,
  });

  final Map<WuXingElement, int> counts;
  final String methodId;
  final String hiddenStemsSourceId;
  final String hiddenStemsVersion;

  int get totalOccurrences => counts.values.fold(0, (a, b) => a + b);
}

final class BaziYinYangBalance {
  const BaziYinYangBalance({required this.yang, required this.yin, required this.methodId});

  final int yang;
  final int yin;
  final String methodId;

  int get totalOccurrences => yang + yin;
}

final class BaziTenGodOccurrence {
  const BaziTenGodOccurrence({
    required this.pillarKind,
    required this.stem,
    required this.tenGod,
    required this.hidden,
  });

  final BaziPillarKind pillarKind;
  final HeavenlyStem stem;
  final BaziTenGod tenGod;
  final bool hidden;
}

final class BaziDerivedAnalysisSnapshot {
  const BaziDerivedAnalysisSnapshot({
    required this.dayMaster,
    required this.elementDistribution,
    required this.yinYangBalance,
    required this.tenGodOccurrences,
  });

  final HeavenlyStem dayMaster;
  final BaziElementDistribution elementDistribution;
  final BaziYinYangBalance yinYangBalance;
  final List<BaziTenGodOccurrence> tenGodOccurrences;
}

/// RC-0149..RC-0153 derived BaZi calculation core.
///
/// Hidden Stems reuse [BaZiHiddenStems], the repository's canonical primitive.
/// RC-0150/0151 use an explicitly named structural occurrence method: the four
/// visible stems plus each Hidden Stem membership occurrence are counted once.
/// This is not a seasonal-strength score and does not imply qi percentages.
abstract final class BaziDerivedAnalysis {
  static const String occurrenceMethodId = 'visible-plus-hidden-occurrences-v1';
  static const String hiddenStemsSourceId = 'canonical-bazi-hidden-stems';
  static const String hiddenStemsVersion = 'repository-v1';

  static BaziDerivedAnalysisSnapshot calculate(BaziFourPillarsSnapshot chart) {
    BaZiHiddenStems.assertComplete();
    final dayMaster = chart.day.stem; // RC-0152.
    final elementCounts = <WuXingElement, int>{
      for (final element in WuXingElement.values) element: 0,
    };
    var yang = 0;
    var yin = 0;
    final tenGods = <BaziTenGodOccurrence>[];

    void add(BaziPillarKind kind, HeavenlyStem stem, {required bool hidden}) {
      elementCounts[stem.element] = elementCounts[stem.element]! + 1;
      if (stem.polarity == YinYang.yang) {
        yang += 1;
      } else {
        yin += 1;
      }
      tenGods.add(BaziTenGodOccurrence(
        pillarKind: kind,
        stem: stem,
        tenGod: tenGodFor(dayMaster: dayMaster, other: stem),
        hidden: hidden,
      ));
    }

    for (final pillar in chart.pillars) {
      add(pillar.kind, pillar.stem, hidden: false);
      for (final stem in BaZiHiddenStems.of(pillar.branch)) {
        add(pillar.kind, stem, hidden: true);
      }
    }

    return BaziDerivedAnalysisSnapshot(
      dayMaster: dayMaster,
      elementDistribution: BaziElementDistribution(
        counts: Map.unmodifiable(elementCounts),
        methodId: occurrenceMethodId,
        hiddenStemsSourceId: hiddenStemsSourceId,
        hiddenStemsVersion: hiddenStemsVersion,
      ),
      yinYangBalance: BaziYinYangBalance(
        yang: yang,
        yin: yin,
        methodId: occurrenceMethodId,
      ),
      tenGodOccurrences: List.unmodifiable(tenGods),
    );
  }

  /// RC-0153 Ten Gods classification relative to the Day Master.
  static BaziTenGod tenGodFor({
    required HeavenlyStem dayMaster,
    required HeavenlyStem other,
  }) {
    final samePolarity = dayMaster.polarity == other.polarity;
    final self = dayMaster.element;
    final target = other.element;

    if (self == target) {
      return samePolarity ? BaziTenGod.friend : BaziTenGod.robWealth;
    }
    if (_generates(self, target)) {
      return samePolarity ? BaziTenGod.eatingGod : BaziTenGod.hurtingOfficer;
    }
    if (_controls(self, target)) {
      return samePolarity ? BaziTenGod.indirectWealth : BaziTenGod.directWealth;
    }
    if (_controls(target, self)) {
      return samePolarity ? BaziTenGod.sevenKillings : BaziTenGod.directOfficer;
    }
    if (_generates(target, self)) {
      return samePolarity ? BaziTenGod.indirectResource : BaziTenGod.directResource;
    }
    throw StateError('Unreachable Five Elements relationship');
  }

  static bool _generates(WuXingElement a, WuXingElement b) => switch (a) {
        WuXingElement.wood => b == WuXingElement.fire,
        WuXingElement.fire => b == WuXingElement.earth,
        WuXingElement.earth => b == WuXingElement.metal,
        WuXingElement.metal => b == WuXingElement.water,
        WuXingElement.water => b == WuXingElement.wood,
      };

  static bool _controls(WuXingElement a, WuXingElement b) => switch (a) {
        WuXingElement.wood => b == WuXingElement.earth,
        WuXingElement.fire => b == WuXingElement.metal,
        WuXingElement.earth => b == WuXingElement.water,
        WuXingElement.metal => b == WuXingElement.wood,
        WuXingElement.water => b == WuXingElement.fire,
      };
}
