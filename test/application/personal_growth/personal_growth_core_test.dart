import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/personal_growth/personal_growth_core.dart';

void main() {
  test('personal growth works without astrology context', () {
    final snapshot = GrowthSnapshot(
      journal: [PersonalJournalEntry(id: 'j1', localDateKey: '2026-09-07', body: 'note', createdAtUtc: DateTime.utc(2026, 9, 7))],
      goals: [PersonalGoal(id: 'g1', title: 'Goal', tasks: [GoalTask(id: 't1', title: 'Task')])],
      habits: [HabitRecord(id: 'h1', title: 'Read', completedDateKeys: const ['2026-09-07'])],
      weeklyReflections: [ReflectionEntry(id: 'w1', periodKey: '2026-W37', body: 'weekly', createdAtUtc: DateTime.utc(2026, 9, 7))],
      monthlyReflections: [ReflectionEntry(id: 'm1', periodKey: '2026-09', body: 'monthly', createdAtUtc: DateTime.utc(2026, 9, 7))],
      lifeWheel: [LifeWheelScore(areaId: 'health', score: 8)],
      values: [PersonalValue(id: 'v1', label: 'Integrity', priority: 1)],
      moodEnergy: [MoodEnergyEntry(id: 'me1', localDateKey: '2026-09-07', mood: 7, energy: 6, createdAtUtc: DateTime.utc(2026, 9, 7))],
      checkIns: [
        DailyCheckIn(id: 'c1', localDateKey: '2026-09-07', kind: CheckInKind.morning, note: 'start', createdAtUtc: DateTime.utc(2026, 9, 7)),
        DailyCheckIn(id: 'c2', localDateKey: '2026-09-07', kind: CheckInKind.evening, note: 'end', createdAtUtc: DateTime.utc(2026, 9, 7, 18)),
      ],
      notes: [PersonalNote(id: 'n1', title: 'Idea', body: 'Body', createdAtUtc: DateTime.utc(2026, 9, 7))],
    );
    expect(snapshot.astrologyContext, isNull);
    expect(snapshot.journalForDate('2026-09-07'), hasLength(1));
    expect(snapshot.moodEnergyForDate('2026-09-07'), hasLength(1));
  });

  test('goal tasks are explicit and duplicate task ids fail closed', () {
    expect(
      () => PersonalGoal(id: 'g', title: 'x', tasks: [GoalTask(id: 't', title: 'a'), GoalTask(id: 't', title: 'b')]),
      throwsArgumentError,
    );
  });

  test('optional astrology comparison requires provenance', () {
    final link = AstrologyContextLink(systemId: 'western', periodId: 'transit-1', sourceId: 'engine', version: '1');
    expect(link.systemId, 'western');
    expect(() => AstrologyContextLink(systemId: '', periodId: 'p', sourceId: 's', version: '1'), throwsArgumentError);
  });

  test('mood energy and dates validate fail closed', () {
    expect(() => MoodEnergyEntry(id: 'x', localDateKey: '2026-02-30', mood: 5, energy: 5, createdAtUtc: DateTime.utc(2026)), throwsArgumentError);
    expect(() => MoodEnergyEntry(id: 'x', localDateKey: '2026-09-07', mood: 11, energy: 5, createdAtUtc: DateTime.utc(2026)), throwsArgumentError);
  });
}
