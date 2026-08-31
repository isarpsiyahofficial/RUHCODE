import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_numerology_data.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/ui/numerology/numerology_presentation.dart';

void main() {
  test('UI and PDF project the same canonical snapshot values and digest', () {
    final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
      birthDate: CivilDate(1990, 5, 19),
      fullName: 'İbrahim Yeşilyurt',
      targetDate: CivilDate(2026, 8, 16),
    );

    final ui = NumerologyPresentationAdapter.fromSnapshot(snapshot);
    final pdf = PdfNumerologyDataAdapter.fromSnapshot(
      snapshot: snapshot,
      origin: PdfDataOrigin.user,
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );

    expect(ui.snapshotDigest, pdf.snapshotDigest);
    expect(ui.birthDateIso, '1990-05-19');
    expect(ui.targetDateIso, '2026-08-16');

    final uiRows = <String, String>{
      for (final row in ui.allRows) row.metricId: row.value,
    };
    final pdfRows = <String, String>{
      for (final row in pdf.metricRows) row.metricId: row.value,
    };
    expect(uiRows, pdfRows);
    expect(uiRows.length, 14);
  });

  test('date-independent presentation omits personal cycle section', () {
    final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
      birthDate: CivilDate(1990, 5, 19),
      fullName: 'İbrahim Yeşilyurt',
    );

    final ui = NumerologyPresentationAdapter.fromSnapshot(snapshot);
    expect(ui.targetDateIso, isNull);
    expect(ui.sections.map((section) => section.sectionId), isNot(contains('personal_cycles')));
    expect(ui.allRows.map((row) => row.metricId), isNot(contains('personal_day')));
  });

  test('presentation is deterministic for the same canonical snapshot', () {
    final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
      birthDate: CivilDate(2028, 2, 29),
      fullName: 'Ada Lovelace',
      targetDate: CivilDate(2032, 2, 29),
    );

    final a = NumerologyPresentationAdapter.fromSnapshot(snapshot);
    final b = NumerologyPresentationAdapter.fromSnapshot(snapshot);

    expect(a.snapshotDigest, b.snapshotDigest);
    expect(
      a.allRows.map((row) => '${row.metricId}=${row.value}').toList(),
      b.allRows.map((row) => '${row.metricId}=${row.value}').toList(),
    );
  });
}
