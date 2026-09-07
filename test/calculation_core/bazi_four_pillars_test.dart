import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_four_pillars.dart';

final class _FixtureBaziProvider implements BaziFourPillarsProvider {
  @override
  BaziFourPillarsResolution resolve({required DateTime birthInstantUtc}) =>
      BaziFourPillarsResolution(
        yearCycleIndex: 40, // Jia-Chen.
        monthCycleIndex: 2, // Bing-Yin.
        dayCycleIndex: 0, // Jia-Zi.
        hourCycleIndex: 59, // Gui-Hai.
        sourceId: 'fixture-bazi-calendar',
        version: 'fixture-v1',
        conventionId: 'fixture-only',
      );
}

void main() {
  test('RC-0142 BaZi remains a distinct Four Pillars domain', () {
    final snapshot = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(2026, 1, 1),
      provider: _FixtureBaziProvider(),
    );
    expect(snapshot.pillars, hasLength(4));
    expect(snapshot.conventionId, 'fixture-only');
  });

  test('RC-0143..RC-0146 assemble Year Month Day Hour pillars independently', () {
    final snapshot = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(2026, 1, 1),
      provider: _FixtureBaziProvider(),
    );

    expect(snapshot.year.kind, BaziPillarKind.year);
    expect(snapshot.year.sexagenaryCycleIndex, 40);
    expect(snapshot.month.kind, BaziPillarKind.month);
    expect(snapshot.month.sexagenaryCycleIndex, 2);
    expect(snapshot.day.kind, BaziPillarKind.day);
    expect(snapshot.day.sexagenaryCycleIndex, 0);
    expect(snapshot.hour.kind, BaziPillarKind.hour);
    expect(snapshot.hour.sexagenaryCycleIndex, 59);
  });

  test('RC-0147 and RC-0148 map cycle indices to canonical stems and branches', () {
    final snapshot = BaziFourPillarsEngine.calculate(
      birthInstantUtc: DateTime.utc(2026, 1, 1),
      provider: _FixtureBaziProvider(),
    );

    expect(snapshot.year.stem, BaziHeavenlyStem.jia);
    expect(snapshot.year.branch, BaziEarthlyBranch.chen);
    expect(snapshot.month.stem, BaziHeavenlyStem.bing);
    expect(snapshot.month.branch, BaziEarthlyBranch.yin);
    expect(snapshot.day.stem, BaziHeavenlyStem.jia);
    expect(snapshot.day.branch, BaziEarthlyBranch.zi);
    expect(snapshot.hour.stem, BaziHeavenlyStem.gui);
    expect(snapshot.hour.branch, BaziEarthlyBranch.hai);
  });

  test('BaZi provenance and convention are mandatory', () {
    expect(
      () => BaziFourPillarsResolution(
        yearCycleIndex: 0,
        monthCycleIndex: 0,
        dayCycleIndex: 0,
        hourCycleIndex: 0,
        sourceId: 'source',
        version: 'v1',
        conventionId: '',
      ),
      throwsArgumentError,
    );
  });

  test('BaZi cycle indices fail closed outside 0..59', () {
    expect(
      () => BaziFourPillarsResolution(
        yearCycleIndex: 60,
        monthCycleIndex: 0,
        dayCycleIndex: 0,
        hourCycleIndex: 0,
        sourceId: 'source',
        version: 'v1',
        conventionId: 'fixture',
      ),
      throwsArgumentError,
    );
  });

  test('BaZi core rejects non-UTC birth instants', () {
    expect(
      () => BaziFourPillarsEngine.calculate(
        birthInstantUtc: DateTime(2026, 1, 1),
        provider: _FixtureBaziProvider(),
      ),
      throwsArgumentError,
    );
  });
}
