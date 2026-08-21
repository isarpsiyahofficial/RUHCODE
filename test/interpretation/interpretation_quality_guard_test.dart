import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/interpretation/interpretation_engine.dart';

void main() {
  test('accepts versioned unique interpretation bundle', () {
    const bundle = InterpretationBundle(
      items: <String>[
        'İlk yorum cümlesi.',
        'İkinci yorum cümlesi.',
      ],
      sourceRuleIds: <String>['rule.1', 'rule.2'],
      interpretationVersion: 'catalog.v1',
    );

    expect(() => InterpretationQualityGuard.validate(bundle), returnsNormally);
  });

  test('rejects unspecified version and item/rule length mismatch', () {
    const unspecified = InterpretationBundle(
      items: <String>['Metin.'],
      sourceRuleIds: <String>['rule.1'],
    );
    const mismatch = InterpretationBundle(
      items: <String>['Metin.', 'İkinci.'],
      sourceRuleIds: <String>['rule.1'],
      interpretationVersion: 'catalog.v1',
    );

    expect(
      () => InterpretationQualityGuard.validate(unspecified),
      throwsA(isA<InterpretationQualityException>()),
    );
    expect(
      () => InterpretationQualityGuard.validate(mismatch),
      throwsA(isA<InterpretationQualityException>()),
    );
  });

  test('rejects unresolved placeholders and duplicate rule IDs', () {
    const placeholder = InterpretationBundle(
      items: <String>['Bugün {planet} etkisi belirgin.'],
      sourceRuleIds: <String>['rule.planet'],
      interpretationVersion: 'catalog.v1',
    );
    const duplicateRule = InterpretationBundle(
      items: <String>['Birinci.', 'İkinci.'],
      sourceRuleIds: <String>['rule.same', 'rule.same'],
      interpretationVersion: 'catalog.v1',
    );

    expect(
      () => InterpretationQualityGuard.validate(placeholder),
      throwsA(isA<InterpretationQualityException>()),
    );
    expect(
      () => InterpretationQualityGuard.validate(duplicateRule),
      throwsA(isA<InterpretationQualityException>()),
    );
  });

  test('rejects duplicate normalized items', () {
    const bundle = InterpretationBundle(
      items: <String>['Aynı yorum.', '  aynı   yorum.  '],
      sourceRuleIds: <String>['rule.1', 'rule.2'],
      interpretationVersion: 'catalog.v1',
    );

    expect(
      () => InterpretationQualityGuard.validate(bundle),
      throwsA(isA<InterpretationQualityException>()),
    );
  });

  test('rejects repeated sentence beyond configured frequency', () {
    const bundle = InterpretationBundle(
      items: <String>[
        'Ortak cümle. İlk ek bilgi.',
        'Ortak cümle. İkinci ek bilgi.',
        'Ortak cümle. Üçüncü ek bilgi.',
      ],
      sourceRuleIds: <String>['rule.1', 'rule.2', 'rule.3'],
      interpretationVersion: 'catalog.v1',
    );

    expect(
      () => InterpretationQualityGuard.validate(bundle),
      throwsA(isA<InterpretationQualityException>()),
    );
  });
}
