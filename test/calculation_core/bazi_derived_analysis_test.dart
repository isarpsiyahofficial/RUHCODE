import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_derived_analysis.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';

BaziPillar _pillar(BaziPillarKind kind, int cycle) => BaziPillar(
      kind: kind,
      stem: BaziFourPillarsEngine.stems[cycle % 10],
      branch: BaziFourPillarsEngine.branches[cycle % 12],
      sexagenaryCycleIndex: cycle,
    );

BaziFourPillarsSnapshot _chart() => BaziFourPillarsSnapshot(
      birthInstantUtc: DateTime.utc(2026, 1, 1),
      year: _pillar(BaziPillarKind.year, 40), // Jia-Chen.
      month: _pillar(BaziPillarKind.month, 2), // Bing-Yin.
      day: _pillar(BaziPillarKind.day, 0), // Jia-Zi => Jia Day Master.
      hour: _pillar(BaziPillarKind.hour, 59), // Gui-Hai.
      sourceId: 'fixture',
      version: 'v1',
      conventionId: 'fixture',
    );

void main() {
  test('RC-0149 maps all twelve Earthly Branches to Hidden Stem membership', () {
    expect(BaziHiddenStems.byBranch.keys.toSet(), BaziEarthlyBranch.values.toSet());
    expect(BaziHiddenStems.byBranch[BaziEarthlyBranch.zi], {BaziHeavenlyStem.gui});
    expect(
      BaziHiddenStems.byBranch[BaziEarthlyBranch.yin],
      {BaziHeavenlyStem.jia, BaziHeavenlyStem.bing, BaziHeavenlyStem.wu},
    );
    expect(
      BaziHiddenStems.byBranch[BaziEarthlyBranch.si],
      {BaziHeavenlyStem.bing, BaziHeavenlyStem.wu, BaziHeavenlyStem.geng},
    );
  });

  test('RC-0150 calculates explicit Five Elements occurrence distribution', () {
    final result = BaziDerivedAnalysis.calculate(_chart());
    expect(result.elementDistribution.methodId, 'visible-plus-hidden-occurrences-v1');
    expect(result.elementDistribution.totalOccurrences, greaterThan(4));
    expect(result.elementDistribution.counts.keys.toSet(), BaziElement.values.toSet());
    expect(result.elementDistribution.hiddenStemsSourceId, isNotEmpty);
    expect(result.elementDistribution.hiddenStemsVersion, isNotEmpty);
  });

  test('RC-0151 calculates Yin Yang balance over the same explicit occurrence method', () {
    final result = BaziDerivedAnalysis.calculate(_chart());
    expect(result.yinYangBalance.methodId, result.elementDistribution.methodId);
    expect(result.yinYangBalance.totalOccurrences, result.elementDistribution.totalOccurrences);
    expect(result.yinYangBalance.yang, greaterThan(0));
    expect(result.yinYangBalance.yin, greaterThan(0));
  });

  test('RC-0152 identifies Day Master as the Day Pillar Heavenly Stem', () {
    final result = BaziDerivedAnalysis.calculate(_chart());
    expect(result.dayMaster, BaziHeavenlyStem.jia);
  });

  test('RC-0153 maps all ten Day-Master relationships for Jia', () {
    const expected = <BaziHeavenlyStem, BaziTenGod>{
      BaziHeavenlyStem.jia: BaziTenGod.friend,
      BaziHeavenlyStem.yi: BaziTenGod.robWealth,
      BaziHeavenlyStem.bing: BaziTenGod.eatingGod,
      BaziHeavenlyStem.ding: BaziTenGod.hurtingOfficer,
      BaziHeavenlyStem.wu: BaziTenGod.indirectWealth,
      BaziHeavenlyStem.ji: BaziTenGod.directWealth,
      BaziHeavenlyStem.geng: BaziTenGod.sevenKillings,
      BaziHeavenlyStem.xin: BaziTenGod.directOfficer,
      BaziHeavenlyStem.ren: BaziTenGod.indirectResource,
      BaziHeavenlyStem.gui: BaziTenGod.directResource,
    };
    for (final entry in expected.entries) {
      expect(
        BaziDerivedAnalysis.tenGodFor(dayMaster: BaziHeavenlyStem.jia, other: entry.key),
        entry.value,
        reason: entry.key.name,
      );
    }
  });

  test('derived analysis retains visible and Hidden Stem Ten God evidence separately', () {
    final result = BaziDerivedAnalysis.calculate(_chart());
    expect(result.tenGodOccurrences.where((e) => !e.hidden), hasLength(4));
    expect(result.tenGodOccurrences.any((e) => e.hidden), isTrue);
    expect(
      result.tenGodOccurrences.any(
        (e) => e.pillarKind == BaziPillarKind.day && !e.hidden && e.tenGod == BaziTenGod.friend,
      ),
      isTrue,
    );
  });
}
