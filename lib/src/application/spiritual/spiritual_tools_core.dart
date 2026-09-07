/// Application-domain primitives for the RUH CODE spiritual tools surface.
///
/// This module intentionally does not calculate astronomy and does not import
/// the calculation core. It consumes already-resolved observations (for
/// example a moon-phase label) and keeps symbolic/editorial practices separate
/// from astronomical truth.
enum SpiritualToolKind {
  tarot,
  iChing,
  moonCycle,
  intention,
  meditation,
  breathwork,
}

final class SpiritualToolDescriptor {
  SpiritualToolDescriptor({
    required this.kind,
    required this.id,
    required this.titleKey,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(id, 'id');
    _requireText(titleKey, 'titleKey');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final SpiritualToolKind kind;
  final String id;
  final String titleKey;
  final String version;
  final String sourceId;
}

final class SpiritualToolsRegistry {
  SpiritualToolsRegistry(Iterable<SpiritualToolDescriptor> tools)
      : tools = List.unmodifiable(tools) {
    if (this.tools.isEmpty) {
      throw ArgumentError('spiritual tool registry cannot be empty');
    }
    final ids = <String>{};
    final kinds = <SpiritualToolKind>{};
    for (final tool in this.tools) {
      if (!ids.add(tool.id)) {
        throw ArgumentError('duplicate spiritual tool id: ${tool.id}');
      }
      if (!kinds.add(tool.kind)) {
        throw ArgumentError('duplicate spiritual tool kind: ${tool.kind.name}');
      }
    }
    const requiredKinds = SpiritualToolKind.values;
    if (kinds.length != requiredKinds.length ||
        !requiredKinds.every(kinds.contains)) {
      throw ArgumentError(
        'registry must contain each spiritual tool kind exactly once',
      );
    }
  }

  final List<SpiritualToolDescriptor> tools;

  SpiritualToolDescriptor byKind(SpiritualToolKind kind) =>
      tools.singleWhere((tool) => tool.kind == kind);
}

final class TarotCardDefinition {
  TarotCardDefinition({
    required this.id,
    required this.deckId,
    required this.titleKey,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(id, 'id');
    _requireText(deckId, 'deckId');
    _requireText(titleKey, 'titleKey');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final String id;
  final String deckId;
  final String titleKey;
  final String version;
  final String sourceId;
}

final class TarotDeckDefinition {
  TarotDeckDefinition({
    required this.id,
    required this.version,
    required this.sourceId,
    required Iterable<TarotCardDefinition> cards,
  }) : cards = List.unmodifiable(cards) {
    _requireText(id, 'id');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
    if (this.cards.isEmpty) {
      throw ArgumentError('Tarot deck cannot be empty');
    }
    final ids = <String>{};
    for (final card in this.cards) {
      if (card.deckId != id) {
        throw ArgumentError('card ${card.id} belongs to another deck');
      }
      if (!ids.add(card.id)) {
        throw ArgumentError('duplicate Tarot card id: ${card.id}');
      }
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final List<TarotCardDefinition> cards;

  TarotCardDefinition cardById(String cardId) =>
      cards.singleWhere((card) => card.id == cardId);
}

final class TarotSpreadPosition {
  TarotSpreadPosition({required this.key, required this.titleKey}) {
    _requireText(key, 'key');
    _requireText(titleKey, 'titleKey');
  }

  final String key;
  final String titleKey;
}

final class TarotSpreadDefinition {
  TarotSpreadDefinition({
    required this.id,
    required this.version,
    required this.sourceId,
    required Iterable<TarotSpreadPosition> positions,
  }) : positions = List.unmodifiable(positions) {
    _requireText(id, 'id');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
    if (this.positions.isEmpty) {
      throw ArgumentError('Tarot spread must contain at least one position');
    }
    final keys = <String>{};
    for (final position in this.positions) {
      if (!keys.add(position.key)) {
        throw ArgumentError('duplicate Tarot spread position: ${position.key}');
      }
    }
  }

  factory TarotSpreadDefinition.oneCard({
    String id = 'tarot.one-card',
    required String version,
    required String sourceId,
  }) =>
      TarotSpreadDefinition(
        id: id,
        version: version,
        sourceId: sourceId,
        positions: [
          TarotSpreadPosition(
            key: 'single',
            titleKey: 'spiritual.tarot.position.single',
          ),
        ],
      );

  factory TarotSpreadDefinition.threeCard({
    String id = 'tarot.three-card',
    required String version,
    required String sourceId,
  }) =>
      TarotSpreadDefinition(
        id: id,
        version: version,
        sourceId: sourceId,
        positions: [
          TarotSpreadPosition(
            key: 'first',
            titleKey: 'spiritual.tarot.position.first',
          ),
          TarotSpreadPosition(
            key: 'second',
            titleKey: 'spiritual.tarot.position.second',
          ),
          TarotSpreadPosition(
            key: 'third',
            titleKey: 'spiritual.tarot.position.third',
          ),
        ],
      );

  final String id;
  final String version;
  final String sourceId;
  final List<TarotSpreadPosition> positions;
}

final class TarotDrawSlot {
  const TarotDrawSlot({required this.position, required this.card});

  final TarotSpreadPosition position;
  final TarotCardDefinition card;
}

final class TarotReading {
  const TarotReading({
    required this.deckId,
    required this.spreadId,
    required this.slots,
  });

  final String deckId;
  final String spreadId;
  final List<TarotDrawSlot> slots;
}

/// Deterministic draw assembler.
///
/// Card order must be supplied by the caller (for example a separately audited
/// entropy provider). This class deliberately owns no hidden RNG, which makes
/// replay/testing possible and prevents random filler text from being mistaken
/// for a sourced interpretation.
final class TarotDrawEngine {
  const TarotDrawEngine();

  TarotReading assemble({
    required TarotDeckDefinition deck,
    required TarotSpreadDefinition spread,
    required List<String> orderedCardIds,
  }) {
    if (orderedCardIds.length != spread.positions.length) {
      throw ArgumentError(
        'draw count must equal spread position count: '
        '${spread.positions.length}',
      );
    }
    final selected = <String>{};
    final slots = <TarotDrawSlot>[];
    for (var index = 0; index < orderedCardIds.length; index++) {
      final cardId = orderedCardIds[index];
      if (!selected.add(cardId)) {
        throw ArgumentError('duplicate card in one Tarot draw: $cardId');
      }
      TarotCardDefinition card;
      try {
        card = deck.cardById(cardId);
      } on StateError {
        throw ArgumentError('unknown Tarot card id: $cardId');
      }
      slots.add(TarotDrawSlot(position: spread.positions[index], card: card));
    }
    return TarotReading(
      deckId: deck.id,
      spreadId: spread.id,
      slots: List.unmodifiable(slots),
    );
  }
}

final class TarotInterpretationEntry {
  TarotInterpretationEntry({
    required this.cardId,
    required this.spreadPositionKey,
    required this.locale,
    required this.body,
    required this.editorialPolicyId,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(cardId, 'cardId');
    _requireText(spreadPositionKey, 'spreadPositionKey');
    _requireText(locale, 'locale');
    _requireText(body, 'body');
    _requireText(editorialPolicyId, 'editorialPolicyId');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final String cardId;
  final String spreadPositionKey;
  final String locale;
  final String body;
  final String editorialPolicyId;
  final String version;
  final String sourceId;
}

final class TarotInterpretationCatalog {
  TarotInterpretationCatalog(Iterable<TarotInterpretationEntry> entries)
      : entries = List.unmodifiable(entries) {
    if (this.entries.isEmpty) {
      throw ArgumentError('Tarot interpretation catalog cannot be empty');
    }
    final keys = <String>{};
    for (final entry in this.entries) {
      final key = '${entry.locale}|${entry.cardId}|${entry.spreadPositionKey}';
      if (!keys.add(key)) {
        throw ArgumentError('duplicate Tarot interpretation entry: $key');
      }
    }
  }

  final List<TarotInterpretationEntry> entries;
}

/// I Ching remains an independent spiritual tool boundary. A concrete
/// hexagram/yarrow/coin algorithm can be plugged in later without being routed
/// through Tarot or astrology engines.
abstract interface class IChingReadingProvider {
  IChingReadingResult read(IChingReadingRequest request);
}

final class IChingReadingRequest {
  IChingReadingRequest({required this.methodId, required this.entropyToken}) {
    _requireText(methodId, 'methodId');
    _requireText(entropyToken, 'entropyToken');
  }

  final String methodId;
  final String entropyToken;
}

final class IChingReadingResult {
  IChingReadingResult({
    required this.hexagramId,
    required this.methodId,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(hexagramId, 'hexagramId');
    _requireText(methodId, 'methodId');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final String hexagramId;
  final String methodId;
  final String version;
  final String sourceId;
}

/// Guidance only: the astronomical moon phase must already have been resolved
/// by a verified upstream astronomy provider.
final class MoonCycleGuidance {
  MoonCycleGuidance({
    required this.phaseId,
    required this.guidanceKey,
    required this.astronomySourceId,
    required this.editorialSourceId,
    required this.version,
  }) {
    _requireText(phaseId, 'phaseId');
    _requireText(guidanceKey, 'guidanceKey');
    _requireText(astronomySourceId, 'astronomySourceId');
    _requireText(editorialSourceId, 'editorialSourceId');
    _requireText(version, 'version');
  }

  final String phaseId;
  final String guidanceKey;
  final String astronomySourceId;
  final String editorialSourceId;
  final String version;
}

final class IntentionPractice {
  IntentionPractice({
    required this.id,
    required this.titleKey,
    required this.promptKey,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(id, 'id');
    _requireText(titleKey, 'titleKey');
    _requireText(promptKey, 'promptKey');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final String id;
  final String titleKey;
  final String promptKey;
  final String version;
  final String sourceId;
}

final class DailyIntention {
  DailyIntention({
    required this.localDateKey,
    required this.practiceId,
    required this.text,
  }) {
    _requireText(localDateKey, 'localDateKey');
    _requireText(practiceId, 'practiceId');
    _requireText(text, 'text');
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!datePattern.hasMatch(localDateKey)) {
      throw ArgumentError('localDateKey must use YYYY-MM-DD');
    }
  }

  final String localDateKey;
  final String practiceId;
  final String text;
}

final class MeditationContent {
  MeditationContent({
    required this.id,
    required this.titleKey,
    required this.durationSeconds,
    required this.contentKey,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(id, 'id');
    _requireText(titleKey, 'titleKey');
    _requireText(contentKey, 'contentKey');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
    if (durationSeconds <= 0) {
      throw ArgumentError('meditation duration must be positive');
    }
  }

  final String id;
  final String titleKey;
  final int durationSeconds;
  final String contentKey;
  final String version;
  final String sourceId;
}

final class BreathworkContent {
  BreathworkContent({
    required this.id,
    required this.titleKey,
    required this.instructionsKey,
    required this.safetyNoteKey,
    required this.version,
    required this.sourceId,
  }) {
    _requireText(id, 'id');
    _requireText(titleKey, 'titleKey');
    _requireText(instructionsKey, 'instructionsKey');
    _requireText(safetyNoteKey, 'safetyNoteKey');
    _requireText(version, 'version');
    _requireText(sourceId, 'sourceId');
  }

  final String id;
  final String titleKey;
  final String instructionsKey;
  final String safetyNoteKey;
  final String version;
  final String sourceId;
}

void _requireText(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError('$field cannot be blank');
  }
}
