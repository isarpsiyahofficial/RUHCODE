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
}

abstract final class PythagoreanProfileEngine {
  static const String engineId = 'numerology.pythagorean.profile';
  static const String engineVersion = '1';
  static const Set<String> vowels = <String>{'A', 'E', 'I', 'O', 'U'};

  static PythagoreanProfileResult calculate({
    required CivilDate birthDate,
    required String fullName,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
  }) {
    final normalized = PythagoreanNameNormalizer.normalize(fullName);
    final lifePath = _lifePath(birthDate, policy);
    final expression = _reduceLetterTotal(normalized, policy: policy);
    final soulUrge = _reduceLetterTotal(
      normalized,
      policy: policy,
      include: (letter) => vowels.contains(letter),
    );
    final personality = _reduceLetterTotal(
      normalized,
      policy: policy,
      include: (letter) => !vowels.contains(letter),
    );
    final birthday = PythagoreanPersonalDayEngine.reduce(
      birthDate.day,
      policy: policy,
    );
    final maturity = PythagoreanPersonalDayEngine.reduce(
      lifePath + expression,
      policy: policy,
    );

    return PythagoreanProfileResult(
      birthDate: birthDate,
      normalizedName: normalized,
      policy: policy,
      lifePath: lifePath,
      expression: expression,
      soulUrge: soulUrge,
      personality: personality,
      birthday: birthday,
      maturity: maturity,
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

  static int _lifePath(
    CivilDate birthDate,
    PersonalCycleReductionPolicy policy,
  ) {
    final month = PythagoreanPersonalDayEngine.reduce(
      birthDate.month,
      policy: policy,
    );
    final day = PythagoreanPersonalDayEngine.reduce(
      birthDate.day,
      policy: policy,
    );
    final year = PythagoreanPersonalDayEngine.reduce(
      birthDate.year,
      policy: policy,
    );
    return PythagoreanPersonalDayEngine.reduce(
      month + day + year,
      policy: policy,
    );
  }

  static int _reduceLetterTotal(
    String normalized, {
    required PersonalCycleReductionPolicy policy,
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
    return PythagoreanPersonalDayEngine.reduce(total, policy: policy);
  }
}