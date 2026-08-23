import '../time/civil_calendar.dart';

enum ChineseZodiacAnimal {
  rat,
  ox,
  tiger,
  rabbit,
  dragon,
  snake,
  horse,
  goat,
  monkey,
  rooster,
  dog,
  pig,
}

enum ChineseFiveElement {
  wood,
  fire,
  earth,
  metal,
  water,
}

enum ChinesePolarity {
  yang,
  yin,
}

/// Supplies the exact civil date on which the Chinese lunar year begins for a
/// Gregorian year.
///
/// The calculation engine deliberately does not infer Chinese New Year from the
/// Gregorian year number. Production must use a versioned, verified offline
/// boundary dataset (or another independently validated provider).
abstract interface class ChineseNewYearBoundaryProvider {
  String get sourceId;
  String get dataVersion;

  /// Returns the Chinese New Year boundary for [gregorianYear].
  ///
  /// Implementations must fail closed when the requested year is outside their
  /// verified coverage. Returning a guessed or nearest available date is not
  /// allowed.
  CivilDate boundaryForGregorianYear(int gregorianYear);
}

final class TabulatedChineseNewYearBoundaryProvider
    implements ChineseNewYearBoundaryProvider {
  TabulatedChineseNewYearBoundaryProvider({
    required this.sourceId,
    required this.dataVersion,
    required Map<int, CivilDate> boundaries,
  }) : _boundaries = Map.unmodifiable(Map<int, CivilDate>.from(boundaries)) {
    if (sourceId.trim().isEmpty) {
      throw ArgumentError.value(sourceId, 'sourceId', 'Must not be empty.');
    }
    if (dataVersion.trim().isEmpty) {
      throw ArgumentError.value(dataVersion, 'dataVersion', 'Must not be empty.');
    }
    if (_boundaries.isEmpty) {
      throw ArgumentError.value(boundaries, 'boundaries', 'Must not be empty.');
    }
    for (final entry in _boundaries.entries) {
      if (entry.value.year != entry.key) {
        throw ArgumentError(
          'Chinese New Year boundary key ${entry.key} must match date year '
          '${entry.value.year}.',
        );
      }
    }
  }

  @override
  final String sourceId;

  @override
  final String dataVersion;

  final Map<int, CivilDate> _boundaries;

  @override
  CivilDate boundaryForGregorianYear(int gregorianYear) {
    final value = _boundaries[gregorianYear];
    if (value == null) {
      throw StateError(
        'Chinese New Year boundary is unavailable for $gregorianYear; '
        'guessing or Gregorian-year fallback is forbidden.',
      );
    }
    return value;
  }
}

final class ChineseZodiacYearResult {
  const ChineseZodiacYearResult({
    required this.civilDate,
    required this.chineseYear,
    required this.sexagenaryIndex,
    required this.animal,
    required this.element,
    required this.polarity,
    required this.chineseNewYearBoundary,
    required this.sourceId,
    required this.dataVersion,
  });

  final CivilDate civilDate;
  final int chineseYear;
  final int sexagenaryIndex;
  final ChineseZodiacAnimal animal;
  final ChineseFiveElement element;
  final ChinesePolarity polarity;
  final CivilDate chineseNewYearBoundary;
  final String sourceId;
  final String dataVersion;
}

/// Strict basic Chinese zodiac year calculation.
///
/// This engine is intentionally separate from BaZi. It only resolves the
/// Chinese zodiac year animal, five-element quality and Yin/Yang polarity. It
/// does not calculate Four Pillars, solar terms, Day Master or Ten Gods.
final class ChineseZodiacYearEngine {
  const ChineseZodiacYearEngine({required this.boundaries});

  final ChineseNewYearBoundaryProvider boundaries;

  static const int _jiaZiAnchorYear = 1984;

  ChineseZodiacYearResult calculate(CivilDate date) {
    final boundary = boundaries.boundaryForGregorianYear(date.year);
    if (boundary.year != date.year) {
      throw StateError(
        'Chinese New Year provider returned ${boundary.isoKey} for ${date.year}.',
      );
    }

    final chineseYear = date.compareTo(boundary) < 0 ? date.year - 1 : date.year;
    final sexagenaryIndex = _positiveModulo(chineseYear - _jiaZiAnchorYear, 60);
    final stemIndex = sexagenaryIndex % 10;
    final branchIndex = sexagenaryIndex % 12;

    return ChineseZodiacYearResult(
      civilDate: date,
      chineseYear: chineseYear,
      sexagenaryIndex: sexagenaryIndex,
      animal: ChineseZodiacAnimal.values[branchIndex],
      element: _elementForStemIndex(stemIndex),
      polarity: stemIndex.isEven ? ChinesePolarity.yang : ChinesePolarity.yin,
      chineseNewYearBoundary: boundary,
      sourceId: boundaries.sourceId,
      dataVersion: boundaries.dataVersion,
    );
  }

  static ChineseFiveElement _elementForStemIndex(int stemIndex) {
    return switch (stemIndex ~/ 2) {
      0 => ChineseFiveElement.wood,
      1 => ChineseFiveElement.fire,
      2 => ChineseFiveElement.earth,
      3 => ChineseFiveElement.metal,
      4 => ChineseFiveElement.water,
      _ => throw StateError('Invalid Heavenly Stem index: $stemIndex'),
    };
  }

  static int _positiveModulo(int value, int modulus) {
    final result = value % modulus;
    return result < 0 ? result + modulus : result;
  }
}
