import 'julian_day.dart';

final class TaiUtcSegment {
  const TaiUtcSegment({
    required this.effectiveFromUtc,
    required this.taiMinusUtcSeconds,
  });

  final DateTime effectiveFromUtc;
  final int taiMinusUtcSeconds;
}

/// Versioned UTC/TAI knowledge used by the astronomical core.
///
/// UTC leap seconds are not predictable. The built-in table therefore has an
/// explicit validity horizon instead of silently assuming that the latest
/// TAI-UTC value remains true forever. Releases must refresh this table from
/// IERS Bulletin C before extending [validUntilUtcExclusive].
abstract final class UtcTaiOffsetTable {
  static final DateTime validFromUtc = DateTime.utc(1972, 1, 1);

  /// IERS Bulletin C 72 states that no leap second will be introduced at the
  /// end of December 2026. A leap second cannot then occur before the next
  /// possible insertion point at the end of June 2027, so this table is safe
  /// for ordinary UTC instants strictly before 2027-07-01T00:00:00Z.
  static final DateTime validUntilUtcExclusive = DateTime.utc(2027, 7, 1);

  static final List<TaiUtcSegment> segments = List.unmodifiable(<TaiUtcSegment>[
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1972, 1, 1), taiMinusUtcSeconds: 10),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1972, 7, 1), taiMinusUtcSeconds: 11),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1973, 1, 1), taiMinusUtcSeconds: 12),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1974, 1, 1), taiMinusUtcSeconds: 13),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1975, 1, 1), taiMinusUtcSeconds: 14),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1976, 1, 1), taiMinusUtcSeconds: 15),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1977, 1, 1), taiMinusUtcSeconds: 16),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1978, 1, 1), taiMinusUtcSeconds: 17),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1979, 1, 1), taiMinusUtcSeconds: 18),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1980, 1, 1), taiMinusUtcSeconds: 19),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1981, 7, 1), taiMinusUtcSeconds: 20),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1982, 7, 1), taiMinusUtcSeconds: 21),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1983, 7, 1), taiMinusUtcSeconds: 22),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1985, 7, 1), taiMinusUtcSeconds: 23),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1988, 1, 1), taiMinusUtcSeconds: 24),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1990, 1, 1), taiMinusUtcSeconds: 25),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1991, 1, 1), taiMinusUtcSeconds: 26),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1992, 7, 1), taiMinusUtcSeconds: 27),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1993, 7, 1), taiMinusUtcSeconds: 28),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1994, 7, 1), taiMinusUtcSeconds: 29),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1996, 1, 1), taiMinusUtcSeconds: 30),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1997, 7, 1), taiMinusUtcSeconds: 31),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(1999, 1, 1), taiMinusUtcSeconds: 32),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(2006, 1, 1), taiMinusUtcSeconds: 33),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(2009, 1, 1), taiMinusUtcSeconds: 34),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(2012, 7, 1), taiMinusUtcSeconds: 35),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(2015, 7, 1), taiMinusUtcSeconds: 36),
    TaiUtcSegment(effectiveFromUtc: DateTime.utc(2017, 1, 1), taiMinusUtcSeconds: 37),
  ]);

  static int taiMinusUtcSeconds(DateTime utcInstant) {
    _requireCoveredUtcInstant(utcInstant);
    for (var index = segments.length - 1; index >= 0; index -= 1) {
      final segment = segments[index];
      if (!utcInstant.isBefore(segment.effectiveFromUtc)) {
        return segment.taiMinusUtcSeconds;
      }
    }
    throw StateError('No TAI-UTC segment matched a covered UTC instant.');
  }

  static void _requireCoveredUtcInstant(DateTime utcInstant) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected a UTC instant.');
    }
    if (utcInstant.isBefore(validFromUtc) ||
        !utcInstant.isBefore(validUntilUtcExclusive)) {
      throw RangeError(
        'UTC instant is outside the bundled leap-second knowledge horizon: '
        '${validFromUtc.toIso8601String()} <= UTC < '
        '${validUntilUtcExclusive.toIso8601String()}.',
      );
    }
  }
}

abstract final class TimeScales {
  static const double ttMinusTaiSeconds = 32.184;
  static const double secondsPerDay = 86400.0;

  static double ttMinusUtcSeconds(DateTime utcInstant) =>
      UtcTaiOffsetTable.taiMinusUtcSeconds(utcInstant) + ttMinusTaiSeconds;

  /// Converts an ordinary representable UTC instant to Julian Date on TT.
  ///
  /// Dart DateTime cannot represent the UTC label 23:59:60 itself. Callers
  /// must not use this method as a representation of the inserted leap-second
  /// label; normal instants on either side are handled by the offset segments.
  static double ttJulianDayFromUtc(DateTime utcInstant) {
    final utcJulianDay = JulianDay.fromUtc(utcInstant);
    return utcJulianDay + ttMinusUtcSeconds(utcInstant) / secondsPerDay;
  }
}
