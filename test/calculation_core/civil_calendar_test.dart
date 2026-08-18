import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('CivilCalendar leap-year rules', () {
    test('1900 is not a leap year', () {
      expect(CivilCalendar.isLeapYear(1900), isFalse);
      expect(CivilCalendar.daysInMonth(1900, 2), 28);
    });

    test('2000 is a leap year', () {
      expect(CivilCalendar.isLeapYear(2000), isTrue);
      expect(CivilCalendar.daysInMonth(2000, 2), 29);
    });

    test('2028, 2032 and 2036 are leap years', () {
      for (final year in [2028, 2032, 2036]) {
        expect(CivilCalendar.isLeapYear(year), isTrue, reason: '$year');
        expect(CivilCalendar.daysInMonth(year, 2), 29, reason: '$year');
      }
    });

    test('2100 is not a leap year', () {
      expect(CivilCalendar.isLeapYear(2100), isFalse);
      expect(CivilCalendar.daysInMonth(2100, 2), 28);
    });
  });

  group('CivilDate validation and transitions', () {
    test('leap day exists only in leap years', () {
      expect(CivilDate(2028, 2, 29).isoKey, '2028-02-29');
      expect(() => CivilDate(2027, 2, 29), throwsRangeError);
    });

    test('leap-year February rolls 28 -> 29 -> March 1', () {
      final feb28 = CivilDate(2028, 2, 28);
      expect(feb28.addDays(1), CivilDate(2028, 2, 29));
      expect(feb28.addDays(2), CivilDate(2028, 3, 1));
    });

    test('normal February rolls 28 -> March 1', () {
      expect(CivilDate(2027, 2, 28).addDays(1), CivilDate(2027, 3, 1));
    });

    test('month lengths are exact', () {
      expect(CivilCalendar.daysInMonth(2026, 1), 31);
      expect(CivilCalendar.daysInMonth(2026, 4), 30);
      expect(CivilCalendar.daysInMonth(2026, 6), 30);
      expect(CivilCalendar.daysInMonth(2026, 9), 30);
      expect(CivilCalendar.daysInMonth(2026, 11), 30);
      expect(CivilCalendar.daysInMonth(2026, 12), 31);
    });

    test('supported range is enforced', () {
      expect(() => CivilDate(1889, 12, 31), throwsRangeError);
      expect(CivilDate(1890, 1, 1).isoKey, '1890-01-01');
      expect(CivilDate(2110, 12, 31).isoKey, '2110-12-31');
      expect(() => CivilDate(2111, 1, 1), throwsRangeError);
    });
  });

  group('weekday and exact-date identity', () {
    test('16.08.2026 and 16.08.2027 remain distinct dates', () {
      final first = CivilDate(2026, 8, 16);
      final second = CivilDate(2027, 8, 16);

      expect(first.isoKey, '2026-08-16');
      expect(second.isoKey, '2027-08-16');
      expect(first, isNot(second));
      expect(CivilCalendar.daysBetween(first, second), 365);
      expect(first.weekday, CivilWeekday.sunday);
      expect(second.weekday, CivilWeekday.monday);
    });

    test('weekday calculation is ISO Monday=1 through Sunday=7', () {
      expect(CivilDate(2000, 1, 1).weekday, CivilWeekday.saturday);
      expect(CivilDate(2028, 2, 29).weekday, CivilWeekday.tuesday);
    });

    test('ISO keys parse and round trip without locale formatting', () {
      const key = '2032-02-29';
      expect(CivilDate.parseIso(key).isoKey, key);
      expect(() => CivilDate.parseIso('29.02.2032'), throwsFormatException);
      expect(() => CivilDate.parseIso('2032-2-29'), throwsFormatException);
    });
  });
}
