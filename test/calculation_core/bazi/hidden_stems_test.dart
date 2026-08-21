import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/hidden_stems.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

void main() {
  test('all twelve branches have a non-empty unique hidden-stem mapping', () {
    BaZiHiddenStems.assertComplete();
    for (final branch in EarthlyBranch.values) {
      final stems = BaZiHiddenStems.of(branch);
      expect(stems, isNotEmpty);
      expect(stems.toSet().length, stems.length);
    }
  });

  test('single-stem branches preserve their canonical main qi', () {
    expect(BaZiHiddenStems.of(EarthlyBranch.zi), <HeavenlyStem>[HeavenlyStem.gui]);
    expect(BaZiHiddenStems.of(EarthlyBranch.mao), <HeavenlyStem>[HeavenlyStem.yi]);
    expect(BaZiHiddenStems.of(EarthlyBranch.you), <HeavenlyStem>[HeavenlyStem.xin]);
  });

  test('multi-stem branches preserve canonical ordered stems', () {
    expect(
      BaZiHiddenStems.of(EarthlyBranch.chou),
      <HeavenlyStem>[HeavenlyStem.ji, HeavenlyStem.gui, HeavenlyStem.xin],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.yin),
      <HeavenlyStem>[HeavenlyStem.jia, HeavenlyStem.bing, HeavenlyStem.wu],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.chen),
      <HeavenlyStem>[HeavenlyStem.wu, HeavenlyStem.yi, HeavenlyStem.gui],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.si),
      <HeavenlyStem>[HeavenlyStem.bing, HeavenlyStem.wu, HeavenlyStem.geng],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.wei),
      <HeavenlyStem>[HeavenlyStem.ji, HeavenlyStem.ding, HeavenlyStem.yi],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.shen),
      <HeavenlyStem>[HeavenlyStem.geng, HeavenlyStem.ren, HeavenlyStem.wu],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.xu),
      <HeavenlyStem>[HeavenlyStem.wu, HeavenlyStem.xin, HeavenlyStem.ding],
    );
    expect(
      BaZiHiddenStems.of(EarthlyBranch.hai),
      <HeavenlyStem>[HeavenlyStem.ren, HeavenlyStem.jia],
    );
  });

  test('mainQi always returns the first ordered hidden stem', () {
    for (final branch in EarthlyBranch.values) {
      expect(BaZiHiddenStems.mainQi(branch), BaZiHiddenStems.of(branch).first);
    }
  });

  test('returned lists are immutable', () {
    final stems = BaZiHiddenStems.of(EarthlyBranch.chou);
    expect(() => stems.add(HeavenlyStem.jia), throwsUnsupportedError);
  });
}
