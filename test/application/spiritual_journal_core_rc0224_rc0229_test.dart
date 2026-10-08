import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/spiritual/spiritual_journal_core.dart';

void main() {
  final created = DateTime.utc(2026, 9, 7, 8);

  test('RC-0224 chakra journal preserves chakra/date/note identity', () {
    final entry = ChakraJournalEntry(
      id: 'chakra-1',
      localDateKey: '2026-09-07',
      chakra: ChakraId.heart,
      note: 'fixture note',
      createdAtUtc: created,
    );
    expect(entry.chakra, ChakraId.heart);
    expect(entry.localDateKey, '2026-09-07');
  });

  test('RC-0225/0226 dream journal stores and filters explicit dates', () {
    final one = DreamJournalEntry(
      id: 'dream-1',
      localDateKey: '2026-09-07',
      title: 'first',
      body: 'fixture dream',
      createdAtUtc: created,
      tags: const ['water'],
    );
    final two = DreamJournalEntry(
      id: 'dream-2',
      localDateKey: '2026-09-08',
      title: 'second',
      body: 'fixture dream 2',
      createdAtUtc: created,
    );
    final aggregate = SpiritualJournalAggregate(dreamEntries: [one, two]);
    expect(aggregate.dreamsForDate('2026-09-07').single.id, 'dream-1');
    expect(aggregate.dreamsForDate('2026-09-09'), isEmpty);
  });

  test('journal dates reject invalid or impossible dates', () {
    expect(
      () => DreamJournalEntry(
        id: 'dream',
        localDateKey: '2026-02-30',
        title: 'x',
        body: 'x',
        createdAtUtc: created,
      ),
      throwsArgumentError,
    );
    expect(
      () => DreamJournalEntry(
        id: 'dream',
        localDateKey: '07-09-2026',
        title: 'x',
        body: 'x',
        createdAtUtc: created,
      ),
      throwsArgumentError,
    );
  });

  test('RC-0227 affirmation entries are distinct dated records', () {
    final entry = AffirmationEntry(
      id: 'affirmation-1',
      localDateKey: '2026-09-07',
      text: 'fixture affirmation',
      createdAtUtc: created,
    );
    expect(entry.text, 'fixture affirmation');
  });

  test('RC-0228 gratitude journal requires at least one nonblank item', () {
    final entry = GratitudeEntry(
      id: 'gratitude-1',
      localDateKey: '2026-09-07',
      items: const ['fixture gratitude'],
      createdAtUtc: created,
    );
    expect(entry.items, hasLength(1));
    expect(
      () => GratitudeEntry(
        id: 'gratitude-2',
        localDateKey: '2026-09-07',
        items: const [],
        createdAtUtc: created,
      ),
      throwsArgumentError,
    );
  });

  test('RC-0229 ritual planner stays modular and supports status', () {
    final plan = RitualPlanEntry(
      id: 'ritual-1',
      localDateKey: '2026-09-08',
      title: 'fixture ritual',
      instructions: 'fixture-only instructions',
      createdAtUtc: created,
      sourceId: 'fixture-only',
      version: 'fixture-v1',
    );
    expect(plan.status, RitualPlanStatus.planned);
    expect(plan.sourceId, 'fixture-only');
  });

  test('ritual sourced content requires source/version as a pair', () {
    expect(
      () => RitualPlanEntry(
        id: 'ritual-2',
        localDateKey: '2026-09-08',
        title: 'x',
        instructions: 'x',
        createdAtUtc: created,
        sourceId: 'source',
      ),
      throwsArgumentError,
    );
  });

  test('timestamps must be UTC and duplicate same-kind IDs fail closed', () {
    expect(
      () => AffirmationEntry(
        id: 'a',
        localDateKey: '2026-09-07',
        text: 'x',
        createdAtUtc: DateTime(2026, 9, 7),
      ),
      throwsArgumentError,
    );
    final entry = AffirmationEntry(
      id: 'same',
      localDateKey: '2026-09-07',
      text: 'x',
      createdAtUtc: created,
    );
    expect(
      () => SpiritualJournalAggregate(affirmations: [entry, entry]),
      throwsArgumentError,
    );
  });
}
