import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/architecture/calculation_interpretation_boundary.dart';

VerifiedCalculationFact fact(String id, String key) => VerifiedCalculationFact(
  id: id,
  domain: CalculationDomain.western,
  factKey: key,
  value: 'value-$key',
  sourceId: 'calculation-core',
  version: '1',
);

void main() {
  test('Daily message trace is deterministic for identical calculation conditions', () {
    final a = DeterministicDailyMessageTrace(
      calculationInputKey: 'utc=2026-09-08T00:00:00Z|profile=p1',
      factIds: const ['moon-1', 'transit-2'],
      ruleSetVersion: 'r1',
      catalogVersion: 'c1',
    );
    final b = DeterministicDailyMessageTrace(
      calculationInputKey: 'utc=2026-09-08T00:00:00Z|profile=p1',
      factIds: const ['moon-1', 'transit-2'],
      ruleSetVersion: 'r1',
      catalogVersion: 'c1',
    );
    expect(a.deterministicKey, b.deterministicKey);
  });

  test('Interpretation cannot invent a transit Dasha or numerology fact', () {
    final input = InterpretationInput(facts: [fact('f1', 'moon-sign')]);
    expect(() => input.requireFact('transit-saturn'), throwsStateError);
    expect(() => input.requireFact('dasha-active'), throwsStateError);
    expect(() => input.requireFact('personal-day'), throwsStateError);
  });

  test('Interpretation consumes verified objects and never raw user form data', () {
    const InterpretationPolicy(
      acceptsVerifiedObjectsOnly: true,
      acceptsRawUserForm: false,
      languageVariationCanChangeFacts: false,
    ).validate();
    expect(
      () => const InterpretationPolicy(
        acceptsVerifiedObjectsOnly: false,
        acceptsRawUserForm: true,
        languageVariationCanChangeFacts: true,
      ).validate(),
      throwsStateError,
    );
  });

  test('Calculation domains have independent calculation_core module paths', () {
    expect(CalculationLayerContract.modulePaths.keys.toSet(), CalculationDomain.values.toSet());
    expect(CalculationLayerContract.modulePaths[CalculationDomain.western], contains('/western'));
    expect(CalculationLayerContract.modulePaths[CalculationDomain.vedic], contains('/vedic'));
    expect(CalculationLayerContract.modulePaths[CalculationDomain.planetaryHours], contains('/planetary_hours'));
    expect(CalculationLayerContract.modulePaths[CalculationDomain.chinese], contains('/chinese'));
    expect(CalculationLayerContract.modulePaths[CalculationDomain.bazi], contains('/bazi'));
    expect(CalculationLayerContract.modulePaths[CalculationDomain.numerology], contains('/numerology'));
  });

  test('Tarot personal growth monetization PDF and UI stay outside calculation core', () {
    const contract = CalculationLayerContract();
    for (final concern in PresentationConcern.values) {
      expect(contract.concernBelongsInsideCalculationCore(concern), isFalse);
      contract.assertSeparated(concern);
    }
  });

  test('Duplicate calculation fact identity fails closed', () {
    expect(
      () => InterpretationInput(facts: [fact('same', 'a'), fact('same', 'b')]),
      throwsArgumentError,
    );
  });
}
