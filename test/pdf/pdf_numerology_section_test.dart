import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_numerology_data.dart';
import 'package:ruh_code/src/pdf/pdf_numerology_section.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  test('real PDF render section uses canonical numerology payload rows', () {
    final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
      birthDate: CivilDate(1990, 5, 19),
      fullName: 'İbrahim Yeşilyurt',
      targetDate: CivilDate(2026, 8, 16),
    );
    final payload = PdfNumerologyDataAdapter.fromSnapshot(
      snapshot: snapshot,
      origin: PdfDataOrigin.user,
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );

    final section = PdfNumerologySectionAdapter.build(
      payload: payload,
      title: 'Numeroloji',
      metricHeader: 'Gösterge',
      valueHeader: 'Değer',
      labelForMetric: (id) => 'label.$id',
    );

    expect(section.sectionId, PdfSectionIds.numerology);
    expect(section.snapshotDigest, payload.snapshotDigest);
    expect(section.rows.first, <String>['Gösterge', 'Değer']);
    expect(section.rows.length, payload.metricRows.length + 1);
    for (var i = 0; i < payload.metricRows.length; i++) {
      expect(section.rows[i + 1][0], 'label.${payload.metricRows[i].metricId}');
      expect(section.rows[i + 1][1], payload.metricRows[i].value);
    }
  });

  test('blank localized metric label is rejected before render', () {
    final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
      birthDate: CivilDate(1990, 5, 19),
      fullName: 'Ada Lovelace',
    );
    final payload = PdfNumerologyDataAdapter.fromSnapshot(
      snapshot: snapshot,
      origin: PdfDataOrigin.user,
      subjectKind: PdfSubjectKind.profile,
      subjectId: 'profile-1',
    );

    expect(
      () => PdfNumerologySectionAdapter.build(
        payload: payload,
        title: 'Numerology',
        metricHeader: 'Metric',
        valueHeader: 'Value',
        labelForMetric: (_) => '',
      ),
      throwsFormatException,
    );
  });
}
