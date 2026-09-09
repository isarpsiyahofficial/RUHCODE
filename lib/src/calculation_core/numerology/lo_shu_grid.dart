final class LoShuGridResult {
  LoShuGridResult({required Map<int, int> counts})
      : counts = Map.unmodifiable({for (var i = 1; i <= 9; i++) i: counts[i] ?? 0});

  final Map<int, int> counts;

  int operator [](int digit) {
    if (digit < 1 || digit > 9) throw RangeError.range(digit, 1, 9, 'digit');
    return counts[digit] ?? 0;
  }

  int countOf(int digit) => this[digit];

  List<List<int>> get layout => const [
        [4, 9, 2],
        [3, 5, 7],
        [8, 1, 6],
      ];

  List<List<int>> get canonicalGrid => layout;
}

/// RC-0185: Lo Shu uses the birth-date digit grid directly. It intentionally
/// does not use Pythagorean letter values or a reduced Life Path result.
abstract final class LoShuGridEngine {
  /// Accepts the canonical CivilDate value object as well as DateTime. Both
  /// expose integer year/month/day fields; keeping this boundary structural
  /// avoids coupling Lo Shu to a timezone-bearing DateTime representation.
  static LoShuGridResult calculate(Object birthDate) {
    final dynamic date = birthDate;
    final int day;
    final int month;
    final int year;
    try {
      day = date.day as int;
      month = date.month as int;
      year = date.year as int;
    } on Object {
      throw ArgumentError.value(
        birthDate,
        'birthDate',
        'Lo Shu requires a date value exposing integer year/month/day fields.',
      );
    }
    final raw = '${day.toString().padLeft(2, '0')}'
        '${month.toString().padLeft(2, '0')}'
        '${year.toString().padLeft(4, '0')}';
    final counts = <int, int>{};
    for (final char in raw.split('')) {
      final digit = int.parse(char);
      if (digit == 0) continue;
      counts[digit] = (counts[digit] ?? 0) + 1;
    }
    return LoShuGridResult(counts: counts);
  }
}

/// RC-0186 future-system boundary. Kabbalistic numerology is not an alias or
/// mode of Pythagorean/Chaldean/Lo Shu; any implementation must provide its own
/// source/version-tagged engine.
abstract interface class KabbalisticNumerologySystem<I, O> {
  String get systemId;
  String get version;
  String get sourceId;
  O calculate(I input);
}
