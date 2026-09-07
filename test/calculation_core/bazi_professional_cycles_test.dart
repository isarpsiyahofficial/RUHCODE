import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_derived_analysis.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_professional_cycles.dart';
import 'package:ruh_code/src/calculation_core/bazi/sexagenary_cycle.dart';

final class _FourPillarsProvider implements BaziFourPillarsProvider {
  @override
  BaziFourPillarsResolution resolve({required DateTime birthInstantUtc}) =>
      BaziFourPillarsResolution(
        yearCycleIndex: 0,
        monthCycleIndex: 13,
        dayCycleIndex: 24,
        hourCycleIndex: 35,
        sourceId: 'fixture-four-pillars',
        version: '1',
        conventionId: 'fixture',
      );
}

final class _DaYunProvider implements DaYunConventionProvider {
  const _DaYunProvider(this.direction, this.startAgeYears);
  final DaYunDirection direction;
  final double startAgeYears;

  @override
  DaYunConventionResolution resolve({required BaziFourPillarsSnapshot natal}) =>
      DaYunConventionResolution(
        direction: direction,
        startAgeYears: startAgeYears,
        sourceId: 'fixture-dayun',
        version: '1',
        conventionId: 'fixture-direction-start-age',
      );
}

final class _PeriodProvider implements BaziPeriodPillarProvider {
  @override
  BaziPeriodPillarResolution resolveYear({required DateTime instantUtc}) =>
      BaziPeriodPillarResolution(
        cycleIndex: 40,
        sourceId: 'fixture-year',
        version: '1',
        conventionId: 'fixture-solar-year',
      );

  @override
  BaziPeriodPillarResolution resolveMonth({required DateTime instantUtc}) =>
      BaziPeriodPillarResolution(
        cycleIndex: 41,
        sourceId: 'fixture-month',
        version: '1',
        conventionId: 'fixture-solar-month',
      );
}

void main() {
  late BaziFourPillarsSnapshot natal;
  setUp(() {
    natal = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(1990, 1, 1, 12),
      provider: _FourPillarsProvider(),
    );
  });

  test('RC-0154 structural element balance scores all five elements and normalizes shares', () {
    final result = BaziElementBalanceEngine.analyze(
      chart: natal,
      method: const StructuralOccurrenceBalanceMethod(),
    );
    expect(result.scores.keys.toSet(), WuXingElement.values.toSet());
    expect(result.shares.values.reduce((a, b) => a + b), closeTo(1.0, 1e-12));
    expect(result.spread, greaterThanOrEqualTo(0));
    expect(result.methodId, contains('occurrence'));
  });

  test('RC-0155 Da Yun advances from Month Pillar and preserves 10-year intervals', () {
    final forward = DaYunEngine.calculate(
      natal: natal,
      conventionProvider: const _DaYunProvider(DaYunDirection.forward, 6.25),
      periodCount: 3,
    );
    expect(forward.periods.map((e) => e.pillar.cycleIndex), [14, 15, 16]);
    expect(forward.periods.first.startAgeYears, 6.25);
    expect(forward.periods.first.endAgeYears, 16.25);
    final backward = DaYunEngine.calculate(
      natal: natal,
      conventionProvider: const _DaYunProvider(DaYunDirection.backward, 6.25),
      periodCount: 2,
    );
    expect(backward.periods.map((e) => e.pillar.cycleIndex), [12, 11]);
  });

  test('RC-0156 annual influence resolves explicit period Gan-Zhi and Day-Master relation', () {
    final result = BaziPeriodInfluenceEngine.annual(
      natal: natal,
      instantUtc: DateTime.utc(2026, 9, 7),
      provider: _PeriodProvider(),
    );
    expect(result.kind, BaziPeriodKind.annual);
    expect(result.pillar, SexagenaryCycle.at(40));
    expect(
      result.stemTenGod,
      BaziDerivedAnalysis.tenGodFor(
        dayMaster: natal.day.stem,
        other: SexagenaryCycle.at(40).stem,
      ),
    );
  });

  test('RC-0157 monthly influence is separate from annual influence', () {
    final provider = _PeriodProvider();
    final instant = DateTime.utc(2026, 9, 7);
    final annual = BaziPeriodInfluenceEngine.annual(natal: natal, instantUtc: instant, provider: provider);
    final monthly = BaziPeriodInfluenceEngine.monthly(natal: natal, instantUtc: instant, provider: provider);
    expect(monthly.kind, BaziPeriodKind.monthly);
    expect(monthly.pillar.cycleIndex, 41);
    expect(monthly.pillar.cycleIndex, isNot(annual.pillar.cycleIndex));
  });

  test('fail closed on local DateTime and invalid Da Yun start age', () {
    expect(
      () => BaziPeriodInfluenceEngine.annual(
        natal: natal,
        instantUtc: DateTime(2026, 9, 7),
        provider: _PeriodProvider(),
      ),
      throwsArgumentError,
    );
    expect(
      () => DaYunConventionResolution(
        direction: DaYunDirection.forward,
        startAgeYears: -1,
        sourceId: 'x',
        version: '1',
        conventionId: 'x',
      ),
      throwsArgumentError,
    );
  });
}
