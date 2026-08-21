import '../time/civil_calendar.dart';
import 'personal_day.dart';

/// Explicit normalization policy for Turkish/English Pythagorean name math.
///
/// Turkish diacritics are transliterated to their Latin base letter because
/// the Pythagorean table is defined over A-Z. Unsupported letters are rejected
/// instead of being silently deleted or guessed.
abstract final class PythagoreanNameNormalizer {
  static const Map<String, String> _turkish = <String, String>{
    'ç': 'C',
    'Ç': 'C',
    'ğ': 'G',
    'Ğ': 'G',
    'ı': 'I',
    'I': 'I',
    'i': 'I',
    'İ': 'I',
    'ö': 'O',
    'Ö': 'O',
    'ş': 'S',
    'Ş': 'S',
    'ü': 'U',
    'Ü': 'U',
  };

  static const Set<String> _ignoredSeparators = <String>{
    ' ',
    '-',
    "'",
    '’',
    '.',
  };

  static String normalize(String input) {
    if (input.trim().isEmpty) {
      throw const FormatException('Numerology name cannot be blank.');
    }

    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final character = String.fromCharCode(rune);
      final turkish = _turkish[character];
      if (turkish != null) {
        buffer.write(turkish);
        continue;
      }
      if (_ignoredSeparators.contains(character)) {
        continue;
      }
      final upper = character.toUpperCase();
      if (upper.length == 1) {
        final code = upper.codeUnitAt(0);
        if (code >= 65 && code <= 90) {
          buffer.write(upper);
          continue;
        }
      }
      throw FormatException(
        'Unsupported character "$character" in Pythagorean name input.',
      );
    }

    final normalized = buffer.toString();
    if (normalized.isEmpty) {
      throw const FormatException('Numerology name has no supported letters.');
    }
    return normalized;
  }
}

/// Exact reduction history for a calculated numerology metric.
///
/// The trace preserves the unreduced source and every intermediate digit-sum
/// so downstream features such as Karmic Debt can use observed compounds
/// instead of reverse-inventing a compound from the final reduced number.
final class PythagoreanReductionTrace {
  const PythagoreanReductionTrace({
    required this.sourceValue,
    required this.steps,
    required this.reducedValue,
    required this.provenance,
  });

  final int sourceValue;
  final List<int> steps;
  final int reducedValue;
  final String provenance;

  Iterable<int> get observedCompounds sync* {
    for (final value in steps) {
      if (value > 9) yield value;
    }
  }
}

final class PythagoreanProfileResult {
  const PythagoreanProfileResult({
    required this.birthDate,
    required this.normalizedName,
    required this.policy,
    required this.lifePath,
    required this.expression,
    required this.soulUrge,
    required this.personality,
    required this.birthday,
    required this.maturity,
    required this.lifePathTrace,
    required this.expressionTrace,
    required this.soulUrgeTrace,
    required this.personalityTrace,
    required this.birthdayTrace,
    required this.maturityTrace,
  });

  final CivilDate birthDate;
  final String normalizedName;
  final PersonalCycleReductionPolicy policy;
  final int lifePath;
  final int expression;
  final int soulUrge;
  final int personality;
  final int birthday;
  final int maturity;

  final PythagoreanReductionTrace lifePathTrace;
  final PythagoreanReductionTrace expressionTrace;
  final PythagoreanReductionTrace soulUrgeTrace;
  final PythagoreanReductionTrace personalityTrace;
  final PythagoreanReductionTrace birthdayTrace;
  final PythagoreanReductionTrace maturityTrace;
}

abstract final class PythagoreanProfileEngine {
  static const String engineId = 'numerology.pythagorean.profile';
  static const String engineVersion = '2';
  static const Set<String> vowels = <String>{'A', 'E', 'I', 'O', 'U'};

