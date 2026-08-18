import 'civil_calendar.dart';

abstract final class JulianDay {
  static double fromUtc(DateTime utcInstant) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected a UTC instant.');
    }
    final date = CivilDate(utcInstant.year, utcInstant.month, utcInstant.day);
    final seconds = utcInstant.hour * 3600 +
        utcInstant.minute * 60 +
        utcInstant.second +
        utcInstant.millisecond / 1000.0 +
        utcInstant.microsecond / 1000000.0;
    return fromCivilDate(date, utHours: seconds / 3600.0);
  }

  static double fromCivilDate(CivilDate date, {double utHours = 0}) {
    if (!utHours.isFinite || utHours < 0 || utHours >= 24) {
      throw RangeError.range(utHours, 0, 24, 'utHours', 'Expected 0 <= UT < 24.');
    }

    var year = date.year;
    var month = date.month;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final century = (year / 100).floor();
    final gregorianCorrection = 2 - century + (century / 4).floor();
    final wholeDays = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        date.day +
        gregorianCorrection -
        1524.5;
    return wholeDays + utHours / 24.0;
  }

  static double modified(double julianDay) => julianDay - 2400000.5;

  static double centuriesSinceJ2000(double julianDay) =>
      (julianDay - 2451545.0) / 36525.0;
}
