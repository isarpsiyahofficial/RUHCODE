import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/daily/today_temporal_contract.dart';

void main() {
  test('RC-1422 weekday comes from Gregorian engine and years are independent', () {
    expect(GregorianCalendarPolicy.weekday(year: 2026, month: 8, day: 16), 7);
    expect(GregorianCalendarPolicy.weekday(year: 2027, month: 8, day: 16), 1);
  });

  test('RC-1423 Gregorian leap-year behavior accepts only real leap days', () {
    expect(GregorianCalendarPolicy.isLeapYear(2028), isTrue);
    expect(GregorianCalendarPolicy.isLeapYear(2100), isFalse);
    expect(GregorianCalendarPolicy.isLeapYear(2000), isTrue);
    expect(
      () => GregorianCalendarPolicy.validateDate(year: 2028, month: 2, day: 29),
      returnsNormally,
    );
    expect(
      () => GregorianCalendarPolicy.validateDate(year: 2100, month: 2, day: 29),
      throwsArgumentError,
    );
  });

  test('RC-1421 active Today context requires explicit timezone and paired location', () {
    expect(
      () => TodayTemporalContext(
        localDateTime: DateTime(2026, 9, 9, 18, 54),
        timezoneId: '',
      ),
      throwsArgumentError,
    );
    expect(
      () => TodayTemporalContext(
        localDateTime: DateTime(2026, 9, 9, 18, 54),
        timezoneId: 'Europe/Istanbul',
        latitude: 36.89,
      ),
      throwsArgumentError,
    );
  });

  test('RC-1428 stock daily message and personal calculated effects stay separate', () {
    final context = TodayTemporalContext(
      localDateTime: DateTime(2026, 9, 9, 18, 54),
      timezoneId: 'Europe/Istanbul',
      latitude: 36.89,
      longitude: 30.70,
    );
    final bundle = TodayContentBundle(
      context: context,
      stockMessage: StockDailyMessage(
        isoDate: '2026-09-09',
        localeTag: 'tr',
        title: 'Günün temel mesajı',
        body: 'Editoryal stok içerik.',
      ),
      personalEffects: PersonalTodayEffects(
        calculationVersion: 'daily-core-v1',
        facts: const {'personalDay': 4, 'moonPhase': 'waxing'},
      ),
    );
    expect(bundle.stockMessage.body, 'Editoryal stok içerik.');
    expect(bundle.personalEffects.facts['personalDay'], 4);
  });

  test('RC-1427 date mismatch never falls back to a random stock message', () {
    final context = TodayTemporalContext(
      localDateTime: DateTime(2026, 9, 9),
      timezoneId: 'Europe/Istanbul',
    );
    expect(
      () => TodayContentBundle(
        context: context,
        stockMessage: StockDailyMessage(
          isoDate: '2026-09-10',
          localeTag: 'en',
          title: 'Base message',
          body: 'Editorial stock content.',
        ),
        personalEffects: PersonalTodayEffects(
          calculationVersion: 'daily-core-v1',
          facts: const {},
        ),
      ),
      throwsStateError,
    );
  });

  test('RC-1435 supported range is explicit and fails closed outside 1890-2110', () {
    expect(RuhSupportedDateRange.contains(DateTime(1890, 1, 1)), isTrue);
    expect(RuhSupportedDateRange.contains(DateTime(2110, 12, 31)), isTrue);
    expect(RuhSupportedDateRange.contains(DateTime(1889, 12, 31)), isFalse);
    expect(
      () => RuhSupportedDateRange.requireSupported(DateTime(2111, 1, 1)),
      throwsRangeError,
    );
  });
}
