enum CivilWeekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  const CivilWeekday(this.isoNumber);
  final int isoNumber;

  static CivilWeekday fromIsoNumber(int value) {
    if (value < 1 || value > 7) {
      throw RangeError.range(value, 1, 7, 'value');
    }
    return CivilWeekday.values[value - 1];
  }
}

final class CivilDate implements Comparable<CivilDate> {
  const CivilDate._(this.year, this.month, this.day);

  factory CivilDate(int year, int month, int day) {
    CivilCalendar.validateDate(year, month, day);
    return CivilDate._(year, month, day);
  }

  factory CivilDate.parseIso(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected YYYY-MM-DD civil date.', value);
    }
    return CivilDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int year;
  final int month;
  final int day;

  CivilWeekday get weekday => CivilCalendar.weekdayOf(this);
  String get isoKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  CivilDate addDays(int days) {
    final utc = DateTime.utc(year, month, day).add(Duration(days: days));
    return CivilDate(utc.year, utc.month, utc.day);
  }

  @override
  int compareTo(CivilDate other) {
    final yearCompare = year.compareTo(other.year);
    if (yearCompare != 0) return yearCompare;
    final monthCompare = month.compareTo(other.month);
    if (monthCompare != 0) return monthCompare;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => isoKey;
}

abstract final class CivilCalendar {
  static const int minimumSupportedYear = 1890;
  static const int maximumSupportedYear = 2110;

  static bool isLeapYear(int year) {
    _validateYear(year);
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  static int daysInMonth(int year, int month) {
    _validateYear(year);
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return switch (month) {
      2 => isLeapYear(year) ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
  }

  static bool isValidDate(int year, int month, int day) {
    if (year < minimumSupportedYear || year > maximumSupportedYear) {
      return false;
    }
    if (month < 1 || month > 12) return false;
    return day >= 1 && day <= daysInMonth(year, month);
  }

  static void validateDate(int year, int month, int day) {
    _validateYear(year);
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    final maximumDay = daysInMonth(year, month);
    if (day < 1 || day > maximumDay) {
      throw RangeError.range(day, 1, maximumDay, 'day');
    }
  }

  static CivilWeekday weekdayOf(CivilDate date) {
    // DateTime.utc is only used after strict civil-date validation. This keeps
    // weekday calculation independent from device locale and local timezone.
    final isoWeekday = DateTime.utc(date.year, date.month, date.day).weekday;
    return CivilWeekday.fromIsoNumber(isoWeekday);
  }

  static int daysBetween(CivilDate start, CivilDate end) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    return endUtc.difference(startUtc).inDays;
  }

  static void _validateYear(int year) {
    if (year < minimumSupportedYear || year > maximumSupportedYear) {
      throw RangeError.range(
        year,
        minimumSupportedYear,
        maximumSupportedYear,
        'year',
      );
    }
  }
}
