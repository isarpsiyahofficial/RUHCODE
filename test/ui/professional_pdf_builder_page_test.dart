import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/pdf/pdf_reports_pages.dart';
import 'package:ruh_code/src/ui/pdf/professional_pdf_ui_actions.dart';

Widget _app(Widget home, {Locale locale = const Locale('tr', 'TR')}) => MaterialApp(
      locale: locale,
      supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

void main() {
  testWidgets('builder requires current preview before PDF generation', (tester) async {
    final actions = _RecordingActions();
    await tester.pumpWidget(
      _app(ProfessionalPdfBuilderPage(actions: actions, records: _RecordActions())),
    );
    await tester.pumpAndSettle();

    await _selectRecord(tester, 'numerology.pythagorean');

    final create = tester.widget<FilledButton>(
      find.byKey(const ValueKey(RuhActionIds.pdfCreate)),
    );
    expect(create.onPressed, isNull);
    expect(find.text('PDF oluşturmadan önce güncel rapor planını önizle.'), findsOneWidget);
    expect(actions.calls, 0);
  });

  testWidgets('builder invokes application actions with typed selected record and section order', (tester) async {
    final actions = _RecordingActions();
    await tester.pumpWidget(
      _app(ProfessionalPdfBuilderPage(actions: actions, records: _RecordActions())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byKey(const ValueKey('professional-pdf-record-selector')), findsOneWidget);
    await _selectRecord(tester, 'numerology.pythagorean');

    expect(find.text('Numeroloji'), findsOneWidget);
    expect(find.text('Hesaplama Bilgileri'), findsOneWidget);
    expect(find.text('Harita'), findsNothing);
    expect(find.text('Yorum'), findsNothing);
    expect(find.text('Notlar'), findsNothing);

    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('professional-pdf-preflight-preview')), findsOneWidget);
    expect(find.text('Rapor Önizlemesi'), findsOneWidget);
    expect(find.text('Numeroloji · TR'), findsOneWidget);
    expect(find.text('A4 · 210 × 297 mm'), findsOneWidget);
    expect(find.text('• Kapak'), findsOneWidget);
    expect(find.text('• Numeroloji'), findsOneWidget);
    expect(find.text('• Hesaplama Bilgileri'), findsOneWidget);

    await _tapCreate(tester);

    expect(actions.calls, 1);
    expect(actions.recordId, 'calc-42');
    expect(actions.localeTag, 'tr');
    expect(actions.sectionIds, [
      PdfSectionIds.numerology,
      PdfSectionIds.technicalManifest,
    ]);
    expect(find.text('PDF doğrulandı'), findsOneWidget);
    expect(find.text('2 sayfa · 4096 byte'), findsOneWidget);
  });

  testWidgets('western record exposes only persisted western handler sections', (tester) async {
    await tester.pumpWidget(
      _app(
        ProfessionalPdfBuilderPage(
          actions: _RecordingActions(),
          records: _RecordActions(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _selectRecord(tester, 'western.natal');

    expect(find.text('Yerleşimler'), findsOneWidget);
    expect(find.text('Evler'), findsOneWidget);
    expect(find.text('Açılar'), findsOneWidget);
    expect(find.text('Hesaplama Bilgileri'), findsOneWidget);
    expect(find.text('Numeroloji'), findsNothing);
    expect(find.text('Harita'), findsNothing);
    expect(find.text('Yorum'), findsNothing);
    expect(find.text('Notlar'), findsNothing);
  });

  testWidgets('changing a section invalidates preview and blocks stale-plan build', (tester) async {
    final actions = _RecordingActions();
    await tester.pumpWidget(
      _app(ProfessionalPdfBuilderPage(actions: actions, records: _RecordActions())),
    );
    await tester.pumpAndSettle();
    await _selectRecord(tester, 'numerology.pythagorean');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('professional-pdf-preflight-preview')), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Hesaplama Bilgileri'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('professional-pdf-preflight-preview')), findsNothing);
    final create = tester.widget<FilledButton>(
      find.byKey(const ValueKey(RuhActionIds.pdfCreate)),
    );
    expect(create.onPressed, isNull);
    expect(actions.calls, 0);
  });

  testWidgets('verified PDF exposes canonical share action when delivery is bound', (tester) async {
    final delivery = _RecordingDeliveryActions();
    await tester.pumpWidget(
      _app(
        ProfessionalPdfBuilderPage(
          actions: _RecordingActions(),
          records: _RecordActions(),
          deliveryActions: delivery,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _selectRecord(tester, 'numerology.pythagorean');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();
    await _tapCreate(tester);

    expect(find.byKey(const ValueKey(RuhActionIds.pdfShare)), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfShare)));
    await tester.pumpAndSettle();

    expect(delivery.shareCalls, 1);
    expect(delivery.recordId, 'calc-42');
    expect(delivery.localeTag, 'tr');
    expect(delivery.sectionIds, [
      PdfSectionIds.numerology,
      PdfSectionIds.technicalManifest,
    ]);
    expect(find.text('PDF paylaşım menüsüne aktarıldı.'), findsOneWidget);
  });

  testWidgets('dismissed PDF share is a normal cancellation state', (tester) async {
    final delivery = _RecordingDeliveryActions(
      shareOutcome: ProfessionalPdfUiDeliveryOutcome.cancelled,
    );
    await tester.pumpWidget(
      _app(
        ProfessionalPdfBuilderPage(
          actions: _RecordingActions(),
          records: _RecordActions(),
          deliveryActions: delivery,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _selectRecord(tester, 'numerology.pythagorean');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();
    await _tapCreate(tester);
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfShare)));
    await tester.pumpAndSettle();

    expect(find.text('Paylaşım iptal edildi.'), findsOneWidget);
    expect(find.textContaining('PDF paylaşılamadı'), findsNothing);
  });

  testWidgets('builder never fakes output when production build actions are absent', (tester) async {
    await tester.pumpWidget(
      _app(ProfessionalPdfBuilderPage(records: _RecordActions())),
    );
    await tester.pumpAndSettle();

    await _selectRecord(tester, 'numerology.pythagorean');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfPreflight)));
    await tester.pumpAndSettle();
    await _tapCreate(tester, settle: false);

    expect(find.textContaining('production runtime'), findsOneWidget);
    expect(find.text('PDF doğrulandı'), findsNothing);
  });

  testWidgets('unsupported calculation records are not advertised as buildable', (tester) async {
    await tester.pumpWidget(
      _app(ProfessionalPdfBuilderPage(records: _UnsupportedRecordActions())),
    );
    await tester.pumpAndSettle();

    expect(find.text('PDF için desteklenen kayıtlı hesaplama bulunamadı.'), findsOneWidget);
    expect(find.byKey(const ValueKey('professional-pdf-record-selector')), findsNothing);
  });

  testWidgets('builder does not expose raw record ID field', (tester) async {
    await tester.pumpWidget(
      _app(
        ProfessionalPdfBuilderPage(
          actions: _RecordingActions(),
          records: _RecordActions(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Kayıt kimliği'), findsNothing);
    expect(find.text('Kayıtlı Hesaplama'), findsOneWidget);
  });
}

Future<void> _selectRecord(WidgetTester tester, String calculationType) async {
  await tester.tap(find.byKey(const ValueKey('professional-pdf-record-selector')));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining(calculationType).last);
  await tester.pumpAndSettle();
}

Future<void> _tapCreate(WidgetTester tester, {bool settle = true}) async {
  final create = find.byKey(const ValueKey(RuhActionIds.pdfCreate));
  await tester.scrollUntilVisible(
    create,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(create);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

final class _RecordingActions implements ProfessionalPdfBuildActions {
  int calls = 0;
  String recordId = '';
  String localeTag = '';
  List<String> sectionIds = const [];

  @override
  Future<ProfessionalPdfUiBuildResult> build({
    required String recordId,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    calls += 1;
    this.recordId = recordId;
    this.localeTag = localeTag;
    this.sectionIds = List<String>.unmodifiable(sectionIds);
    return const ProfessionalPdfUiBuildResult(byteLength: 4096, pageCount: 2);
  }
}

final class _RecordingDeliveryActions implements ProfessionalPdfDeliveryActions {
  _RecordingDeliveryActions({
    this.shareOutcome = ProfessionalPdfUiDeliveryOutcome.success,
  });

  final ProfessionalPdfUiDeliveryOutcome shareOutcome;
  int shareCalls = 0;
  String recordId = '';
  String localeTag = '';
  List<String> sectionIds = const [];

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
  }) async {
    shareCalls += 1;
    this.recordId = recordId;
    this.localeTag = localeTag;
    this.sectionIds = List<String>.unmodifiable(sectionIds);
    return ProfessionalPdfUiDeliveryResult(outcome: shareOutcome);
  }
}

final class _RecordActions implements ProfessionalPdfRecordActions {
  @override
  Future<List<ProfessionalPdfUiRecord>> listRecords() async => <ProfessionalPdfUiRecord>[
        ProfessionalPdfUiRecord(
          recordId: 'calc-42',
          ownerEntityId: 'owner-1',
          calculationType: 'numerology.pythagorean',
          createdAtUtc: DateTime.utc(2026, 8, 22, 1, 0),
        ),
        ProfessionalPdfUiRecord(
          recordId: 'western-7',
          ownerEntityId: 'owner-1',
          calculationType: 'western.natal',
          createdAtUtc: DateTime.utc(2026, 8, 22, 2, 0),
        ),
      ];
}

final class _UnsupportedRecordActions implements ProfessionalPdfRecordActions {
  @override
  Future<List<ProfessionalPdfUiRecord>> listRecords() async => <ProfessionalPdfUiRecord>[
        ProfessionalPdfUiRecord(
          recordId: 'vedic-1',
          ownerEntityId: 'owner-1',
          calculationType: 'vedic.natal',
          createdAtUtc: DateTime.utc(2026, 8, 22, 3, 0),
        ),
      ];
}
