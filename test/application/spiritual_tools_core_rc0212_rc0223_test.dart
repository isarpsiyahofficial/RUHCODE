import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/spiritual/spiritual_tools_core.dart';

void main() {
  SpiritualToolsRegistry registry() => SpiritualToolsRegistry([
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.tarot,
          id: 'tarot',
          titleKey: 'spiritual.tarot',
          version: '1',
          sourceId: 'product-spec',
        ),
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.iChing,
          id: 'iching',
          titleKey: 'spiritual.iching',
          version: '1',
          sourceId: 'product-spec',
        ),
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.moonCycle,
          id: 'moon-cycle',
          titleKey: 'spiritual.moonCycle',
          version: '1',
          sourceId: 'product-spec',
        ),
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.intention,
          id: 'intention',
          titleKey: 'spiritual.intention',
          version: '1',
          sourceId: 'product-spec',
        ),
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.meditation,
          id: 'meditation',
          titleKey: 'spiritual.meditation',
          version: '1',
          sourceId: 'product-spec',
        ),
        SpiritualToolDescriptor(
          kind: SpiritualToolKind.breathwork,
          id: 'breathwork',
          titleKey: 'spiritual.breathwork',
          version: '1',
          sourceId: 'product-spec',
        ),
      ]);

  TarotDeckDefinition deck() => TarotDeckDefinition(
        id: 'fixture-deck',
        version: 'fixture-v1',
        sourceId: 'fixture-only',
        cards: List.generate(
          5,
          (index) => TarotCardDefinition(
            id: 'card-$index',
            deckId: 'fixture-deck',
            titleKey: 'fixture.card.$index',
            version: 'fixture-v1',
            sourceId: 'fixture-only',
          ),
        ),
      );

  test('RC-0212/0213/0218-0223 registry keeps six tools distinct', () {
    final value = registry();
    expect(value.tools, hasLength(6));
    expect(value.byKind(SpiritualToolKind.tarot).id, 'tarot');
    expect(value.byKind(SpiritualToolKind.iChing).id, 'iching');
    expect(value.byKind(SpiritualToolKind.moonCycle).id, 'moon-cycle');
    expect(value.byKind(SpiritualToolKind.intention).id, 'intention');
    expect(value.byKind(SpiritualToolKind.meditation).id, 'meditation');
    expect(value.byKind(SpiritualToolKind.breathwork).id, 'breathwork');
  });

  test('registry fails closed when a required spiritual tool is missing', () {
    final all = registry().tools.toList()..removeLast();
    expect(() => SpiritualToolsRegistry(all), throwsArgumentError);
  });

  test('RC-0214 single-card Tarot draw is explicit and deterministic', () {
    final reading = const TarotDrawEngine().assemble(
      deck: deck(),
      spread: TarotSpreadDefinition.oneCard(
        version: '1',
        sourceId: 'product-spec',
      ),
      orderedCardIds: const ['card-2'],
    );
    expect(reading.slots, hasLength(1));
    expect(reading.slots.single.card.id, 'card-2');
    expect(reading.slots.single.position.key, 'single');
  });

  test('RC-0215 three-card Tarot draw keeps all positions', () {
    final reading = const TarotDrawEngine().assemble(
      deck: deck(),
      spread: TarotSpreadDefinition.threeCard(
        version: '1',
        sourceId: 'product-spec',
      ),
      orderedCardIds: const ['card-0', 'card-1', 'card-4'],
    );
    expect(reading.slots.map((slot) => slot.card.id),
        ['card-0', 'card-1', 'card-4']);
    expect(reading.slots.map((slot) => slot.position.key),
        ['first', 'second', 'third']);
  });

  test('RC-0216 larger Tarot spreads can be added as data', () {
    final spread = TarotSpreadDefinition(
      id: 'fixture.four-card',
      version: 'fixture-v1',
      sourceId: 'fixture-only',
      positions: List.generate(
        4,
        (index) => TarotSpreadPosition(
          key: 'p$index',
          titleKey: 'fixture.position.$index',
        ),
      ),
    );
    final reading = const TarotDrawEngine().assemble(
      deck: deck(),
      spread: spread,
      orderedCardIds: const ['card-0', 'card-1', 'card-2', 'card-3'],
    );
    expect(reading.slots, hasLength(4));
  });

  test('Tarot draw rejects duplicate, unknown, or wrong-size selections', () {
    final engine = const TarotDrawEngine();
    final spread = TarotSpreadDefinition.threeCard(
      version: '1',
      sourceId: 'product-spec',
    );
    expect(
      () => engine.assemble(
        deck: deck(),
        spread: spread,
        orderedCardIds: const ['card-0', 'card-0', 'card-1'],
      ),
      throwsArgumentError,
    );
    expect(
      () => engine.assemble(
        deck: deck(),
        spread: spread,
        orderedCardIds: const ['card-0', 'card-1', 'unknown'],
      ),
      throwsArgumentError,
    );
    expect(
      () => engine.assemble(
        deck: deck(),
        spread: spread,
        orderedCardIds: const ['card-0'],
      ),
      throwsArgumentError,
    );
  });

  test('RC-0217 Tarot interpretation requires editorial provenance', () {
    final entry = TarotInterpretationEntry(
      cardId: 'card-0',
      spreadPositionKey: 'single',
      locale: 'tr',
      body: 'Fixture-only symbolic reflection.',
      editorialPolicyId: 'symbolic-reflection-v1',
      version: 'fixture-v1',
      sourceId: 'fixture-only',
    );
    expect(TarotInterpretationCatalog([entry]).entries.single.sourceId,
        'fixture-only');
    expect(
      () => TarotInterpretationEntry(
        cardId: 'card-0',
        spreadPositionKey: 'single',
        locale: 'tr',
        body: 'x',
        editorialPolicyId: '',
        version: '1',
        sourceId: 'source',
      ),
      throwsArgumentError,
    );
  });

  test('RC-0218 I Ching request/result carry independent method provenance', () {
    final request = IChingReadingRequest(
      methodId: 'fixture-method',
      entropyToken: 'fixture-token',
    );
    final result = IChingReadingResult(
      hexagramId: 'fixture-hexagram',
      methodId: request.methodId,
      version: 'fixture-v1',
      sourceId: 'fixture-only',
    );
    expect(result.methodId, 'fixture-method');
    expect(result.hexagramId, 'fixture-hexagram');
  });

  test('RC-0219 moon guidance consumes pre-resolved astronomy provenance', () {
    final value = MoonCycleGuidance(
      phaseId: 'waxing-crescent',
      guidanceKey: 'fixture.moon.guidance',
      astronomySourceId: 'verified-upstream-fixture',
      editorialSourceId: 'fixture-editorial',
      version: 'fixture-v1',
    );
    expect(value.astronomySourceId, 'verified-upstream-fixture');
    expect(value.editorialSourceId, 'fixture-editorial');
  });

  test('RC-0220/0221 intention and daily intention are separate primitives', () {
    final practice = IntentionPractice(
      id: 'fixture-intention',
      titleKey: 'fixture.intention.title',
      promptKey: 'fixture.intention.prompt',
      version: 'fixture-v1',
      sourceId: 'fixture-only',
    );
    final daily = DailyIntention(
      localDateKey: '2026-09-07',
      practiceId: practice.id,
      text: 'Fixture user intention',
    );
    expect(daily.practiceId, practice.id);
    expect(
      () => DailyIntention(
        localDateKey: '07-09-2026',
        practiceId: practice.id,
        text: 'x',
      ),
      throwsArgumentError,
    );
  });

  test('RC-0222 meditation content requires positive duration/source', () {
    final value = MeditationContent(
      id: 'fixture-meditation',
      titleKey: 'fixture.meditation.title',
      durationSeconds: 300,
      contentKey: 'fixture.meditation.body',
      version: 'fixture-v1',
      sourceId: 'fixture-only',
    );
    expect(value.durationSeconds, 300);
    expect(
      () => MeditationContent(
        id: 'x',
        titleKey: 'x',
        durationSeconds: 0,
        contentKey: 'x',
        version: '1',
        sourceId: 'source',
      ),
      throwsArgumentError,
    );
  });

  test('RC-0223 breathwork requires instructions and safety note provenance', () {
    final value = BreathworkContent(
      id: 'fixture-breath',
      titleKey: 'fixture.breath.title',
      instructionsKey: 'fixture.breath.instructions',
      safetyNoteKey: 'fixture.breath.safety',
      version: 'fixture-v1',
      sourceId: 'fixture-only',
    );
    expect(value.safetyNoteKey, 'fixture.breath.safety');
    expect(
      () => BreathworkContent(
        id: 'x',
        titleKey: 'x',
        instructionsKey: 'x',
        safetyNoteKey: '',
        version: '1',
        sourceId: 'source',
      ),
      throwsArgumentError,
    );
  });
}
