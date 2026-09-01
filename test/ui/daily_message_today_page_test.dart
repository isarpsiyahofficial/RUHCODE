import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/content/daily_messages/daily_message_catalog.dart';
import 'package:ruh_code/src/ui/daily_messages/daily_message_today_page.dart';

DailyMessageCatalog _catalog() {
  return DailyMessageCatalog([
    DailyMessageEntry(
      date: CivilDate(2026, 9, 1),
      localeTag: 'tr',
      title: 'Türkçe başlık',
      teaser: 'Türkçe kısa metin',
      fullText: 'Türkçe tam metin',
      themeTag: 'test',
    ),
    DailyMessageEntry(
      date: CivilDate(2026, 9, 1),
      localeTag: 'en',
      title: 'English title',
      teaser: 'English teaser',
      fullText: 'English full text',
      themeTag: 'test',
    ),
  ]);
}

Widget _app({required Locale locale, required DateTime now}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('tr'), Locale('en')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: DailyMessageTodayPage(
        catalog: _catalog(),
        clock: () => now,
      ),
    ),
  );
}

void main() {
  testWidgets('Today page uses exact local civil date and Turkish locale', (tester) async {
    await tester.pumpWidget(
      _app(locale: const Locale('tr'), now: DateTime(2026, 9, 1, 23, 59)),
    );

    expect(find.byKey(const ValueKey('daily-message-today')), findsOneWidget);
    expect(find.text('2026-09-01'), findsOneWidget);
    expect(find.text('Türkçe başlık'), findsOneWidget);
    expect(find.text('Türkçe tam metin'), findsOneWidget);
    expect(find.text('English title'), findsNothing);
  });

  testWidgets('non-Turkish UI uses independent English entry', (tester) async {
    await tester.pumpWidget(
      _app(locale: const Locale('en'), now: DateTime(2026, 9, 1, 8)),
    );

    expect(find.text('Message of the Day'), findsOneWidget);
    expect(find.text('English title'), findsOneWidget);
    expect(find.text('English full text'), findsOneWidget);
    expect(find.text('Türkçe başlık'), findsNothing);
  });

  testWidgets('missing exact date is fail-closed and does not fall back', (tester) async {
    await tester.pumpWidget(
      _app(locale: const Locale('en'), now: DateTime(2026, 9, 2, 8)),
    );

    expect(find.byKey(const ValueKey('daily-message-missing')), findsOneWidget);
    expect(find.text("Today's message is unavailable for this date."), findsOneWidget);
    expect(find.text('English title'), findsNothing);
  });
}
