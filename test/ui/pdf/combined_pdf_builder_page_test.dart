import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/combined_professional_pdf_application_service.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/pdf/combined_pdf_builder_page.dart';
import 'package:ruh_code/src/ui/pdf/combined_professional_pdf_ui_actions.dart';

void main() {
  testWidgets('multi-record preview uses accessible 48dp actions and sealed delivery token',
      (tester) async {
    final actions = _WidgetCombinedActions();
    final delivery = _WidgetCombinedDelivery();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        home: CombinedProfessionalPdfBuilderPage(
          actions: actions,
          deliveryActions: delivery,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kombine PDF Raporu'), findsOneWidget);
    expect(find.byKey(const ValueKey('combined-pdf-subject-selector')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('combined-pdf-subject-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('profile-1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('combined-record-western-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('combined-record-numerology-1')));
    await tester.pump();

    final previewFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedPreview));
    final createFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedCreate));
    final saveFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedSave));
    final shareFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedShare));

    expect(tester.getSize(previewFinder).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(createFinder).height, greaterThanOrEqualTo(48));

    await tester.tap(previewFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('combined-pdf-preview-card')), findsOneWidget);
    expect(find.textContaining('western.natal'), findsOneWidget);
    expect(find.textContaining('numerology.pythagorean'), findsOneWidget);
    expect(tester.widget<FilledButton>(createFinder).onPressed, isNotNull);
    expect(tester.getSize(saveFinder).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(shareFinder).height, greaterThanOrEqualTo(48));

    final preview = actions.lastPreview;
    expect(preview, isNotNull);
    await tester.tap(shareFinder);
    await tester.pumpAndSettle();
    expect(delivery.lastPreview, same(preview));
    expect(find.text('PDF paylaşım menüsüne aktarıldı.'), findsOneWidget);

    final section = find.byKey(const ValueKey('combined-section-placements'));
    expect(section, findsOneWidget);
    await tester.tap(section);
    await tester.pump();
    expect(find.byKey(const ValueKey('combined-pdf-preview-card')), findsNothing);
    expect(tester.widget<FilledButton>(createFinder).onPressed, isNull);
  });

  testWidgets('critical combined PDF controls survive 2.0x text scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: CombinedProfessionalPdfBuilderPage(
          actions: _WidgetCombinedActions(),
          deliveryActions: _WidgetCombinedDelivery(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Kombine PDF Raporu'), findsOneWidget);
    final previewFinder = find.byKey(const ValueKey(RuhActionIds.pdfCombinedPreview));
    expect(previewFinder, findsOneWidget);
    expect(tester.getSize(previewFinder).height, greaterThanOrEqualTo(48));
  });
}

final class _WidgetCombinedActions implements CombinedProfessionalPdfUiActions {
  CombinedPdfUiPreview? lastPreview;

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
  }) async => <CombinedPdfUiRecord>[
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

  @override
  Future<CombinedPdfUiPreview> preview({
    required List<String> recordIds,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    final result = CombinedPdfUiPreview(
      value: CombinedProfessionalPdfPreview(
        recordIds: List<String>.unmodifiable(recordIds),
        localeTag: localeTag,
        subjectKind: PdfSubjectKind.profile,
        subjectId: 'profile-1',
        compositeSnapshotDigest: List<String>.filled(64, 'a').join(),
        memberSystemIds: const <String>['western.natal', 'numerology.pythagorean'],
        sectionIds: List<String>.unmodifiable(<String>['cover', ...sectionIds]),
      ),
    );
    lastPreview = result;
    return result;
  }

  @override
  Future<List<int>> build({required CombinedPdfUiPreview preview}) async =>
      const <int>[37, 80, 68, 70, 45, 49];
}

final class _WidgetCombinedDelivery implements CombinedProfessionalPdfDeliveryActions {
  CombinedPdfUiPreview? lastPreview;

  @override
  Future<CombinedPdfUiDeliveryResult> save({
    required CombinedPdfUiPreview preview,
    required String fileName,
  }) async {
    lastPreview = preview;
    return CombinedPdfUiDeliveryResult(
      outcome: CombinedPdfUiDeliveryOutcome.saved,
      savedUri: Uri.file('/tmp/$fileName'),
    );
  }

  @override
  Future<CombinedPdfUiDeliveryResult> share({
    required CombinedPdfUiPreview preview,
    required String fileName,
  }) async {
    lastPreview = preview;
    return const CombinedPdfUiDeliveryResult(
      outcome: CombinedPdfUiDeliveryOutcome.shared,
    );
  }
}
