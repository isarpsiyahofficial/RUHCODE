import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/actions/ruh_action_ids.dart';
import 'package:ruh_code/src/ui/pdf/pdf_reports_pages.dart';
import 'package:ruh_code/src/ui/pdf/professional_pdf_ui_actions.dart';

void main() {
  testWidgets('builder invokes application actions with exact record and section order', (tester) async {
    final actions = _RecordingActions();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr', 'TR'),
        home: ProfessionalPdfBuilderPage(actions: actions),
      ),
    );

    await tester.enterText(find.byType(TextField), 'calc-42');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfCreate)));
    await tester.pumpAndSettle();

    expect(actions.calls, 1);
    expect(actions.recordId, 'calc-42');
    expect(actions.localeTag.toLowerCase(), contains('tr'));
    expect(actions.sectionIds, ['chart', 'placements', 'interpretation', 'notes']);
    expect(find.text('PDF doğrulandı'), findsOneWidget);
    expect(find.text('2 sayfa · 4096 byte'), findsOneWidget);
  });

  testWidgets('builder never fakes output when production actions are absent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfessionalPdfBuilderPage()),
    );

    await tester.enterText(find.byType(TextField), 'calc-42');
    await tester.tap(find.byKey(const ValueKey(RuhActionIds.pdfCreate)));
    await tester.pump();

    expect(find.textContaining('production runtime'), findsOneWidget);
    expect(find.text('PDF doğrulandı'), findsNothing);
  });
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
