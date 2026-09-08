import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/runtime_invariance.dart';

void main() {
  test('device model and presentation locale cannot affect stored calculation key', () {
    final context = StoredCalculationContext(
      subjectId: 'subject-1',
      localDateTimeIso: '1990-05-17T14:30:00',
      timezoneId: 'Europe/Istanbul',
      utcInstant: DateTime.utc(1990, 5, 17, 11, 30),
    );
    final input = CanonicalDecimal.parse('12.5');
    const keyBuilder = RuntimeInvariantCalculationKey();

    const trEnvironment = PresentationEnvironment(
      languageCode: 'tr',
      systemTimezoneId: 'Europe/Istanbul',
      deviceModel: 'Android-A',
      decimalSeparator: ',',
    );
    const enEnvironment = PresentationEnvironment(
      languageCode: 'en',
      systemTimezoneId: 'America/New_York',
      deviceModel: 'Android-B',
      decimalSeparator: '.',
    );

    final first = keyBuilder.forStored(
      context: context,
      engineVersion: 'engine-1',
      algorithmVersion: 'algo-1',
      numericInputs: <CanonicalDecimal>[input],
    );
    final second = keyBuilder.forStored(
      context: context,
      engineVersion: 'engine-1',
      algorithmVersion: 'algo-1',
      numericInputs: <CanonicalDecimal>[input],
    );

    expect(trEnvironment.deviceModel, isNot(enEnvironment.deviceModel));
    expect(trEnvironment.languageCode, isNot(enEnvironment.languageCode));
    expect(trEnvironment.systemTimezoneId, isNot(enEnvironment.systemTimezoneId));
    expect(first, second);
  });

  test('stored calculation keeps its own timezone instead of ambient system timezone', () {
    final context = StoredCalculationContext(
      subjectId: 'subject-2',
      localDateTimeIso: '1984-01-02T03:04:05',
      timezoneId: 'Asia/Kathmandu',
      utcInstant: DateTime.utc(1984, 1, 1, 21, 19, 5),
    );
    expect(context.timezoneId, 'Asia/Kathmandu');
    expect(context.deterministicFingerprint, contains('Asia/Kathmandu'));
    expect(context.deterministicFingerprint, isNot(contains('Europe/Istanbul')));
  });

  test('now calculations require explicit current timezone and UTC instant', () {
    final context = CurrentCalculationContext(
      timezoneId: 'Pacific/Kiritimati',
      utcNow: DateTime.utc(2026, 9, 8, 21, 0),
    );
    expect(context.timezoneId, 'Pacific/Kiritimati');
    expect(context.utcNow.isUtc, isTrue);
  });

  test('calculation core accepts canonical decimal independent from locale separator', () {
    expect(CanonicalDecimal.parse('12.50').value, 12.5);
    expect(() => CanonicalDecimal.parse('12,50'), throwsFormatException);
    expect(() => CanonicalDecimal.parse('NaN'), throwsFormatException);
  });

  test('TR and EN localization catalogs require exact key parity', () {
    final pair = LocalizationCatalogPair(
      tr: const <String, String>{
        'calculation.unavailable': 'Hesaplanamıyor',
        'birth_time.unknown': 'Doğum saati bilinmiyor',
      },
      en: const <String, String>{
        'calculation.unavailable': 'Unavailable',
        'birth_time.unknown': 'Birth time is unknown',
      },
    );
    expect(pair.systemText('calculation.unavailable', 'tr'), 'Hesaplanamıyor');
    expect(pair.systemText('calculation.unavailable', 'en'), 'Unavailable');
  });

  test('missing localization key on either language fails closed', () {
    expect(
      () => LocalizationCatalogPair(
        tr: const <String, String>{'only.tr': 'Sadece Türkçe'},
        en: const <String, String>{},
      ),
      throwsStateError,
    );
  });

  test('user-authored names and notes are never localized or translated', () {
    const boundary = UserDataLocalizationBoundary();
    const name = 'İbrahim / John';
    const note = 'Bugün iyi hissediyorum — keep this English sentence.';
    expect(boundary.preserveName(name), name);
    expect(boundary.preserveNote(note), note);
    expect(boundary.preserveUserText(note), note);
  });
}
