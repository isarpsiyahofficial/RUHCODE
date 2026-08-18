import '../numerology/personal_day.dart';
import '../time/civil_calendar.dart';
import 'daily_snapshot.dart';

final class PersonalDayDailyFactor {
  const PersonalDayDailyFactor({
    this.policy = PersonalCycleReductionPolicy.singleDigit,
  });

  final PersonalCycleReductionPolicy policy;

  DailyFactorReference build({
    required CivilDate birthDate,
    required CivilDate targetDate,
  }) {
    final result = PythagoreanPersonalDayEngine.calculate(
      birthDate: birthDate,
      targetDate: targetDate,
      policy: policy,
    );

    final resultId = <String>[
      'personal-day',
      result.targetDate.isoKey,
      result.personalDay.toString(),
      'py-${result.personalYear}',
      'pm-${result.personalMonth}',
      policy.name,
    ].join('|');

    return DailyFactorReference(
      kind: DailyFactorKind.personalDay,
      sourceEngineId: PythagoreanPersonalDayEngine.engineId,
      sourceEngineVersion: PythagoreanPersonalDayEngine.engineVersion,
      resultId: resultId,
    );
  }
}