  static PythagoreanProfileResult calculate({
    required CivilDate birthDate,
    required String fullName,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
  }) {
    final normalized = PythagoreanNameNormalizer.normalize(fullName);

    final reducedMonth = PythagoreanPersonalDayEngine.reduce(
      birthDate.month,
      policy: policy,
    );
    final reducedDay = PythagoreanPersonalDayEngine.reduce(
      birthDate.day,
      policy: policy,
    );
    final reducedYear = PythagoreanPersonalDayEngine.reduce(
      birthDate.year,
      policy: policy,
    );
    final lifePathTrace = _traceReduction(
      reducedMonth + reducedDay + reducedYear,
      policy: policy,
      provenance: 'life_path.reduced_month_day_year_sum',
    );

    final expressionTrace = _traceLetterTotal(
      normalized,
      policy: policy,
      provenance: 'expression.full_name_value_sum',
    );
    final soulUrgeTrace = _traceLetterTotal(
      normalized,
      policy: policy,
      provenance: 'soul_urge.vowel_value_sum',
      include: (letter) => vowels.contains(letter),
    );
    final personalityTrace = _traceLetterTotal(
      normalized,
      policy: policy,
      provenance: 'personality.consonant_value_sum',
      include: (letter) => !vowels.contains(letter),
    );
    final birthdayTrace = _traceReduction(
      birthDate.day,
      policy: policy,
      provenance: 'birthday.calendar_day',
    );
    final maturityTrace = _traceReduction(
      lifePathTrace.reducedValue + expressionTrace.reducedValue,
      policy: policy,
      provenance: 'maturity.life_path_plus_expression',
    );

    return PythagoreanProfileResult(
      birthDate: birthDate,
      normalizedName: normalized,
      policy: policy,
      lifePath: lifePathTrace.reducedValue,
      expression: expressionTrace.reducedValue,
      soulUrge: soulUrgeTrace.reducedValue,
      personality: personalityTrace.reducedValue,
      birthday: birthdayTrace.reducedValue,
      maturity: maturityTrace.reducedValue,
      lifePathTrace: lifePathTrace,
      expressionTrace: expressionTrace,
      soulUrgeTrace: soulUrgeTrace,
      personalityTrace: personalityTrace,
      birthdayTrace: birthdayTrace,
      maturityTrace: maturityTrace,
    );
  }

  static int letterValue(String uppercaseAsciiLetter) {
    if (uppercaseAsciiLetter.length != 1) {
      throw const FormatException('Pythagorean letter input must be one character.');
    }
    final code = uppercaseAsciiLetter.codeUnitAt(0);
    if (code < 65 || code > 90) {
      throw FormatException(
        'Pythagorean letter must be uppercase A-Z: $uppercaseAsciiLetter.',
      );
    }
    return ((code - 65) % 9) + 1;
  }

  static PythagoreanReductionTrace _traceLetterTotal(
    String normalized, {
    required PersonalCycleReductionPolicy policy,
    required String provenance,
    bool Function(String letter)? include,
  }) {
    var total = 0;
    for (final code in normalized.codeUnits) {
      final letter = String.fromCharCode(code);
      if (include == null || include(letter)) {
        total += letterValue(letter);
      }
    }
    if (total == 0) {
      throw const FormatException(
        'Numerology name does not contain letters for the requested calculation.',
      );
    }
    return _traceReduction(total, policy: policy, provenance: provenance);
  }

  static PythagoreanReductionTrace _traceReduction(
    int sourceValue, {
    required PersonalCycleReductionPolicy policy,
    required String provenance,
  }) {
    if (sourceValue <= 0) {
      throw RangeError.value(sourceValue, 'sourceValue', 'Must be positive.');
    }
    if (provenance.trim().isEmpty) {
      throw const FormatException('Reduction provenance cannot be blank.');
    }

    final steps = <int>[sourceValue];
    var current = sourceValue;
    while (!_isTerminal(current, policy)) {
      current = _digitSum(current);
      steps.add(current);
    }

    return PythagoreanReductionTrace(
      sourceValue: sourceValue,
      steps: List<int>.unmodifiable(steps),
      reducedValue: current,
      provenance: provenance,
    );
  }

  static bool _isTerminal(
    int value,
    PersonalCycleReductionPolicy policy,
  ) {
    if (value >= 1 && value <= 9) return true;
    if (policy == PersonalCycleReductionPolicy.preserveMasterNumbers &&
        (value == 11 || value == 22 || value == 33)) {
      return true;
    }
    return false;
  }

  static int _digitSum(int value) {
    var remaining = value;
    var sum = 0;
    while (remaining > 0) {
      sum += remaining % 10;
      remaining ~/= 10;
    }
    return sum;
  }
}