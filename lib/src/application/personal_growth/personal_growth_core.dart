/// Personal-growth primitives for RUH CODE.
///
/// This domain is intentionally useful without astrology. Optional astrological
/// context may be attached for comparison, but never becomes mandatory input.
enum CheckInKind { morning, evening }

enum GoalStatus { active, completed, archived }

final class PersonalJournalEntry {
  PersonalJournalEntry({required this.id, required this.localDateKey, required this.body, required this.createdAtUtc}) {
    _text(id, 'id'); _date(localDateKey); _text(body, 'body'); _utc(createdAtUtc, 'createdAtUtc');
  }
  final String id; final String localDateKey; final String body; final DateTime createdAtUtc;
}

final class GoalTask {
  GoalTask({required this.id, required this.title, this.completed = false}) { _text(id, 'id'); _text(title, 'title'); }
  final String id; final String title; final bool completed;
}

final class PersonalGoal {
  PersonalGoal({required this.id, required this.title, required Iterable<GoalTask> tasks, this.status = GoalStatus.active})
      : tasks = List.unmodifiable(tasks) {
    _text(id, 'id'); _text(title, 'title');
    final ids = <String>{};
    for (final task in this.tasks) { if (!ids.add(task.id)) throw ArgumentError('duplicate goal task id: ${task.id}'); }
  }
  final String id; final String title; final List<GoalTask> tasks; final GoalStatus status;
}

final class HabitRecord {
  HabitRecord({required this.id, required this.title, required Iterable<String> completedDateKeys})
      : completedDateKeys = List.unmodifiable(completedDateKeys) {
    _text(id, 'id'); _text(title, 'title');
    final seen = <String>{};
    for (final key in this.completedDateKeys) { _date(key); if (!seen.add(key)) throw ArgumentError('duplicate habit date: $key'); }
  }
  final String id; final String title; final List<String> completedDateKeys;
}

final class ReflectionEntry {
  ReflectionEntry({required this.id, required this.periodKey, required this.body, required this.createdAtUtc}) {
    _text(id, 'id'); _text(periodKey, 'periodKey'); _text(body, 'body'); _utc(createdAtUtc, 'createdAtUtc');
  }
  final String id; final String periodKey; final String body; final DateTime createdAtUtc;
}

final class LifeWheelScore {
  LifeWheelScore({required this.areaId, required this.score}) {
    _text(areaId, 'areaId'); if (score < 0 || score > 10) throw ArgumentError('life wheel score must be 0..10');
  }
  final String areaId; final int score;
}

final class PersonalValue {
  PersonalValue({required this.id, required this.label, required this.priority}) {
    _text(id, 'id'); _text(label, 'label'); if (priority < 1) throw ArgumentError('priority must be >= 1');
  }
  final String id; final String label; final int priority;
}

final class MoodEnergyEntry {
  MoodEnergyEntry({required this.id, required this.localDateKey, required this.mood, required this.energy, required this.createdAtUtc}) {
    _text(id, 'id'); _date(localDateKey); _range(mood, 'mood'); _range(energy, 'energy'); _utc(createdAtUtc, 'createdAtUtc');
  }
  final String id; final String localDateKey; final int mood; final int energy; final DateTime createdAtUtc;
}

final class DailyCheckIn {
  DailyCheckIn({required this.id, required this.localDateKey, required this.kind, required this.note, required this.createdAtUtc}) {
    _text(id, 'id'); _date(localDateKey); _text(note, 'note'); _utc(createdAtUtc, 'createdAtUtc');
  }
  final String id; final String localDateKey; final CheckInKind kind; final String note; final DateTime createdAtUtc;
}

final class PersonalNote {
  PersonalNote({required this.id, required this.title, required this.body, required this.createdAtUtc}) {
    _text(id, 'id'); _text(title, 'title'); _text(body, 'body'); _utc(createdAtUtc, 'createdAtUtc');
  }
  final String id; final String title; final String body; final DateTime createdAtUtc;
}

/// Optional context link used only when the user explicitly chooses to compare
/// growth records with an astrological period. Null means fully standalone use.
final class AstrologyContextLink {
  AstrologyContextLink({required this.systemId, required this.periodId, required this.sourceId, required this.version}) {
    _text(systemId, 'systemId'); _text(periodId, 'periodId'); _text(sourceId, 'sourceId'); _text(version, 'version');
  }
  final String systemId; final String periodId; final String sourceId; final String version;
}

final class GrowthSnapshot {
  GrowthSnapshot({
    required Iterable<PersonalJournalEntry> journal,
    required Iterable<PersonalGoal> goals,
    required Iterable<HabitRecord> habits,
    required Iterable<ReflectionEntry> weeklyReflections,
    required Iterable<ReflectionEntry> monthlyReflections,
    required Iterable<LifeWheelScore> lifeWheel,
    required Iterable<PersonalValue> values,
    required Iterable<MoodEnergyEntry> moodEnergy,
    required Iterable<DailyCheckIn> checkIns,
    required Iterable<PersonalNote> notes,
    this.astrologyContext,
  })  : journal = List.unmodifiable(journal), goals = List.unmodifiable(goals), habits = List.unmodifiable(habits),
        weeklyReflections = List.unmodifiable(weeklyReflections), monthlyReflections = List.unmodifiable(monthlyReflections),
        lifeWheel = List.unmodifiable(lifeWheel), values = List.unmodifiable(values), moodEnergy = List.unmodifiable(moodEnergy),
        checkIns = List.unmodifiable(checkIns), notes = List.unmodifiable(notes) {
    final seen = <String>{};
    void add(String kind, String id) { final key = '$kind:$id'; if (!seen.add(key)) throw ArgumentError('duplicate growth identity: $key'); }
    for (final e in this.journal) add('journal', e.id); for (final e in this.goals) add('goal', e.id); for (final e in this.habits) add('habit', e.id);
    for (final e in this.weeklyReflections) add('weekly', e.id); for (final e in this.monthlyReflections) add('monthly', e.id);
    for (final e in this.moodEnergy) add('mood', e.id); for (final e in this.checkIns) add('checkin', e.id); for (final e in this.notes) add('note', e.id);
  }
  final List<PersonalJournalEntry> journal; final List<PersonalGoal> goals; final List<HabitRecord> habits;
  final List<ReflectionEntry> weeklyReflections; final List<ReflectionEntry> monthlyReflections; final List<LifeWheelScore> lifeWheel;
  final List<PersonalValue> values; final List<MoodEnergyEntry> moodEnergy; final List<DailyCheckIn> checkIns; final List<PersonalNote> notes;
  final AstrologyContextLink? astrologyContext;

  List<PersonalJournalEntry> journalForDate(String localDateKey) { _date(localDateKey); return List.unmodifiable(journal.where((e) => e.localDateKey == localDateKey)); }
  List<MoodEnergyEntry> moodEnergyForDate(String localDateKey) { _date(localDateKey); return List.unmodifiable(moodEnergy.where((e) => e.localDateKey == localDateKey)); }
}

void _text(String value, String field) { if (value.trim().isEmpty) throw ArgumentError('$field cannot be blank'); }
void _range(int value, String field) { if (value < 0 || value > 10) throw ArgumentError('$field must be 0..10'); }
void _utc(DateTime value, String field) { if (!value.isUtc) throw ArgumentError('$field must be UTC'); }
void _date(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) throw ArgumentError('date must use YYYY-MM-DD');
  final p = value.split('-').map(int.parse).toList(); final d = DateTime.utc(p[0], p[1], p[2]);
  if (d.year != p[0] || d.month != p[1] || d.day != p[2]) throw ArgumentError('date must be valid');
}
