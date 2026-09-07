/// Journal/planner primitives for RUH CODE spiritual tools.
///
/// These are application records, not calculation-engine truths. Date identity
/// is explicit so records cannot silently migrate between calendar days.
enum ChakraId {
  root,
  sacral,
  solarPlexus,
  heart,
  throat,
  thirdEye,
  crown,
}

final class ChakraJournalEntry {
  ChakraJournalEntry({
    required this.id,
    required this.localDateKey,
    required this.chakra,
    required this.note,
    required this.createdAtUtc,
  }) {
    _requireId(id, 'id');
    _requireDate(localDateKey);
    _requireText(note, 'note');
    _requireUtc(createdAtUtc, 'createdAtUtc');
  }

  final String id;
  final String localDateKey;
  final ChakraId chakra;
  final String note;
  final DateTime createdAtUtc;
}

final class DreamJournalEntry {
  DreamJournalEntry({
    required this.id,
    required this.localDateKey,
    required this.title,
    required this.body,
    required this.createdAtUtc,
    this.tags = const [],
  }) {
    _requireId(id, 'id');
    _requireDate(localDateKey);
    _requireText(title, 'title');
    _requireText(body, 'body');
    _requireUtc(createdAtUtc, 'createdAtUtc');
    if (tags.any((tag) => tag.trim().isEmpty)) {
      throw ArgumentError('dream tags cannot contain blank values');
    }
  }

  final String id;
  final String localDateKey;
  final String title;
  final String body;
  final DateTime createdAtUtc;
  final List<String> tags;
}

final class AffirmationEntry {
  AffirmationEntry({
    required this.id,
    required this.localDateKey,
    required this.text,
    required this.createdAtUtc,
  }) {
    _requireId(id, 'id');
    _requireDate(localDateKey);
    _requireText(text, 'text');
    _requireUtc(createdAtUtc, 'createdAtUtc');
  }

  final String id;
  final String localDateKey;
  final String text;
  final DateTime createdAtUtc;
}

final class GratitudeEntry {
  GratitudeEntry({
    required this.id,
    required this.localDateKey,
    required Iterable<String> items,
    required this.createdAtUtc,
  }) : items = List.unmodifiable(items) {
    _requireId(id, 'id');
    _requireDate(localDateKey);
    _requireUtc(createdAtUtc, 'createdAtUtc');
    if (this.items.isEmpty || this.items.any((item) => item.trim().isEmpty)) {
      throw ArgumentError('gratitude entry requires non-blank items');
    }
  }

  final String id;
  final String localDateKey;
  final List<String> items;
  final DateTime createdAtUtc;
}

enum RitualPlanStatus { planned, completed, cancelled }

final class RitualPlanEntry {
  RitualPlanEntry({
    required this.id,
    required this.localDateKey,
    required this.title,
    required this.instructions,
    required this.createdAtUtc,
    this.status = RitualPlanStatus.planned,
    this.sourceId,
    this.version,
  }) {
    _requireId(id, 'id');
    _requireDate(localDateKey);
    _requireText(title, 'title');
    _requireText(instructions, 'instructions');
    _requireUtc(createdAtUtc, 'createdAtUtc');
    if ((sourceId == null) != (version == null)) {
      throw ArgumentError('ritual sourceId and version must be supplied together');
    }
    if (sourceId != null) {
      _requireText(sourceId!, 'sourceId');
      _requireText(version!, 'version');
    }
  }

  final String id;
  final String localDateKey;
  final String title;
  final String instructions;
  final DateTime createdAtUtc;
  final RitualPlanStatus status;
  final String? sourceId;
  final String? version;
}

/// In-memory aggregate with explicit record isolation. Persistence is supplied
/// by the repository/storage layer; this class intentionally does not pretend
/// that an in-memory list satisfies backup/offline durability requirements.
final class SpiritualJournalAggregate {
  SpiritualJournalAggregate({
    Iterable<ChakraJournalEntry> chakraEntries = const [],
    Iterable<DreamJournalEntry> dreamEntries = const [],
    Iterable<AffirmationEntry> affirmations = const [],
    Iterable<GratitudeEntry> gratitudeEntries = const [],
    Iterable<RitualPlanEntry> ritualPlans = const [],
  })  : chakraEntries = List.unmodifiable(chakraEntries),
        dreamEntries = List.unmodifiable(dreamEntries),
        affirmations = List.unmodifiable(affirmations),
        gratitudeEntries = List.unmodifiable(gratitudeEntries),
        ritualPlans = List.unmodifiable(ritualPlans) {
    final seen = <String>{};
    for (final entry in [
      ...this.chakraEntries.map((e) => ('chakra', e.id)),
      ...this.dreamEntries.map((e) => ('dream', e.id)),
      ...this.affirmations.map((e) => ('affirmation', e.id)),
      ...this.gratitudeEntries.map((e) => ('gratitude', e.id)),
      ...this.ritualPlans.map((e) => ('ritual', e.id)),
    ]) {
      final key = '${entry.$1}:${entry.$2}';
      if (!seen.add(key)) {
        throw ArgumentError('duplicate journal record identity: $key');
      }
    }
  }

  final List<ChakraJournalEntry> chakraEntries;
  final List<DreamJournalEntry> dreamEntries;
  final List<AffirmationEntry> affirmations;
  final List<GratitudeEntry> gratitudeEntries;
  final List<RitualPlanEntry> ritualPlans;

  List<DreamJournalEntry> dreamsForDate(String localDateKey) {
    _requireDate(localDateKey);
    return List.unmodifiable(
      dreamEntries.where((entry) => entry.localDateKey == localDateKey),
    );
  }
}

void _requireText(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field cannot be blank');
}

void _requireId(String value, String field) => _requireText(value, field);

void _requireDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw ArgumentError('localDateKey must use YYYY-MM-DD');
  }
  final parts = value.split('-').map(int.parse).toList();
  final parsed = DateTime.utc(parts[0], parts[1], parts[2]);
  if (parsed.year != parts[0] || parsed.month != parts[1] || parsed.day != parts[2]) {
    throw ArgumentError('localDateKey must be a valid calendar date');
  }
}

void _requireUtc(DateTime value, String field) {
  if (!value.isUtc) throw ArgumentError('$field must be UTC');
}
