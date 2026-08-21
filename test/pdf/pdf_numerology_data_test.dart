import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';
import 'package:ruh_code/src/pdf/pdf_data_contract.dart';
import 'package:ruh_code/src/pdf/pdf_numerology_data.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';

void main() {
  group('PdfNumerologyDataAdapter', () {
    test('projects canonical snapshot values without recalculation drift', () {
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

      final rows = <String, String>{
        for (final row in payload.metricRows) row.metricId: row.value,
      };
      expect(rows['life_path'], '${snapshot.profile.lifePath}');
      expect(rows['expression'], '${snapshot.profile.expression}');
      expect(rows['balance'], '${snapshot.extendedName.balance}');
      expect(rows['personal_year'], '${snapshot.personalCycles!.personalYear}');
      expect(rows['personal_month'], '${snapshot.personalCycles!.personalMonth}');
      expect(rows['personal_day'], '${snapshot.personalCycles!.personalDay}');
    });

    test('uses the exact canonical snapshot SHA-256 identity', () {
      final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );
      final expected = PythagoreanSnapshotFingerprint.sha256Hex(snapshot);
      final payload = PdfNumerologyDataAdapter.fromSnapshot(
        snapshot: snapshot,
        origin: PdfDataOrigin.user,
        subjectKind: PdfSubjectKind.profile,
        subjectId: 'profile-1',
      );

      expect(payload.snapshotDigest, expected);
      expect(payload.dataset.identity.snapshotDigest, expected);
      const PdfReportDataValidator().requireUiPdfSnapshotParity(
        uiSnapshotDigest: expected,
        pdfIdentity: payload.dataset.identity,
      );
    });

    test('target-date changes produce a different PDF snapshot identity', () {
      final first = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 8, 16),
      );
      final second = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2027, 8, 16),
      );

      final firstPayload = PdfNumerologyDataAdapter.fromSnapshot(
        snapshot: first,
        origin: PdfDataOrigin.user,
        subjectKind: PdfSubjectKind.profile,
        subjectId: 'profile-1',
      );
      final secondPayload = PdfNumerologyDataAdapter.fromSnapshot(
        snapshot: second,
        origin: PdfDataOrigin.user,
        subjectKind: PdfSubjectKind.profile,
        subjectId: 'profile-1',
      );
      expect(firstPayload.snapshotDigest, isNot(secondPayload.snapshotDigest));
    });

    test('demo/user subject boundaries remain strict', () {
      final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );

      expect(
        () => PdfNumerologyDataAdapter.fromSnapshot(
          snapshot: snapshot,
          origin: PdfDataOrigin.user,
          subjectKind: PdfSubjectKind.demo,
          subjectId: 'demo-1',
        ),
        throwsFormatException,
      );
      expect(
        () => PdfNumerologyDataAdapter.fromSnapshot(
          snapshot: snapshot,
          origin: PdfDataOrigin.demo,
          subjectKind: PdfSubjectKind.profile,
          subjectId: 'profile-1',
        ),
        throwsFormatException,
      );
    });
  });
}
