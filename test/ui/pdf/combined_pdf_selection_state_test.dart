import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/combined_professional_pdf_application_service.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/ui/pdf/combined_pdf_selection_state.dart';
import 'package:ruh_code/src/ui/pdf/combined_professional_pdf_ui_actions.dart';

void main() {
  test('exact preview input can build', () async {
    final actions = _FakeCombinedActions();
    final state = CombinedPdfSelectionState(actions: actions);

    await state.selectSubject(
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );
    state.toggleRecord('western-1');
    state.toggleRecord('numerology-1');
    state.setSections(const <String>['placements', 'numerology']);

    final preview = await state.createPreview();
    expect(preview.recordIds, const <String>['western-1', 'numerology-1']);
    final bytes = await state.build();
    expect(bytes, const <int>[1, 2, 3]);
    expect(actions.buildCalls, 1);
  });

  test('record change invalidates preview before build', () async {
    final actions = _FakeCombinedActions();
    final state = CombinedPdfSelectionState(actions: actions);
    await state.selectSubject(
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );
    state.toggleRecord('western-1');
    state.toggleRecord('numerology-1');
    state.setSections(const <String>['placements']);
    await state.createPreview();

    state.toggleRecord('numerology-1');

    expect(state.preview, isNull);
    expect(() => state.build(), throwsStateError);
  });

  test('locale and section changes invalidate preview', () async {
    final actions = _FakeCombinedActions();
    final state = CombinedPdfSelectionState(actions: actions);
    await state.selectSubject(
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );
    state.toggleRecord('western-1');
    state.toggleRecord('numerology-1');
    state.setSections(const <String>['placements']);
    await state.createPreview();

    state.setLocale('en-US');
    expect(state.preview, isNull);
    await state.createPreview();
    state.setSections(const <String>['placements', 'numerology']);
    expect(state.preview, isNull);
  });

  test('records outside selected subject cannot be toggled', () async {
    final state = CombinedPdfSelectionState(actions: _FakeCombinedActions());
    await state.selectSubject(
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );

    expect(() => state.toggleRecord('other-record'), throwsFormatException);
  });
}

final class _FakeCombinedActions implements CombinedProfessionalPdfUiActions {
  int buildCalls = 0;

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
  }) async {
    if (subjectKind != PdfSubjectKind.profile || subjectId != 'profile-1') {
      return const <CombinedPdfUiRecord>[];
    }
    return <CombinedPdfUiRecord>[
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

  @override
  Future<CombinedPdfUiPreview> preview({
    required List<String> recordIds,
    required String localeTag,
    required List<String> sectionIds,
  }) async {
    return CombinedPdfUiPreview(
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
  }

  @override
  Future<List<int>> build({required CombinedPdfUiPreview preview}) async {
    buildCalls += 1;
    return const <int>[1, 2, 3];
  }
}
