enum NumerologyReductionPolicy { preserve11_22_33, reduceAll }

final class NumerologyMethodProfile {
  const NumerologyMethodProfile({
    required this.id,
    required this.version,
    required this.sourceId,
    this.reductionPolicy = NumerologyReductionPolicy.preserve11_22_33,
  });

  final String id;
  final String version;
  final String sourceId;
  final NumerologyReductionPolicy reductionPolicy;

  void validate() {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Numerology method provenance must not be empty.');
    }
  }
}

abstract final class NumerologyReducer {
  static int reduce(int value, NumerologyMethodProfile profile) {
    profile.validate();
    var n = value.abs();
    while (n > 9) {
      if (profile.reductionPolicy == NumerologyReductionPolicy.preserve11_22_33 &&
          (n == 11 || n == 22 || n == 33)) {
        return n;
      }
      n = n.toString().split('').fold<int>(0, (a, b) => a + int.parse(b));
    }
    return n;
  }
}

final class NumerologyAlphabet {
  NumerologyAlphabet({
    required this.id,
    required this.version,
    required this.sourceId,
    required Map<String, int> values,
  }) : values = Map.unmodifiable(values.map((k, v) => MapEntry(k.toUpperCase(), v))) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Alphabet provenance must not be empty.');
    }
    if (this.values.isEmpty || this.values.values.any((v) => v < 1 || v > 9)) {
      throw ArgumentError('Alphabet values must be in 1..9.');
    }
  }

  final String id;
  final String version;
  final String sourceId;
  final Map<String, int> values;

  static NumerologyAlphabet pythagorean({required String sourceId}) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return NumerologyAlphabet(
      id: 'pythagorean-latin', version: '1', sourceId: sourceId,
      values: {for (var i = 0; i < letters.length; i++) letters[i]: (i % 9) + 1},
    );
  }

  static NumerologyAlphabet chaldean({required String sourceId}) => NumerologyAlphabet(
        id: 'chaldean-latin', version: '1', sourceId: sourceId,
        values: const {
          'A':1,'I':1,'J':1,'Q':1,'Y':1,
          'B':2,'K':2,'R':2,
          'C':3,'G':3,'L':3,'S':3,
          'D':4,'M':4,'T':4,
          'E':5,'H':5,'N':5,'X':5,
          'U':6,'V':6,'W':6,
          'O':7,'Z':7,
          'F':8,'P':8,
        },
      );
}

abstract final class NumerologyNameNormalizer {
  static const _tr = <String, String>{
    'Ç':'C','ç':'C','Ğ':'G','ğ':'G','İ':'I','I':'I','ı':'I','i':'I',
    'Ö':'O','ö':'O','Ş':'S','ş':'S','Ü':'U','ü':'U',
  };

  /// RC-0182/0183: Turkish letters are transliterated explicitly; they are not
  /// silently deleted. Unsupported non-letter symbols are separators.
  static String normalizeLatinTrEn(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _tr[char] ?? char.toUpperCase();
      if (RegExp(r'^[A-Z]$').hasMatch(mapped)) out.write(mapped);
    }
    return out.toString();
  }
}

final class NumerologyNameResult {
  const NumerologyNameResult({
    required this.expression,
    required this.soulUrge,
    required this.personality,
    required this.balance,
    required this.karmicLessons,
    required this.hiddenPassion,
  });
  final int expression;
  final int soulUrge;
  final int personality;
  final int balance;
  final Set<int> karmicLessons;
  final Set<int> hiddenPassion;
}

final class NumerologyPeriodResult {
  const NumerologyPeriodResult({required this.pinnacles, required this.challenges});
  final List<int> pinnacles;
  final List<int> challenges;
}

abstract final class PythagoreanNumerologyCore {
  static const _vowels = {'A','E','I','O','U','Y'};

  static int lifePath(DateTime birthDate, NumerologyMethodProfile profile) {
    final digits = '${birthDate.year.toString().padLeft(4,'0')}${birthDate.month.toString().padLeft(2,'0')}${birthDate.day.toString().padLeft(2,'0')}';
    final sum = digits.split('').fold<int>(0, (a, b) => a + int.parse(b));
    return NumerologyReducer.reduce(sum, profile);
  }

  static int birthday(DateTime birthDate, NumerologyMethodProfile profile) =>
      NumerologyReducer.reduce(birthDate.day, profile);

