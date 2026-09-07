import 'bazi_four_pillars.dart';

enum BaziElement { wood, fire, earth, metal, water }

enum BaziPolarity { yang, yin }

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

extension BaziStemAttributes on BaziHeavenlyStem {
  BaziElement get element => switch (this) {
        BaziHeavenlyStem.jia || BaziHeavenlyStem.yi => BaziElement.wood,
        BaziHeavenlyStem.bing || BaziHeavenlyStem.ding => BaziElement.fire,
        BaziHeavenlyStem.wu || BaziHeavenlyStem.ji => BaziElement.earth,
        BaziHeavenlyStem.geng || BaziHeavenlyStem.xin => BaziElement.metal,
        BaziHeavenlyStem.ren || BaziHeavenlyStem.gui => BaziElement.water,
      };

  BaziPolarity get polarity => switch (this) {
        BaziHeavenlyStem.jia ||
        BaziHeavenlyStem.bing ||
        BaziHeavenlyStem.wu ||
        BaziHeavenlyStem.geng ||
        BaziHeavenlyStem.ren =>
          BaziPolarity.yang,
        _ => BaziPolarity.yin,
      };
}

/// RC-0149 Hidden Stems membership table.
///
/// Values are intentionally represented as sets. Sources agree on membership
/// but can differ in presentation/order for secondary/residual qi. No universal
/// percentage or ordering strength is inferred by this core.
abstract final class BaziHiddenStems {
  static const String sourceId = 'traditional-hidden-stems-membership';
  static const String version = 'membership-v1';

  static const Map<BaziEarthlyBranch, Set<BaziHeavenlyStem>> byBranch =
      <BaziEarthlyBranch, Set<BaziHeavenlyStem>>{
    BaziEarthlyBranch.zi: <BaziHeavenlyStem>{BaziHeavenlyStem.gui},
    BaziEarthlyBranch.chou: <BaziHeavenlyStem>{
      BaziHeavenlyStem.ji,
      BaziHeavenlyStem.gui,
      BaziHeavenlyStem.xin,
    },
    BaziEarthlyBranch.yin: <BaziHeavenlyStem>{
      BaziHeavenlyStem.jia,
      BaziHeavenlyStem.bing,
      BaziHeavenlyStem.wu,
    },
    BaziEarthlyBranch.mao: <BaziHeavenlyStem>{BaziHeavenlyStem.yi},
    BaziEarthlyBranch.chen: <BaziHeavenlyStem>{
      BaziHeavenlyStem.wu,
      BaziHeavenlyStem.yi,
      BaziHeavenlyStem.gui,
    },
    BaziEarthlyBranch.si: <BaziHeavenlyStem>{
      BaziHeavenlyStem.bing,
      BaziHeavenlyStem.wu,
      BaziHeavenlyStem.geng,
    },
    BaziEarthlyBranch.wu: <BaziHeavenlyStem>{
      BaziHeavenlyStem.ding,
      BaziHeavenlyStem.ji,
    },
    BaziEarthlyBranch.wei: <BaziHeavenlyStem>{
      BaziHeavenlyStem.ji,
      BaziHeavenlyStem.ding,
      BaziHeavenlyStem.yi,
    },
    BaziEarthlyBranch.shen: <BaziHeavenlyStem>{
      BaziHeavenlyStem.geng,
      BaziHeavenlyStem.ren,
      BaziHeavenlyStem.wu,
    },
    BaziEarthlyBranch.you: <BaziHeavenlyStem>{BaziHeavenlyStem.xin},
    BaziEarthlyBranch.xu: <BaziHeavenlyStem>{
      BaziHeavenlyStem.wu,
      BaziHeavenlyStem.xin,
      BaziHeavenlyStem.ding,
    },
    BaziEarthlyBranch.hai: <BaziHeavenlyStem>{
      BaziHeavenlyStem.ren,
      BaziHeavenlyStem.jia,
    },
  };
}

final class BaziElementDistribution {
  const BaziElementDistribution({
    required this.counts,
    required this.methodId,
    required this.hiddenStemsSourceId,
    required this.hiddenStemsVersion,
  });

  final Map<BaziElement, int> counts;
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
  final BaziHeavenlyStem stem;
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

  final BaziHeavenlyStem dayMaster;
  final BaziElementDistribution elementDistribution;
  final BaziYinYangBalance yinYangBalance;
  final List<BaziTenGodOccurrence> tenGodOccurrences;
}

/// RC-0150/0151 use an explicitly named structural occurrence method: the four
/// visible stems plus each Hidden Stem membership occurrence are counted once.
/// This is not a seasonal-strength score and does not imply qi percentages.
abstract final class BaziDerivedAnalysis {
  static const String occurrenceMethodId = 'visible-plus-hidden-occurrences-v1';

  static BaziDerivedAnalysisSnapshot calculate(BaziFourPillarsSnapshot chart) {
    final dayMaster = chart.day.stem; // RC-0152.
    final elementCounts = <BaziElement, int>{for (final e in BaziElement.values) e: 0};
    var yang = 0;
    var yin = 0;
    final tenGods = <BaziTenGodOccurrence>[];

    void add(BaziPillarKind kind, BaziHeavenlyStem stem, {required bool hidden}) {
      elementCounts[stem.element] = elementCounts[stem.element]! + 1;
      if (stem.polarity == BaziPolarity.yang) {
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
      final hidden = BaziHiddenStems.byBranch[pillar.branch];
      if (hidden == null || hidden.isEmpty) {
        throw StateError('Missing Hidden Stems membership for ${pillar.branch.name}');
      }
      for (final stem in hidden) {
        add(pillar.kind, stem, hidden: true);
      }
    }

    return BaziDerivedAnalysisSnapshot(
      dayMaster: dayMaster,
      elementDistribution: BaziElementDistribution(
        counts: Map.unmodifiable(elementCounts),
        methodId: occurrenceMethodId,
        hiddenStemsSourceId: BaziHiddenStems.sourceId,
        hiddenStemsVersion: BaziHiddenStems.version,
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
    required BaziHeavenlyStem dayMaster,
    required BaziHeavenlyStem other,
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

  static bool _generates(BaziElement a, BaziElement b) => switch (a) {
        BaziElement.wood => b == BaziElement.fire,
        BaziElement.fire => b == BaziElement.earth,
        BaziElement.earth => b == BaziElement.metal,
        BaziElement.metal => b == BaziElement.water,
        BaziElement.water => b == BaziElement.wood,
      };

  static bool _controls(BaziElement a, BaziElement b) => switch (a) {
        BaziElement.wood => b == BaziElement.earth,
        BaziElement.fire => b == BaziElement.metal,
        BaziElement.earth => b == BaziElement.water,
        BaziElement.metal => b == BaziElement.wood,
        BaziElement.water => b == BaziElement.fire,
      };
}
