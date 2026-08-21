import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

void main() {
  test('canonical 60-cycle endpoints and wrap are stable', () {
    expect(SexagenaryCycle.at(0), const SexagenaryPillar(
      cycleIndex: 0,
      stem: HeavenlyStem.jia,
      branch: EarthlyBranch.zi,
    ));
    expect(SexagenaryCycle.at(59), const SexagenaryPillar(
      cycleIndex: 59,
      stem: HeavenlyStem.gui,
      branch: EarthlyBranch.hai,
    ));
    expect(SexagenaryCycle.at(60), SexagenaryCycle.at(0));
    expect(SexagenaryCycle.at(-1), SexagenaryCycle.at(59));
  });

  test('all 60 canonical pairs preserve Yin/Yang parity and are unique', () {
    final seen = <String>{};
    for (var index = 0; index < SexagenaryCycle.length; index++) {
      final pillar = SexagenaryCycle.at(index);
      expect(pillar.stem.polarity, pillar.branch.polarity);
      expect(seen.add('${pillar.stem.name}-${pillar.branch.name}'), isTrue);
      expect(SexagenaryCycle.indexOf(pillar.stem, pillar.branch), index);
    }
    expect(seen.length, 60);
  });

  test('known sequence positions are deterministic', () {
    expect(SexagenaryCycle.at(1).stem, HeavenlyStem.yi);
    expect(SexagenaryCycle.at(1).branch, EarthlyBranch.chou);
    expect(SexagenaryCycle.at(10).stem, HeavenlyStem.jia);
    expect(SexagenaryCycle.at(10).branch, EarthlyBranch.xu);
    expect(SexagenaryCycle.at(12).stem, HeavenlyStem.bing);
    expect(SexagenaryCycle.at(12).branch, EarthlyBranch.zi);
  });

  test('invalid parity pair is rejected instead of invented', () {
    expect(
      () => SexagenaryCycle.indexOf(HeavenlyStem.jia, EarthlyBranch.chou),
      throwsFormatException,
    );
  });

  test('five elements and polarity mappings remain explicit', () {
    expect(HeavenlyStem.jia.element, WuXingElement.wood);
    expect(HeavenlyStem.jia.polarity, YinYang.yang);
    expect(HeavenlyStem.gui.element, WuXingElement.water);
    expect(HeavenlyStem.gui.polarity, YinYang.yin);
    expect(EarthlyBranch.shen.element, WuXingElement.metal);
    expect(EarthlyBranch.shen.polarity, YinYang.yang);
    expect(EarthlyBranch.hai.element, WuXingElement.water);
    expect(EarthlyBranch.hai.polarity, YinYang.yin);
  });
}