  static NumerologyNameResult nameNumbers({
    required String fullName,
    required NumerologyAlphabet alphabet,
    required NumerologyMethodProfile profile,
  }) {
    if (!alphabet.id.startsWith('pythagorean')) {
      throw ArgumentError('Pythagorean name metrics require a Pythagorean alphabet.');
    }
    final normalized = NumerologyNameNormalizer.normalizeLatinTrEn(fullName);
    if (normalized.isEmpty) throw ArgumentError('Name must contain supported letters.');
    final values = <int>[];
    final vowelValues = <int>[];
    final consonantValues = <int>[];
    final frequencies = <int, int>{};
    for (final c in normalized.split('')) {
      final value = alphabet.values[c];
      if (value == null) throw StateError('Missing Pythagorean mapping for $c');
      values.add(value);
      frequencies[value] = (frequencies[value] ?? 0) + 1;
      (_vowels.contains(c) ? vowelValues : consonantValues).add(value);
    }
    int reduced(List<int> v) => NumerologyReducer.reduce(v.fold(0, (a,b) => a+b), profile);
    final present = frequencies.keys.toSet();
    final maxFreq = frequencies.values.reduce((a,b) => a > b ? a : b);
    return NumerologyNameResult(
      expression: reduced(values),
      soulUrge: reduced(vowelValues),
      personality: reduced(consonantValues),
      balance: NumerologyReducer.reduce(values.first, profile),
      karmicLessons: {for (var i=1; i<=9; i++) if (!present.contains(i)) i},
      hiddenPassion: {for (final e in frequencies.entries) if (e.value == maxFreq) e.key},
    );
  }

  static int maturity({required int lifePath, required int expression, required NumerologyMethodProfile profile}) =>
      NumerologyReducer.reduce(lifePath + expression, profile);

  static Set<int> karmicDebtNumbers(Iterable<int> rawValues) =>
      rawValues.where((v) => const {13,14,16,19}.contains(v)).toSet();

  static int personalYear({required DateTime date, required DateTime birthDate, required NumerologyMethodProfile profile}) =>
      NumerologyReducer.reduce(birthDate.month + birthDate.day + date.year.toString().split('').fold<int>(0,(a,b)=>a+int.parse(b)), profile);

  static int personalMonth({required DateTime date, required DateTime birthDate, required NumerologyMethodProfile profile}) =>
      NumerologyReducer.reduce(personalYear(date: date, birthDate: birthDate, profile: profile) + date.month, profile);

  static int personalDay({required DateTime date, required DateTime birthDate, required NumerologyMethodProfile profile}) =>
      NumerologyReducer.reduce(personalMonth(date: date, birthDate: birthDate, profile: profile) + date.day, profile);

  static NumerologyPeriodResult periods(DateTime birthDate, NumerologyMethodProfile profile) {
    final m = NumerologyReducer.reduce(birthDate.month, profile);
    final d = NumerologyReducer.reduce(birthDate.day, profile);
    final y = NumerologyReducer.reduce(birthDate.year.toString().split('').fold<int>(0,(a,b)=>a+int.parse(b)), profile);
    final p1 = NumerologyReducer.reduce(m+d, profile);
    final p2 = NumerologyReducer.reduce(d+y, profile);
    final p3 = NumerologyReducer.reduce(p1+p2, profile);
    final p4 = NumerologyReducer.reduce(m+y, profile);
    int diff(int a, int b) => NumerologyReducer.reduce((a-b).abs(), profile);
    final c1 = diff(d,m), c2 = diff(d,y), c3 = diff(c1,c2), c4 = diff(m,y);
    return NumerologyPeriodResult(pinnacles: [p1,p2,p3,p4], challenges: [c1,c2,c3,c4]);
  }
}

final class NumerologyCompatibilityRule {
  NumerologyCompatibilityRule({required this.id, required this.version, required this.sourceId, required this.evaluate}) {
    if (id.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Compatibility rule provenance must not be empty.');
    }
  }
  final String id;
  final String version;
  final String sourceId;
  final double Function(int aLifePath, int bLifePath) evaluate;
}

abstract final class NumerologyCompatibilityEngine {
  static double evaluate({required int aLifePath, required int bLifePath, required NumerologyCompatibilityRule rule}) {
    final value = rule.evaluate(aLifePath, bLifePath);
    if (!value.isFinite || value < 0 || value > 1) throw StateError('Compatibility score must be within 0..1.');
    return value;
  }
}
