import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot.dart';
import 'package:ruh_code/src/calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  group('PythagoreanSnapshotFingerprint', () {
    test('is deterministic for the same canonical snapshot', () {
      final first = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 8, 16),
      );
      final second = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
        targetDate: CivilDate(2026, 8, 16),
      );

      final firstDigest = PythagoreanSnapshotFingerprint.sha256Hex(first);
      final secondDigest = PythagoreanSnapshotFingerprint.sha256Hex(second);
      expect(firstDigest, secondDigest);
      expect(firstDigest, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('changes when exact target date changes', () {
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

      expect(
        PythagoreanSnapshotFingerprint.sha256Hex(first),
        isNot(PythagoreanSnapshotFingerprint.sha256Hex(second)),
      );
    });

    test('changes when normalized name calculation changes', () {
      final first = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );
      final second = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yılmaz',
      );

      expect(
        PythagoreanSnapshotFingerprint.sha256Hex(first),
        isNot(PythagoreanSnapshotFingerprint.sha256Hex(second)),
      );
    });

    test('canonical payload excludes translated interpretation text', () {
      final snapshot = PythagoreanNumerologySnapshotEngine.calculate(
        birthDate: CivilDate(1990, 5, 19),
        fullName: 'İbrahim Yeşilyurt',
      );
      final json = PythagoreanSnapshotFingerprint.canonicalJson(snapshot);

      expect(json, contains('numerology.pythagorean.snapshot'));
      expect(json, isNot(contains('yorum')));
      expect(json, isNot(contains('interpretation')));
    });
  });
}
