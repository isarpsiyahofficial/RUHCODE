import '../time/civil_calendar.dart';

final class LoShuGridResult {
  const LoShuGridResult({
    required this.birthDate,
    required this.counts,
  });

  final CivilDate birthDate;
  final Map<int, int> counts;

  int countOf(int number) {
    if (number < 1 || number > 9) {
      throw RangeError.range(number, 1, 9, 'number');
    }
    return counts[number] ?? 0;
  }

  /// Canonical Lo Shu visual order:
  /// 4 9 2
  /// 3 5 7
  /// 8 1 6
  List<List<int>> get canonicalGrid => const <List<int>>[
        <int>[4, 9, 2],
        <int>[3, 5, 7],
        <int>[8, 1, 6],
      ];
}

/// Lo Shu is intentionally independent from Pythagorean and Chaldean name
/// tables. The v1 input is the exact Gregorian birth date digits; zero has no
/// Lo Shu cell and is therefore ignored rather than remapped.
abstract final class LoShuGridEngine {
  static const String engineId = 'numerology.lo-shu.birth-grid';
  static const String engineVersion = '1';

  static LoShuGridResult calculate(CivilDate birthDate) {
    final counts = <int, int>{for (var number = 1; number <= 9; number++) number: 0};
    for (final digit in _birthDateDigits(birthDate)) {
      if (digit == 0) {
        continue;
      }
      counts[digit] = (counts[digit] ?? 0) + 1;
    }
    return LoShuGridResult(
      birthDate: birthDate,
      counts: Map<int, int>.unmodifiable(counts),
    );
  }

  static List<int> _birthDateDigits(CivilDate birthDate) {
    final text = '${birthDate.day.toString().padLeft(2, '0')}'
        '${birthDate.month.toString().padLeft(2, '0')}'
        '${birthDate.year.toString().padLeft(4, '0')}';
    return text.codeUnits.map((code) => code - 48).toList(growable: false);
  }
}