import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/content/interpretation_catalog_policy.dart';

void main() {
  InterpretationEntry entry(InterpretationSystem system, String condition) =>
      InterpretationEntry(
        id: '${system.name}-$condition',
        system: system,
        conditionId: condition,
        summary: 'Readable summary',
        technical: 'Technical interpretation',
        sourceId: 'editorial-source',
        version: '1.0.0',
      );

  test('system catalogs cannot be mixed', () {
    expect(
      () => InterpretationCatalog(
        system: InterpretationSystem.western,
        entries: [entry(InterpretationSystem.vedic, 'sun.aries')],
      ),
      throwsArgumentError,
    );
  });

  test('same generic text cannot ambiguously cover multiple conditions', () {
    final first = entry(InterpretationSystem.western, 'sun.aries');
    final second = InterpretationEntry(
      id: 'different-id',
      system: InterpretationSystem.western,
      conditionId: 'sun.aries',
      summary: 'Readable summary',
      technical: 'Technical interpretation',
      sourceId: 'editorial-source',
      version: '1.0.0',
    );
    expect(
      () => InterpretationCatalog(
        system: InterpretationSystem.western,
        entries: [first, second],
      ),
      throwsArgumentError,
    );
  });

  test('registry resolves only exact system and calculation condition', () {
    final registry = InterpretationRegistry([
      InterpretationCatalog(
        system: InterpretationSystem.western,
        entries: [entry(InterpretationSystem.western, 'saturn.house7')],
      ),
      InterpretationCatalog(
        system: InterpretationSystem.vedic,
        entries: [entry(InterpretationSystem.vedic, 'saturn.house7')],
      ),
    ]);
    expect(
      registry.resolve(
        system: InterpretationSystem.western,
        conditionId: 'saturn.house7',
      )?.system,
      InterpretationSystem.western,
    );
  });

  test('normal user gets summary before technical/raw data', () {
    final result = InterpretationPresenter.compose(
      entry: entry(InterpretationSystem.bazi, 'day-master.yang-fire'),
      audience: InterpretationAudience.normal,
      rawCalculation: const {'stem': 'Bing'},
    );
    expect(result.summary, isNotEmpty);
    expect(result.technical, isNull);
    expect(result.rawCalculation, isNull);
  });

  test('detailed user can descend into technical and raw calculation data', () {
    final result = InterpretationPresenter.compose(
      entry: entry(InterpretationSystem.numerology, 'life-path.7'),
      audience: InterpretationAudience.detailed,
      rawCalculation: const {'lifePath': 7},
    );
    expect(result.technical, isNotNull);
    expect(result.rawCalculation?['lifePath'], 7);
  });

  test('professional can hide prepared interpretation without hiding raw data', () {
    final result = InterpretationPresenter.compose(
      entry: entry(InterpretationSystem.western, 'saturn.square.sun'),
      audience: InterpretationAudience.professional,
      rawCalculation: const {'orb': 0.7, 'applying': true},
      professionalPreparedInterpretationEnabled: false,
    );
    expect(result.preparedInterpretationVisible, isFalse);
    expect(result.summary, isEmpty);
    expect(result.rawCalculation?['applying'], isTrue);
  });
}
