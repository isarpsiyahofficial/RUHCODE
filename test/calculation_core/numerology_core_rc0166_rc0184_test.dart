import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/numerology_core.dart';

void main() {
  const profile = NumerologyMethodProfile(
    id: 'pythagorean-core-v1', version: '1', sourceId: 'requirement-fixture',
  );

  test('RC-0166 Life Path is deterministic', () {
    final birth = DateTime.utc(1990, 7, 28);
    expect(PythagoreanNumerologyCore.lifePath(birth, profile), 9);
  });

  test('RC-0167 Expression uses the Pythagorean name mapping', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.expression, 7);
  });

  test('RC-0168 Soul Urge uses vowels from the normalized TR/EN name', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.soulUrge, 1);
  });

  test('RC-0169 Personality uses consonants from the normalized TR/EN name', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.personality, 6);
  });

  test('RC-0170 Birthday is deterministic', () {
    expect(PythagoreanNumerologyCore.birthday(DateTime.utc(1990, 7, 28), profile), 1);
  });

  test('RC-0171 Maturity combines Life Path and Expression', () {
    expect(PythagoreanNumerologyCore.maturity(lifePath: 9, expression: 7, profile: profile), 7);
  });

  test('RC-0172 Balance Number reduces every name-component initial', () {
    final alphabet = NumerologyAlphabet.pythagorean(sourceId: 'fixture');
    final ada = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'Ada Lovelace', alphabet: alphabet, profile: profile,
    );
    final ipek = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen', alphabet: alphabet, profile: profile,
    );
    // A(1)+L(3)=4. I(9)+S(1)=10=>1. A first-letter-only
    // implementation would incorrectly return 1 and 9 respectively.
    expect(ada.balance, 4);
    expect(ipek.balance, 1);
  });

  test('RC-0173 Karmic Lessons are exactly the absent Pythagorean values', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.karmicLessons, <int>{3, 4, 6, 8});
  });

  test('RC-0174 Karmic Debt candidates are not inferred after reduction', () {
    expect(PythagoreanNumerologyCore.karmicDebtNumbers([13, 14, 16, 19, 22]), <int>{13,14,16,19});
    expect(PythagoreanNumerologyCore.karmicDebtNumbers([4, 5, 7, 1]), isEmpty);
  });

  test('RC-0175 Hidden Passion is exactly the most frequent value', () {
    final r = PythagoreanNumerologyCore.nameNumbers(
      fullName: 'İpek Şen',
      alphabet: NumerologyAlphabet.pythagorean(sourceId: 'fixture'),
      profile: profile,
    );
    expect(r.hiddenPassion, <int>{5});
  });

  test('RC-0176 Personal Year has an exact date fixture', () {
    expect(
      PythagoreanNumerologyCore.personalYear(
        date: DateTime.utc(2026, 9, 7),
        birthDate: DateTime.utc(1990, 7, 28),
        profile: profile,
      ),
      9,
    );
  });

  test('RC-0177 Personal Month has an exact date fixture', () {
    expect(
      PythagoreanNumerologyCore.personalMonth(
        date: DateTime.utc(2026, 9, 7),
        birthDate: DateTime.utc(1990, 7, 28),
        profile: profile,
      ),
      9,
    );
  });

  test('RC-0178 Personal Day has an exact date fixture', () {
    expect(
      PythagoreanNumerologyCore.personalDay(
        date: DateTime.utc(2026, 9, 7),
        birthDate: DateTime.utc(1990, 7, 28),
        profile: profile,
      ),
      7,
    );
  });

  test('RC-0179 Pinnacles expose four exact periods', () {
    final r = PythagoreanNumerologyCore.periods(DateTime.utc(1990,7,28), profile);
    expect(r.pinnacles, <int>[8, 2, 1, 8]);
  });

  test('RC-0180 Challenges expose four exact periods', () {
    final r = PythagoreanNumerologyCore.periods(DateTime.utc(1990,7,28), profile);
    expect(r.challenges, <int>[6, 0, 6, 6]);
  });

  test('RC-0181 compatibility is version/source-driven and bounded', () {
    final rule = NumerologyCompatibilityRule(
      id: 'fixture', version: '1', sourceId: 'fixture',
      evaluate: (a,b) => a == b ? 1 : 0.5,
    );
    expect(NumerologyCompatibilityEngine.evaluate(aLifePath: 3, bLifePath: 3, rule: rule), 1);
    expect(NumerologyCompatibilityEngine.evaluate(aLifePath: 3, bLifePath: 4, rule: rule), 0.5);
    expect(() => NumerologyCompatibilityEngine.evaluate(
      aLifePath: 3, bLifePath: 4,
      rule: NumerologyCompatibilityRule(id:'bad',version:'1',sourceId:'x',evaluate:(a,b)=>1.2),
    ), throwsStateError);
  });

  test('RC-0182 Turkish characters are transliterated rather than dropped', () {
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('Çağrı Işık'), 'CAGRIISIK');
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('İÖŞÜÇĞ'), 'IOSUCG');
  });

  test('RC-0183 TR and EN normalization rules remain explicit and deterministic', () {
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('Ada Lovelace'), 'ADALOVELACE');
    expect(NumerologyNameNormalizer.normalizeLatinTrEn('İpek Şen'), 'IPEKSEN');
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
