import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/combined_professional_pdf_application_service.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/pdf/combined_pdf_builder_page.dart';
import 'package:ruh_code/src/ui/pdf/combined_professional_pdf_ui_actions.dart';

void main() {
  testWidgets('preview stays disabled for two records from only one system', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
        home: CombinedProfessionalPdfBuilderPage(actions: _SameSystemUiActions()),
      ),
    );
    await tester.pumpAndSettle();

    await _selectOnlySubject(tester);
    await tester.tap(find.byKey(const ValueKey('combined-record-western-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('combined-record-western-2')));
    await tester.pump();

    final warning = find.text('Select two distinct calculation systems to preview.');
    await tester.scrollUntilVisible(warning, 120);
    expect(warning, findsOneWidget);
    expect(find.text('Önizleme için iki farklı hesaplama sistemi seç.'), findsNothing);

    final previewFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedPreview));
    await tester.scrollUntilVisible(previewFinder, 120);
    expect(tester.widget<OutlinedButton>(previewFinder).onPressed, isNull);
  });

  testWidgets('English locale uses English combined section labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
        home: CombinedProfessionalPdfBuilderPage(actions: _MixedSystemUiActions()),
      ),
    );
    await tester.pumpAndSettle();

    await _selectOnlySubject(tester);
    await tester.tap(find.byKey(const ValueKey('combined-record-western-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('combined-record-numerology-1')));
    await tester.pump();

    final numerologySection = find.byKey(const ValueKey('combined-section-numerology'));
    await tester.scrollUntilVisible(numerologySection, 120);
    expect(find.text('Report Sections'), findsOneWidget);
    expect(find.text('Placements'), findsOneWidget);
    expect(find.text('Houses'), findsOneWidget);
    expect(find.text('Aspects'), findsOneWidget);
    expect(find.text('Numerology'), findsWidgets);
    expect(find.text('Calculation Details'), findsOneWidget);
    expect(find.text('Yerleşimler'), findsNothing);
    expect(find.text('Hesaplama Bilgileri'), findsNothing);
  });
}

Future<void> _selectOnlySubject(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('combined-pdf-subject-selector')));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('profile-1').last);
  await tester.pumpAndSettle();
}

abstract base class _BaseUiActions implements CombinedProfessionalPdfUiActions {
  List<CombinedPdfUiRecord> get records;

  @override
  Future<List<CombinedPdfUiSubject>> listSubjects() async => const <CombinedPdfUiSubject>[
        CombinedPdfUiSubject(
          subjectKind: PdfSubjectKind.profile,
          subjectId: 'profile-1',
          availableRecordCount: 2,
        ),
      ];

  @override
  Future<List<CombinedPdfUiRecord>> listCandidates({
    required PdfSubjectKind subjectKind,
    required String subjectId,
  }) async => records;

  @override
  Future<CombinedPdfUiPreview> preview({
    required List<String> recordIds,
    required String localeTag,
    required List<String> sectionIds,
  }) async => CombinedPdfUiPreview(
        value: CombinedProfessionalPdfPreview(
          recordIds: recordIds,
          localeTag: localeTag,
          subjectKind: PdfSubjectKind.profile,
          subjectId: 'profile-1',
          compositeSnapshotDigest: List<String>.filled(64, 'b').join(),
          memberSystemIds: records.map((item) => item.calculationType).toSet().toList(),
          sectionIds: <String>['cover', ...sectionIds],
        ),
      );

  @override
  Future<List<int>> build({required CombinedPdfUiPreview preview}) async => const <int>[1];
}

final class _SameSystemUiActions extends _BaseUiActions {
  @override
  List<CombinedPdfUiRecord> get records => <CombinedPdfUiRecord>[
        CombinedPdfUiRecord(
          recordId: 'western-1',
          calculationType: 'western.natal',
          createdAtUtc: DateTime.utc(2026, 8, 1),
        ),
        CombinedPdfUiRecord(
          recordId: 'western-2',
          calculationType: 'western.natal',
          createdAtUtc: DateTime.utc(2026, 8, 2),
        ),
      ];
}

final class _MixedSystemUiActions extends _BaseUiActions {
  @override
  List<CombinedPdfUiRecord> get records => <CombinedPdfUiRecord>[
        CombinedPdfUiRecord(
          recordId: 'western-1',
          calculationType: 'western.natal',
          createdAtUtc: DateTime.utc(2026, 8, 1),
        ),
        CombinedPdfUiRecord(
          recordId: 'numerology-1',
          calculationType: 'numerology.pythagorean',
          createdAtUtc: DateTime.utc(2026, 8, 2),
        ),
      ];
}
