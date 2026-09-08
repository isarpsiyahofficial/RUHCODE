enum TodayEntitlement { free, pro }
enum TodayRange { today, week, month, year }
enum PersonalSignalKind { moon, planetaryHour, personalDay, transit, vedicPeriod, moonPhase, journal }
enum ReminderKind { transitExact, personalMonthChanged, fullMoon, planetaryHourStarted }

final class PersonalSignal {
  PersonalSignal({required this.id, required this.kind, required this.atUtc, required this.summary, required this.sourceId, required this.version, this.importance = 0}) {
    if ([id, summary, sourceId, version].any((v) => v.trim().isEmpty)) throw ArgumentError('signal fields required');
    if (!atUtc.isUtc) throw ArgumentError('signal time must be UTC');
    if (importance < 0 || importance > 100) throw ArgumentError('importance must be 0..100');
  }
  final String id;
  final PersonalSignalKind kind;
  final DateTime atUtc;
  final String summary;
  final String sourceId;
  final String version;
  final int importance;
}

final class DailyJournalEntry {
  DailyJournalEntry({required this.id, required this.dayUtc, required this.note}) {
    if (id.trim().isEmpty || note.trim().isEmpty) throw ArgumentError('journal id/note required');
    if (!dayUtc.isUtc) throw ArgumentError('journal day must be UTC');
  }
  final String id;
  final DateTime dayUtc;
  final String note;
}

final class PersonalTodaySnapshot {
  PersonalTodaySnapshot({required this.dayUtc, required Iterable<PersonalSignal> signals, required Iterable<DailyJournalEntry> journal})
      : signals = List.unmodifiable(signals), journal = List.unmodifiable(journal) {
    if (!dayUtc.isUtc) throw ArgumentError('snapshot day must be UTC');
    final ids = this.signals.map((e) => e.id).toList();
    if (ids.toSet().length != ids.length) throw ArgumentError('duplicate signal id');
  }
  final DateTime dayUtc;
  final List<PersonalSignal> signals;
  final List<DailyJournalEntry> journal;

  List<PersonalSignal> importantEffects(TodayEntitlement entitlement, {int freeLimit = 3}) {
    final sorted = [...signals]..sort((a, b) => b.importance.compareTo(a.importance));
    if (entitlement == TodayEntitlement.pro) return List.unmodifiable(sorted);
    return List.unmodifiable(sorted.take(freeLimit.clamp(0, sorted.length)));
  }
}

final class PersonalCalendar {
  PersonalCalendar({required Iterable<PersonalTodaySnapshot> days}) : days = List.unmodifiable(days) {
    final keys = this.days.map((d) => _dateKey(d.dayUtc)).toList();
    if (keys.toSet().length != keys.length) throw ArgumentError('duplicate calendar day');
  }
  final List<PersonalTodaySnapshot> days;

  PersonalTodaySnapshot? day(DateTime utc) {
    if (!utc.isUtc) throw ArgumentError('UTC required');
    final key = _dateKey(utc);
    for (final item in days) { if (_dateKey(item.dayUtc) == key) return item; }
    return null;
  }

  List<PersonalTodaySnapshot> range(DateTime fromUtc, DateTime toUtc, TodayRange range, TodayEntitlement entitlement) {
    if (!fromUtc.isUtc || !toUtc.isUtc || toUtc.isBefore(fromUtc)) throw ArgumentError('valid UTC range required');
    if (range == TodayRange.year && entitlement != TodayEntitlement.pro) throw StateError('year view requires PRO');
    return List.unmodifiable(days.where((d) => !d.dayUtc.isBefore(fromUtc) && !d.dayUtc.isAfter(toUtc)));
  }

  static String _dateKey(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}

final class FavoriteDate {
  FavoriteDate({required this.id, required this.atUtc, required this.label}) {
    if (id.trim().isEmpty || label.trim().isEmpty || !atUtc.isUtc) throw ArgumentError('valid favorite required');
  }
  final String id;
  final DateTime atUtc;
  final String label;
}

final class PersonalReminder {
  PersonalReminder({required this.id, required this.kind, required this.enabled, required this.sourceRef}) {
    if (id.trim().isEmpty || sourceRef.trim().isEmpty) throw ArgumentError('reminder id/source required');
  }
  final String id;
  final ReminderKind kind;
  final bool enabled;
  final String sourceRef;
}

final class HistoricalCorrelationPolicy {
  const HistoricalCorrelationPolicy();
  String disclaimer(String locale) => locale == 'tr'
      ? 'Geçmiş notlar yalnız karşılaştırma içindir; nedensellik kanıtı değildir.'
      : 'Past notes are for comparison only; they do not prove causation.';
}
