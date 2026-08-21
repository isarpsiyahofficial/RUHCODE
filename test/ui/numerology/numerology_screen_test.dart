import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/numerology/numerology_presentation.dart';
import 'package:ruh_code/src/ui/numerology/numerology_screen.dart';

void main() {
  const model = NumerologyPresentationModel(
    snapshotDigest: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    birthDateIso: '1990-05-19',
    targetDateIso: '2026-08-21',
    sections: <NumerologyPresentationSection>[
      NumerologyPresentationSection(
        sectionId: 'core',
        rows: <NumerologyPresentationRow>[
          NumerologyPresentationRow(metricId: 'life_path', value: '7'),
          NumerologyPresentationRow(metricId: 'expression', value: '5'),
        ],
      ),
      NumerologyPresentationSection(
        sectionId: 'personal_cycles',
        rows: <NumerologyPresentationRow>[
          NumerologyPresentationRow(metricId: 'personal_year', value: '1'),
          NumerologyPresentationRow(metricId: 'personal_day', value: '9'),
        ],
      ),
    ],
  );

  testWidgets('renders canonical presentation values with Turkish labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NumerologyScreen(model: model, locale: Locale('tr')),
      ),
    );

    expect(find.text('Numeroloji Sonuçları'), findsOneWidget);
    expect(find.text('Temel Sayılar'), findsOneWidget);
    expect(find.text('Yaşam Yolu'), findsOneWidget);
    expect(find.byKey(const Key('numerology-metric-life_path')), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.textContaining('Doğum tarihi: 1990-05-19'), findsOneWidget);
    expect(find.textContaining('Hedef tarih: 2026-08-21'), findsOneWidget);
    expect(find.text('life_path'), findsNothing);
  });

  testWidgets('renders the same values with independent English labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NumerologyScreen(model: model, locale: Locale('en')),
      ),
    );

    expect(find.text('Numerology Results'), findsOneWidget);
    expect(find.text('Core Numbers'), findsOneWidget);
    expect(find.text('Life Path'), findsOneWidget);
    expect(find.byKey(const Key('numerology-metric-life_path')), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Yaşam Yolu'), findsNothing);
  });

  testWidgets('shows a real empty state without fabricating calculation values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NumerologyScreen(model: null, locale: Locale('tr')),
      ),
    );

    expect(find.text('Henüz hesaplama yok'), findsOneWidget);
    expect(find.byKey(const Key('numerology-result-list')), findsNothing);
    expect(find.text('7'), findsNothing);
  });

  test('unknown locales fail closed instead of leaking fallback copy', () {
    expect(
      () => NumerologyScreenCopy.forLocale(const Locale('de')),
      throwsUnsupportedError,
    );
  });

  test('unknown presentation IDs fail closed instead of leaking technical IDs', () {
    final copy = NumerologyScreenCopy.forLocale(const Locale('tr'));
    expect(() => copy.metricLabel('unknown_metric'), throwsStateError);
    expect(() => copy.sectionLabel('unknown_section'), throwsStateError);
  });
}
