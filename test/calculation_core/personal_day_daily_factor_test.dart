import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/daily/daily_snapshot.dart';
import 'package:ruh_code/src/calculation_core/daily/personal_day_factor.dart';
import 'package:ruh_code/src/calculation_core/numerology/personal_day.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  test('PersonalDayDailyFactor emits deterministic provenance reference', () {
    const factor = PersonalDayDailyFactor();
    final reference = factor.build(
      birthDate: CivilDate(1990, 5, 19),
      targetDate: CivilDate(2026, 8, 16),
    );

    expect(reference.kind, DailyFactorKind.personalDay);
    expect(
      reference.sourceEngineId,
      PythagoreanPersonalDayEngine.engineId,
    );
    expect(
      reference.sourceEngineVersion,
      PythagoreanPersonalDayEngine.engineVersion,
    );
    expect(
      reference.resultId,
      'personal-day|2026-08-16|4|py-7|pm-6|singleDigit',
    );
  });

  test('master-number policy is encoded in result identity', () {
    const factor = PersonalDayDailyFactor(
      policy: PersonalCycleReductionPolicy.preserveMasterNumbers,
    );
    final reference = factor.build(
      birthDate: CivilDate(1990, 5, 19),
      targetDate: CivilDate(2026, 8, 16),
    );

    expect(reference.resultId, contains('|22|'));
    expect(reference.resultId, endsWith('|preserveMasterNumbers'));
  });
}
