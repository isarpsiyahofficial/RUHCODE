import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/numerology/numerology_presentation.dart';
import 'package:ruh_code/src/ui/numerology/numerology_screen.dart';
import 'package:ruh_code/src/ui/pdf/pdf_reports_pages.dart';
import 'package:ruh_code/src/ui/pdf/professional_pdf_ui_actions.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: RuhAppTheme.light(),
      home: home,
    );

void main() {
  testWidgets('numerology result exposes localized metric semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    const model = NumerologyPresentationModel(
      snapshotDigest: 'digest',
      birthDateIso: '1990-05-19',
      targetDateIso: '2026-08-23',
      sections: <NumerologyPresentationSection>[
        NumerologyPresentationSection(
          sectionId: 'core',
          rows: <NumerologyPresentationRow>[
            NumerologyPresentationRow(metricId: 'life_path', value: '7'),
          ],
        ),
      ],
    );

    await tester.pumpWidget(_app(const NumerologyScreen(model: model)));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Yaşam Yolu: 7'), findsOneWidget);
    expect(find.text('Yaşam Yolu'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('professional PDF create and share controls expose semantics and 48dp targets', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        ProfessionalPdfBuilderPage(
          actions: _BuildActions(),
          records: _RecordActions(),
          deliveryActions: _DeliveryActions(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final create = find.byKey(const ValueKey(RuhActionIds.pdfCreate));
    expect(create, findsOneWidget);
    expect(find.bySemanticsLabel('PDF Oluştur'), findsOneWidget);
    expect(tester.getSize(create).height, greaterThanOrEqualTo(48));

    await tester.tap(find.byKey(const ValueKey('professional-pdf-record-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('numerology.pythagorean').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      create,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(create);
    await tester.pumpAndSettle();

    final share = find.byKey(const ValueKey(RuhActionIds.pdfShare));
    await tester.scrollUntilVisible(
      share,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(share, findsOneWidget);
    expect(find.bySemanticsLabel('PDF Paylaş'), findsOneWidget);
    expect(tester.getSize(share).height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });
}

final class _BuildActions implements ProfessionalPdfBuildActions {
  @override
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async => const ProfessionalPdfUiBuildResult(byteLength: 4096, pageCount: 2);
}

final class _DeliveryActions implements ProfessionalPdfDeliveryActions {
  @override
  Future<ProfessionalPdfUiDeliveryResult> save({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async => const ProfessionalPdfUiDeliveryResult(
        outcome: ProfessionalPdfUiDeliveryOutcome.success,
      );

  @override
  Future<ProfessionalPdfUiDeliveryResult> share({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async => const ProfessionalPdfUiDeliveryResult(
        outcome: ProfessionalPdfUiDeliveryOutcome.success,
      );
}

final class _RecordActions implements ProfessionalPdfRecordActions {
  @override
  Future<List<ProfessionalPdfUiRecord>> listRecords() async => <ProfessionalPdfUiRecord>[
        ProfessionalPdfUiRecord(
          recordId: 'calc-42',
          ownerEntityId: 'owner-1',
          calculationType: 'numerology.pythagorean',
          createdAtUtc: DateTime.utc(2026, 8, 23, 0, 30),
        ),
      ];
}
