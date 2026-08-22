import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/pdf_local_renderer.dart';
import 'package:ruh_code/src/pdf/pdf_local_service.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';
import 'package:ruh_code/src/pdf/persisted_pythagorean_numerology_pdf.dart';

void main() {
  test('valid persisted canonical snapshot reaches font boundary without recalculation', () async {
    final fontProvider = _ThrowingFontProvider();
    final service = PersistedPythagoreanNumerologyPdfService(
      fontProvider: fontProvider,
    );

    await expectLater(
      service.buildReport(
        snapshot: _snapshot(),
        options: const PdfReportOptions(
          localeTag: 'tr',
          sectionIds: <String>['numerology'],
        ),
      ),
      throwsStateError,
    );
    expect(fontProvider.calls, 1);
  });

  test('tampered canonical snapshot digest fails before font loading', () async {
    final fontProvider = _ThrowingFontProvider();
    final service = PersistedPythagoreanNumerologyPdfService(
      fontProvider: fontProvider,
    );
    final original = _snapshot();
    final tampered = PersistedCalculationPdfSnapshot(
      recordId: original.recordId,
      ownerEntityId: original.ownerEntityId,
      calculationType: original.calculationType,
      payload: <String, Object?>{
        ...original.payload,
        PersistedPythagoreanNumerologyPdfContract.digestKey:
            List<String>.filled(64, '0').join(),
      },
      createdAtUtc: original.createdAtUtc,
      manifest: original.manifest,
    );

    await expectLater(
      service.buildReport(
        snapshot: tampered,
        options: const PdfReportOptions(
          localeTag: 'tr',
          sectionIds: <String>['numerology'],
        ),
      ),
      throwsFormatException,
    );
    expect(fontProvider.calls, 0);
  });

  test('manifest engine-version drift fails closed before rendering', () async {
    final fontProvider = _ThrowingFontProvider();
    final service = PersistedPythagoreanNumerologyPdfService(
      fontProvider: fontProvider,
    );
    final original = _snapshot();
    final wrongManifest = CalculationManifest(
      id: original.manifest.id,
      engineId: original.manifest.engineId,
      engineVersion: '999',
      algorithmVersion: original.manifest.algorithmVersion,
      dataVersion: original.manifest.dataVersion,
      localDateTime: original.manifest.localDateTime,
      utcDateTime: original.manifest.utcDateTime,
      location: original.manifest.location,
      validity: original.manifest.validity,
    );

    await expectLater(
      service.buildReport(
        snapshot: PersistedCalculationPdfSnapshot(
          recordId: original.recordId,
          ownerEntityId: original.ownerEntityId,
          calculationType: original.calculationType,
          payload: original.payload,
          createdAtUtc: original.createdAtUtc,
          manifest: wrongManifest,
        ),
        options: const PdfReportOptions(
          localeTag: 'en',
          sectionIds: <String>['numerology'],
        ),
      ),
      throwsFormatException,
    );
    expect(fontProvider.calls, 0);
  });

  test('wrong calculation type is rejected instead of reinterpretation', () async {
    final fontProvider = _ThrowingFontProvider();
    final service = PersistedPythagoreanNumerologyPdfService(
      fontProvider: fontProvider,
    );
    final original = _snapshot();

    await expectLater(
      service.buildReport(
        snapshot: PersistedCalculationPdfSnapshot(
          recordId: original.recordId,
          ownerEntityId: original.ownerEntityId,
          calculationType: 'western.natal',
          payload: original.payload,
          createdAtUtc: original.createdAtUtc,
          manifest: original.manifest,
        ),
        options: const PdfReportOptions(
          localeTag: 'tr',
          sectionIds: <String>['numerology'],
        ),
      ),
      throwsFormatException,
    );
    expect(fontProvider.calls, 0);
  });
}

PersistedCalculationPdfSnapshot _snapshot() {
  final canonical = jsonEncode(<String, Object?>{
    'schemaVersion': '1',
    'engineId': 'numerology.pythagorean.snapshot',
    'engineVersion': '1',
    'birthDate': '1990-05-19',
    'normalizedName': 'IBRAHIMYESILYURT',
    'profilePolicy': 'preserveMasterNumbers',
    'profile': <String, Object?>{
      'lifePath': 7,
      'expression': 5,
      'soulUrge': 9,
      'personality': 3,
      'birthday': 1,
      'maturity': 3,
      'lifePathTrace': <int>[34, 7],
      'expressionTrace': <int>[50, 5],
      'soulUrgeTrace': <int>[27, 9],
      'personalityTrace': <int>[30, 3],
      'birthdayTrace': <int>[19, 10, 1],
      'maturityTrace': <int>[12, 3],
    },
    'extendedName': <String, Object?>{
      'balance': 5,
      'karmicLessons': <int>[2, 8],
      'hiddenPassions': <int>[1, 5],
      'valueFrequencies': <String, int>{
        '1': 3,
        '2': 0,
        '3': 1,
        '4': 2,
        '5': 3,
        '6': 1,
        '7': 2,
        '8': 0,
        '9': 2,
      },
    },
    'periods': <String, Object?>{
      'lifePath': 7,
      'pinnacles': <int>[6, 1, 7, 8],
      'challenges': <int>[4, 1, 3, 3],
      'firstPeriodEndAgeInclusive': 29,
      'secondPeriodEndAgeInclusive': 38,
      'thirdPeriodEndAgeInclusive': 47,
    },
    'profileKarmicDebt': <Object?>[],
    'targetDate': null,
    'cycles': null,
    'cycleKarmicDebt': <Object?>[],
  });
  final digest = sha256.convert(utf8.encode(canonical)).toString();

  return PersistedCalculationPdfSnapshot(
    recordId: 'calc-num-1',
    ownerEntityId: 'profile-1',
    calculationType: PersistedPythagoreanNumerologyPdfContract.calculationType,
    payload: <String, Object?>{
      PersistedPythagoreanNumerologyPdfContract.payloadSchemaKey:
          PersistedPythagoreanNumerologyPdfContract.payloadSchema,
      PersistedPythagoreanNumerologyPdfContract.canonicalJsonKey: canonical,
      PersistedPythagoreanNumerologyPdfContract.digestKey: digest,
      PersistedPythagoreanNumerologyPdfContract.subjectKindKey: 'profile',
    },
    createdAtUtc: DateTime.utc(2026, 8, 22),
    manifest: CalculationManifest(
      id: EntityId.parse('22222222-2222-4222-8222-222222222222'),
      engineId: 'numerology.pythagorean.snapshot',
      engineVersion: '1',
      algorithmVersion: '1',
      dataVersion: 'numerology-pdf-data-v1',
      localDateTime: DateTime.parse('2026-08-22T06:00:00+03:00'),
      utcDateTime: DateTime.utc(2026, 8, 22, 3),
      location: const LocationRecord(
        label: 'Antalya, Türkiye',
        countryCode: 'TR',
        latitude: 36.8969,
        longitude: 30.7133,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: CalculationValidity.valid,
    ),
  );
}

final class _ThrowingFontProvider implements PdfFontBundleProvider {
  int calls = 0;

  @override
  Future<PdfFontBundle> loadForLocale(String localeTag) async {
    calls += 1;
    throw StateError('font boundary reached');
  }
}
