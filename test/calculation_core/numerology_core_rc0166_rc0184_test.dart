import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/numerology_core.dart';

void main() {
  const profile = NumerologyMethodProfile(
    id: 'pythagorean-core-v1', version: '1', sourceId: 'requirement-fixture',
  );

  test('RC-0166/0170 Life Path and Birthday are deterministic', () {
    final birth = DateTime.utc(1990, 7, 28);
    expect(PythagoreanNumerologyCore.lifePath(birth, profile), 9);
    expect(PythagoreanNumerologyCore.birthday(birth, profile), 1);
  });

  test('RC-0167/0168/0169 name metrics use Pythagorean mapping', () {
    final alphabet = NumerologyAlphabet.pythagorean(sourceId: 'fixture');
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'Ada Lovelace', alphabet: alphabet, profile: profile,
    );
    expect(r.expression, isPositive);
    expect(r.soulUrge, isPositive);
    expect(r.personality, isPositive);
  });

  test('RC-0171 maturity combines Life Path and Expression', () {
    expect(PythagoreanNumerologyCore.maturity(lifePath: 9, expression: 7, profile: profile), 7);
  });

  test('RC-0172/0173/0175 derived name evidence is explicit', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.balance, isPositive);
    expect(r.karmicLessons, isNotEmpty);
    expect(r.hiddenPassion, isNotEmpty);
  });

  test('RC-0174 karmic debt candidates are not inferred after reduction', () {
    expect(PythagoreanNumerologyCore.karmicDebtNumbers([13, 14, 16, 19, 22]), {13,14,16,19});
  });

  test('RC-0176/0177/0178 personal periods calculate separately', () {
    final birth = DateTime.utc(1990, 7, 28);
    final date = DateTime.utc(2026, 9, 7);
    final y = PythagoreanNumerologyCore.personalYear(date: date, birthDate: birth, profile: profile);
    final m = PythagoreanNumerologyCore.personalMonth(date: date, birthDate: birth, profile: profile);
    final d = PythagoreanNumerologyCore.personalDay(date: date, birthDate: birth, profile: profile);
    expect([y,m,d].every((v) => v > 0), isTrue);
  });

  test('RC-0179/0180 Pinnacles and Challenges expose four periods', () {
    final r = PythagoreanNumerologyCore.periods(DateTime.utc(1990,7,28), profile);
    expect(r.pinnacles, hasLength(4));
    expect(r.challenges, hasLength(4));
  });

  test('RC-0181 compatibility is version/source-driven and bounded', () {
    final rule = NumerologyCompatibilityRule(
      id: 'fixture', version: '1', sourceId: 'fixture',
      evaluate: (a,b) => a == b ? 1 : 0.5,
    );
    expect(NumerologyCompatibilityEngine.evaluate(aLifePath: 3, bLifePath: 3, rule: rule), 1);
    expect(() => NumerologyCompatibilityEngine.evaluate(
      aLifePath: 3, bLifePath: 4,
      rule: NumerologyCompatibilityRule(id:'bad',version:'1',sourceId:'x',evaluate:(a,b)=>1.2),
    ), throwsStateError);
  });

  test('RC-0182/0183 Turkish characters are transliterated, not deleted', () {
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('Çağrı Işık'), 'CAGRII SIK'.replaceAll(' ', ''));
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('İÖŞÜÇĞ'), 'IOSUCG');
  });

  test('RC-0184 Chaldean table is structurally distinct from Pythagorean', () {
    final p = NumerologyAlphabet.pythagorean(sourceId: 'p');
    final c = NumerologyAlphabet.chaldean(sourceId: 'c');
    expect(p.id, isNot(c.id));
    expect(p.values['F'], 6);
    expect(c.values['F'], 8);
    expect(() => PythagoreanNumerologyCore.nameNumbers(fullName:'F', alphabet:c, profile:profile), throwsArgumentError);
  });
}
