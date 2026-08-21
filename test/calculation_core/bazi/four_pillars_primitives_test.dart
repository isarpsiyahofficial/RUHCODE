import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/four_pillars_primitives.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

void main() {
  const pillars = BaZiFourPillars(
    year: SexagenaryPillar(
      cycleIndex: 0,
      stem: HeavenlyStem.jia,
      branch: EarthlyBranch.zi,
    ),
    month: SexagenaryPillar(
      cycleIndex: 5,
      stem: HeavenlyStem.ji,
      branch: EarthlyBranch.si,
    ),
    day: SexagenaryPillar(
      cycleIndex: 14,
      stem: HeavenlyStem.wu,
      branch: EarthlyBranch.yin,
    ),
    hour: SexagenaryPillar(
      cycleIndex: 29,
      stem: HeavenlyStem.gui,
      branch: EarthlyBranch.si,
    ),
  );

  test('Day Master is the Heavenly Stem of the verified Day Pillar', () {
    expect(pillars.dayMaster, HeavenlyStem.wu);
  });

  test('visible Five Elements distribution counts exactly eight visible symbols', () {
    final distribution =
        BaZiFourPillarsPrimitives.elementDistribution(pillars).visible;

    expect(distribution[WuXingElement.wood], 2);
    expect(distribution[WuXingElement.fire], 2);
    expect(distribution[WuXingElement.earth], 2);
    expect(distribution[WuXingElement.metal], 0);
    expect(distribution[WuXingElement.water], 2);
    expect(distribution.values.fold<int>(0, (a, b) => a + b), 8);
  });

  test('Hidden Stem occurrences stay separate from visible Five Elements counts', () {
    final distribution =
        BaZiFourPillarsPrimitives.elementDistribution(pillars);

    expect(distribution.hiddenStemOccurrences[WuXingElement.wood], 1);
    expect(distribution.hiddenStemOccurrences[WuXingElement.fire], 3);
    expect(distribution.hiddenStemOccurrences[WuXingElement.earth], 3);
    expect(distribution.hiddenStemOccurrences[WuXingElement.metal], 2);
    expect(distribution.hiddenStemOccurrences[WuXingElement.water], 2);
    expect(distribution.hiddenStemOccurrences.values.fold<int>(0, (a, b) => a + b), 11);
  });

  test('Yin Yang distribution counts exactly eight visible symbols', () {
    final distribution =
        BaZiFourPillarsPrimitives.polarityDistribution(pillars).visible;

    expect(distribution[YinYang.yang], 4);
    expect(distribution[YinYang.yin], 4);
    expect(distribution.values.fold<int>(0, (a, b) => a + b), 8);
  });

  test('distribution maps are immutable', () {
    final elements = BaZiFourPillarsPrimitives.elementDistribution(pillars);
    final polarity = BaZiFourPillarsPrimitives.polarityDistribution(pillars);

    expect(
      () => elements.visible[WuXingElement.wood] = 99,
      throwsUnsupportedError,
    );
    expect(
      () => elements.hiddenStemOccurrences[WuXingElement.wood] = 99,
      throwsUnsupportedError,
    );
    expect(
      () => polarity.visible[YinYang.yang] = 99,
      throwsUnsupportedError,
    );
  });
}
