import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_derived_analysis.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';
import 'package:ruh_code/src/calculation_core/bazi/hidden_stems.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

BaziPillar _pillar(BaziPillarKind kind, int cycle) {
  final canonical = SexagenaryCycle.at(cycle);
  return BaziPillar(
    kind: kind,
    stem: canonical.stem,
    branch: canonical.branch,
    sexagenaryCycleIndex: canonical.cycleIndex,
  );
}

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
  test('RC-0149 reuses canonical Hidden Stems for all twelve branches', () {
    BaZiHiddenStems.assertComplete();
    expect(EarthlyBranch.values, hasLength(12));
    expect(BaZiHiddenStems.of(EarthlyBranch.zi), [HeavenlyStem.gui]);
    expect(
      BaZiHiddenStems.of(EarthlyBranch.yin).toSet(),
      {HeavenlyStem.jia, HeavenlyStem.bing, HeavenlyStem.wu},
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.si).toSet(),
      {HeavenlyStem.bing, HeavenlyStem.wu, HeavenlyStem.geng},
    );
  });

  test('RC-0150 calculates explicit Five Elements occurrence distribution', () {
    final result = BaziDerivedAnalysis.calculate(_chart());
    expect(result.elementDistribution.methodId, 'visible-plus-hidden-occurrences-v1');
    expect(result.elementDistribution.totalOccurrences, greaterThan(4));
    expect(result.elementDistribution.counts.keys.toSet(), WuXingElement.values.toSet());
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
    expect(result.dayMaster, HeavenlyStem.jia);
  });

  test('RC-0153 maps all ten Day-Master relationships for Jia', () {
    const expected = <HeavenlyStem, BaziTenGod>{
      HeavenlyStem.jia: BaziTenGod.friend,
      HeavenlyStem.yi: BaziTenGod.robWealth,
      HeavenlyStem.bing: BaziTenGod.eatingGod,
      HeavenlyStem.ding: BaziTenGod.hurtingOfficer,
      HeavenlyStem.wu: BaziTenGod.indirectWealth,
      HeavenlyStem.ji: BaziTenGod.directWealth,
      HeavenlyStem.geng: BaziTenGod.sevenKillings,
      HeavenlyStem.xin: BaziTenGod.directOfficer,
      HeavenlyStem.ren: BaziTenGod.indirectResource,
      HeavenlyStem.gui: BaziTenGod.directResource,
    };
    for (final entry in expected.entries) {
      expect(
        BaziDerivedAnalysis.tenGodFor(dayMaster: HeavenlyStem.jia, other: entry.key),
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
