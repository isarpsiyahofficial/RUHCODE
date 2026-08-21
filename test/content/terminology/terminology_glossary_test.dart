import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/content/terminology/terminology_glossary.dart';

void main() {
  test('every canonical terminology ID has TR and EN labels', () {
    expect(() => RuhTerminologyGlossary.validateComplete(), returnsNormally);
    expect(
      RuhTerminologyGlossary.entries.length,
      TerminologyId.values.length,
    );
  });

  test('critical Western terminology stays fixed', () {
    expect(
      RuhTerminologyGlossary.label(TerminologyId.ascendant, 'en'),
      'Ascendant',
    );
    expect(
      RuhTerminologyGlossary.label(TerminologyId.ascendant, 'tr'),
      'Yükselen',
    );
    expect(RuhTerminologyGlossary.label(TerminologyId.house, 'en'), 'House');
    expect(RuhTerminologyGlossary.label(TerminologyId.house, 'tr'), 'Ev');
  });

  test('Vedik technical terminology is not arbitrarily renamed', () {
    expect(RuhTerminologyGlossary.label(TerminologyId.nakshatra, 'tr'), 'Nakshatra');
    expect(RuhTerminologyGlossary.label(TerminologyId.ayanamsha, 'tr'), 'Ayanamsha');
    expect(
      RuhTerminologyGlossary.entries[TerminologyId.lagna]!.preferredTechnicalLabel,
      'Lagna / Ascendant',
    );
  });

  test('numerology terminology is stable across the app', () {
    expect(RuhTerminologyGlossary.label(TerminologyId.lifePath, 'tr'), 'Yaşam Yolu');
    expect(RuhTerminologyGlossary.label(TerminologyId.personalDay, 'tr'), 'Kişisel Gün');
    expect(RuhTerminologyGlossary.label(TerminologyId.compatibility, 'en'), 'Compatibility');
  });

  test('unsupported locale fails closed instead of fallback leakage', () {
    expect(
      () => RuhTerminologyGlossary.label(TerminologyId.house, 'de'),
      throwsArgumentError,
    );
  });
}
