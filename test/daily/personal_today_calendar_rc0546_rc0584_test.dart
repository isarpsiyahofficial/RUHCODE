import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/daily/personal_today_calendar.dart';

PersonalSignal signal(String id, PersonalSignalKind kind, int importance, DateTime at) => PersonalSignal(
  id: id, kind: kind, atUtc: at, summary: id, sourceId: 'calc-core', version: '1', importance: importance,
);

void main() {
  final day = DateTime.utc(2026, 9, 8);

  test('Today keeps changing personal signal types and provenance', () {
    final snapshot = PersonalTodaySnapshot(dayUtc: day, signals: [
      signal('moon', PersonalSignalKind.moon, 30, day),
      signal('hour', PersonalSignalKind.planetaryHour, 40, day.add(const Duration(hours: 1))),
      signal('personal-day', PersonalSignalKind.personalDay, 50, day),
      signal('transit', PersonalSignalKind.transit, 90, day),
      signal('dasha', PersonalSignalKind.vedicPeriod, 70, day),
      signal('phase', PersonalSignalKind.moonPhase, 20, day),
    ], journal: [DailyJournalEntry(id: 'j1', dayUtc: day, note: 'note')]);
    expect(snapshot.signals.map((e) => e.kind).toSet().length, 6);
    expect(snapshot.journal.single.note, 'note');
  });

  test('Free sees first important effects while PRO sees all', () {
    final snapshot = PersonalTodaySnapshot(dayUtc: day, signals: [
      signal('a', PersonalSignalKind.transit, 10, day),
      signal('b', PersonalSignalKind.transit, 80, day),
      signal('c', PersonalSignalKind.transit, 60, day),
      signal('d', PersonalSignalKind.transit, 40, day),
    ], journal: const []);
    expect(snapshot.importantEffects(TodayEntitlement.free).map((e) => e.id), ['b','c','d']);
    expect(snapshot.importantEffects(TodayEntitlement.pro).length, 4);
  });

  test('Year view is PRO but week/month ranges are available', () {
    final calendar = PersonalCalendar(days: [PersonalTodaySnapshot(dayUtc: day, signals: const [], journal: const [])]);
    expect(calendar.range(day, day, TodayRange.week, TodayEntitlement.free).length, 1);
    expect(() => calendar.range(day, day, TodayRange.year, TodayEntitlement.free), throwsStateError);
    expect(calendar.range(day, day, TodayRange.year, TodayEntitlement.pro).length, 1);
  });

  test('Past day returns its own journal and causality disclaimer is explicit', () {
    final past = DateTime.utc(2025, 9, 8);
    final calendar = PersonalCalendar(days: [PersonalTodaySnapshot(dayUtc: past, signals: const [], journal: [DailyJournalEntry(id: 'past', dayUtc: past, note: 'lived experience')])]);
    expect(calendar.day(past)!.journal.single.note, 'lived experience');
    expect(const HistoricalCorrelationPolicy().disclaimer('tr'), contains('nedensellik'));
  });

  test('Reminder categories are independently manageable', () {
    final reminders = [
      PersonalReminder(id:'t', kind:ReminderKind.transitExact, enabled:true, sourceRef:'transit:1'),
      PersonalReminder(id:'m', kind:ReminderKind.personalMonthChanged, enabled:false, sourceRef:'num:month'),
      PersonalReminder(id:'f', kind:ReminderKind.fullMoon, enabled:true, sourceRef:'moon:full'),
      PersonalReminder(id:'v', kind:ReminderKind.planetaryHourStarted, enabled:false, sourceRef:'hour:venus'),
    ];
    expect(reminders.map((e) => e.kind).toSet().length, 4);
    expect(reminders.where((e) => e.enabled).length, 2);
  });

  test('Invalid provenance/time and duplicate day fail closed', () {
    expect(() => PersonalSignal(id:'x', kind:PersonalSignalKind.moon, atUtc:DateTime(2026), summary:'x', sourceId:'s', version:'1'), throwsArgumentError);
    final snap = PersonalTodaySnapshot(dayUtc: day, signals: const [], journal: const []);
    expect(() => PersonalCalendar(days:[snap,snap]), throwsArgumentError);
  });
}
