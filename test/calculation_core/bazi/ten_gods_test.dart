import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';
import 'package:ruh_code/src/calculation_core/bazi/ten_gods.dart';

void main() {
  test('Jia Day Master maps all ten Heavenly Stems to the ten canonical gods', () {
    const expected = <HeavenlyStem, TenGod>{
      HeavenlyStem.jia: TenGod.friend,
      HeavenlyStem.yi: TenGod.robWealth,
      HeavenlyStem.bing: TenGod.eatingGod,
      HeavenlyStem.ding: TenGod.hurtingOfficer,
      HeavenlyStem.wu: TenGod.indirectWealth,
      HeavenlyStem.ji: TenGod.directWealth,
      HeavenlyStem.geng: TenGod.sevenKillings,
      HeavenlyStem.xin: TenGod.directOfficer,
      HeavenlyStem.ren: TenGod.indirectResource,
      HeavenlyStem.gui: TenGod.directResource,
    };

    for (final entry in expected.entries) {
      expect(
        BaZiTenGods.assess(dayMaster: HeavenlyStem.jia, target: entry.key).tenGod,
        entry.value,
        reason: 'Jia vs ${entry.key.name}',
      );
    }
    expect(expected.values.toSet(), TenGod.values.toSet());
  });

  test('Yin Day Master reverses same/opposite-polarity Ten Gods correctly', () {
    const expected = <HeavenlyStem, TenGod>{
      HeavenlyStem.jia: TenGod.robWealth,
      HeavenlyStem.yi: TenGod.friend,
      HeavenlyStem.bing: TenGod.hurtingOfficer,
      HeavenlyStem.ding: TenGod.eatingGod,
      HeavenlyStem.wu: TenGod.directWealth,
      HeavenlyStem.ji: TenGod.indirectWealth,
      HeavenlyStem.geng: TenGod.directOfficer,
      HeavenlyStem.xin: TenGod.sevenKillings,
      HeavenlyStem.ren: TenGod.directResource,
      HeavenlyStem.gui: TenGod.indirectResource,
    };

    for (final entry in expected.entries) {
      expect(
        BaZiTenGods.assess(dayMaster: HeavenlyStem.yi, target: entry.key).tenGod,
        entry.value,
        reason: 'Yi vs ${entry.key.name}',
      );
    }
  });

  test('Hidden Stems are classified in canonical main-qi-first order', () {
    final assessments = BaZiTenGods.assessHiddenStems(
      dayMaster: HeavenlyStem.jia,
      branch: EarthlyBranch.chou,
    );

    expect(
      assessments.map((item) => item.target).toList(),
      <HeavenlyStem>[HeavenlyStem.ji, HeavenlyStem.gui, HeavenlyStem.xin],
    );
    expect(
      assessments.map((item) => item.tenGod).toList(),
      <TenGod>[TenGod.directWealth, TenGod.directResource, TenGod.directOfficer],
    );
    expect(
      () => assessments.add(
        BaZiTenGods.assess(
          dayMaster: HeavenlyStem.jia,
          target: HeavenlyStem.jia,
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test('Ten Gods primitive has complete coverage for every Day Master and target', () {
    for (final dayMaster in HeavenlyStem.values) {
      final results = <TenGod>{};
      for (final target in HeavenlyStem.values) {
        final result = BaZiTenGods.assess(dayMaster: dayMaster, target: target);
        expect(result.dayMaster, dayMaster);
        expect(result.target, target);
        results.add(result.tenGod);
      }
      expect(
        results,
        TenGod.values.toSet(),
        reason: '${dayMaster.name} must produce all ten relationship identities',
      );
    }
  });
}
