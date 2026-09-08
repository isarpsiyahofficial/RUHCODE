import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/interpretation/terminology_and_safety.dart';

void main() {
  test('core terminology is centralized and stable in TR/EN', () {
    final glossary = TerminologyGlossary.core();
    expect(glossary.require('ascendant').en, 'Ascendant');
    expect(glossary.require('ascendant').tr, 'Yükselen');
    expect(glossary.require('house').en, 'House');
    expect(glossary.require('house').tr, 'Ev');
    expect(glossary.require('nakshatra').keepTechnicalTerm, isTrue);
  });

  test('interpretation version is independent metadata from calculation engine', () {
    final rule = InterpretationRule(
      id: 'sun-aries-v1',
      interpretationVersion: 'interpretation-2026.09',
      subject: InterpretationSubject.sun,
      conditionKey: 'aries',
      templateTr: '{planet} Koç burcunda.',
      templateEn: '{planet} is in Aries.',
      allowedPlaceholders: const {'planet'},
    );
    expect(rule.interpretationVersion, 'interpretation-2026.09');
  });

  test('Sun in Aries rule cannot match Moon in Aries calculation fact', () {
    final rule = InterpretationRule(
      id: 'sun-aries',
      interpretationVersion: 'v1',
      subject: InterpretationSubject.sun,
      conditionKey: 'aries',
      templateTr: 'Güneş Koç burcunda.',
      templateEn: 'Sun is in Aries.',
      allowedPlaceholders: const {},
    );
    const matcher = InterpretationRuleMatcher();
    expect(
      () => matcher.requireMatch(
        rule: rule,
        calculatedSubject: InterpretationSubject.moon,
        calculatedConditionKey: 'aries',
      ),
      throwsStateError,
    );
  });

  test('unfilled placeholder never reaches rendered interpretation', () {
    final rule = InterpretationRule(
      id: 'planet-sign',
      interpretationVersion: 'v1',
      subject: InterpretationSubject.planet,
      conditionKey: 'aries',
      templateTr: '{planet} Koç burcunda.',
      templateEn: '{planet} is in Aries.',
      allowedPlaceholders: const {'planet'},
    );
    expect(() => rule.render(languageCode: 'tr', values: const {}), throwsStateError);
    expect(
      rule.render(languageCode: 'en', values: const {'planet': 'Mars'}),
      'Mars is in Aries.',
    );
  });

  test('composer removes repetition while preserving separate conflicting factors', () {
    const composer = InterpretationComposer();
    final output = composer.preserveConflictingFactors(const [
      'Factor A supports action.',
      'Factor B supports caution.',
      'Factor A supports action.',
    ]);
    expect(output, hasLength(2));
    expect(output[0], contains('action'));
    expect(output[1], contains('caution'));
  });

  test('astronomical data and traditional interpretation have separate labels', () {
    const policy = InterpretationSafetyPolicy();
    expect(policy.evidenceLabel('tr'), isNot(policy.traditionLabel('tr')));
    expect(policy.evidenceLabel('en'), isNot(policy.traditionLabel('en')));
  });

  test('medical legal financial and death certainty categories fail closed', () {
    const policy = InterpretationSafetyPolicy();
    for (final category in <InterpretationSafetyCategory>[
      InterpretationSafetyCategory.medicalDiagnosis,
      InterpretationSafetyCategory.legalCertainty,
      InterpretationSafetyCategory.financialGuarantee,
      InterpretationSafetyCategory.deathPrediction,
    ]) {
      expect(() => policy.requireAllowed(category), throwsStateError);
    }
    expect(() => policy.requireAllowed(InterpretationSafetyCategory.allowed), returnsNormally);
  });
}
