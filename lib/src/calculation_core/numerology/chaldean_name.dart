import 'personal_day.dart';
import 'pythagorean_profile.dart';

final class ChaldeanNameResult {
  const ChaldeanNameResult({
    required this.normalizedName,
    required this.compoundTotal,
    required this.reducedNumber,
    required this.policy,
  });

  final String normalizedName;
  final int compoundTotal;
  final int reducedNumber;
  final PersonalCycleReductionPolicy policy;
}

/// Chaldean name-number engine with its own canonical letter table.
///
/// It intentionally does not call [PythagoreanProfileEngine.letterValue].
/// Both systems may share the explicit TR/EN normalization contract, but the
/// numeric tables remain independent as required by the master specification.
abstract final class ChaldeanNameEngine {
  static const String engineId = 'numerology.chaldean.name';
  static const String engineVersion = '1';

  static const Map<String, int> letterValues = <String, int>{
    'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
    'B': 2, 'K': 2, 'R': 2,
    'C': 3, 'G': 3, 'L': 3, 'S': 3,
    'D': 4, 'M': 4, 'T': 4,
    'E': 5, 'H': 5, 'N': 5, 'X': 5,
    'U': 6, 'V': 6, 'W': 6,
    'O': 7, 'Z': 7,
    'F': 8, 'P': 8,
  };

  static ChaldeanNameResult calculate({
    required String fullName,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
  }) {
    final normalized = PythagoreanNameNormalizer.normalize(fullName);
    var total = 0;
    for (final code in normalized.codeUnits) {
      final letter = String.fromCharCode(code);
      final value = letterValues[letter];
      if (value == null) {
        throw FormatException('Chaldean table has no value for $letter.');
      }
      total += value;
    }
    if (total <= 0) {
      throw const FormatException('Chaldean name total must be positive.');
    }
    return ChaldeanNameResult(
      normalizedName: normalized,
      compoundTotal: total,
      reducedNumber: PythagoreanPersonalDayEngine.reduce(total, policy: policy),
      policy: policy,
    );
  }

  static int letterValue(String uppercaseAsciiLetter) {
    final value = letterValues[uppercaseAsciiLetter];
    if (value == null) {
      throw FormatException(
        'Chaldean letter must be an uppercase supported A-Z letter: $uppercaseAsciiLetter.',
      );
    }
    return value;
  }
}