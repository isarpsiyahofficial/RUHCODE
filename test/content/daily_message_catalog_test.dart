import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_catalog.dart';

void main() {
  DailyMessageEntry entry({
    required int year,
    required int month,
    required int day,
    required String locale,
    String title = 'Başlık',
    String teaser = 'Kısa mesaj',
    String fullText = 'Tam mesaj metni.',
    String theme = 'denge',
  }) {
    return DailyMessageEntry(
      date: CivilDate(year, month, day),
      localeTag: locale,
      title: title,
      teaser: teaser,
      fullText: fullText,
      themeTag: theme,
    );
  }

  test('lookup uses exact YYYY-MM-DD plus locale key', () {
    final catalog = DailyMessageCatalog(<DailyMessageEntry>[
      entry(year: 2026, month: 8, day: 16, locale: 'tr'),
      entry(
        year: 2026,
        month: 8,
        day: 16,
        locale: 'en',
        title: 'Title',
        teaser: 'Short message',
        fullText: 'Full message.',
        theme: 'balance',
      ),
      entry(year: 2027, month: 8, day: 16, locale: 'tr', title: 'Başka Başlık'),
    ]);

    expect(
      catalog.require(date: CivilDate(2026, 8, 16), localeTag: 'tr').title,
      'Başlık',
    );
    expect(
      catalog.require(date: CivilDate(2026, 8, 16), localeTag: 'en').title,
      'Title',
    );
    expect(
      catalog.require(date: CivilDate(2027, 8, 16), localeTag: 'tr').title,
      'Başka Başlık',
    );
  });

  test('same date and locale duplicate is rejected', () {
    expect(
      () => DailyMessageCatalog(<DailyMessageEntry>[
        entry(year: 2026, month: 8, day: 16, locale: 'tr'),
        entry(year: 2026, month: 8, day: 16, locale: 'tr'),
      ]),
      throwsArgumentError,
    );
  });

  test('missing exact date never falls back to a random message', () {
    final catalog = DailyMessageCatalog(<DailyMessageEntry>[
      entry(year: 2026, month: 8, day: 16, locale: 'tr'),
    ]);
    expect(
      catalog.find(date: CivilDate(2026, 8, 17), localeTag: 'tr'),
      isNull,
    );
    expect(
      () => catalog.require(date: CivilDate(2026, 8, 17), localeTag: 'tr'),
      throwsStateError,
    );
  });

  test('29 February is a normal exact catalog key on leap years', () {
    final catalog = DailyMessageCatalog(<DailyMessageEntry>[
      entry(year: 2028, month: 2, day: 29, locale: 'tr'),
      entry(
        year: 2028,
        month: 2,
        day: 29,
        locale: 'en',
        title: 'Leap Day',
        teaser: 'Leap day teaser',
        fullText: 'Leap day full message.',
        theme: 'renewal',
      ),
    ]);
    expect(
      catalog.require(date: CivilDate(2028, 2, 29), localeTag: 'tr').key,
      '2028-02-29|tr',
    );
    expect(
      catalog.require(date: CivilDate(2028, 2, 29), localeTag: 'en').key,
      '2028-02-29|en',
    );
  });

  test('unsupported locale and blank content are rejected', () {
    expect(
      () => entry(year: 2026, month: 1, day: 1, locale: 'de'),
      throwsArgumentError,
    );
    expect(
      () => entry(
        year: 2026,
        month: 1,
        day: 1,
        locale: 'tr',
        teaser: '   ',
      ),
      throwsArgumentError,
    );
  });
}
