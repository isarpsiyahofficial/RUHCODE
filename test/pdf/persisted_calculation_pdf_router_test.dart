import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/pdf_service.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_router.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';

void main() {
  test('routes exact calculation type to exactly one registered service', () async {
    final numerology = _RecordingService(<int>[1, 2, 3]);
    final western = _RecordingService(<int>[4, 5]);
    final router = PersistedCalculationPdfRouter(
      handlers: <PersistedCalculationPdfHandler>[
        PersistedCalculationPdfHandler(
          calculationType: 'numerology.pythagorean',
          service: numerology,
        ),
        PersistedCalculationPdfHandler(
          calculationType: 'western.natal',
          service: western,
        ),
      ],
    );

    final bytes = await router.buildReport(
      snapshot: _snapshot('numerology.pythagorean'),
      options: const PdfReportOptions(
        localeTag: 'tr',
        sectionIds: <String>['chart'],
      ),
    );

    expect(bytes, <int>[1, 2, 3]);
    expect(numerology.calls, 1);
    expect(western.calls, 0);
    expect(router.supportedCalculationTypes, <String>{
      'numerology.pythagorean',
      'western.natal',
    });
  });

  test('unknown calculation type fails closed instead of reusing another handler', () async {
    final router = PersistedCalculationPdfRouter(
      handlers: <PersistedCalculationPdfHandler>[
        PersistedCalculationPdfHandler(
          calculationType: 'numerology.pythagorean',
          service: _RecordingService(<int>[1]),
        ),
      ],
    );

    await expectLater(
      router.buildReport(
        snapshot: _snapshot('vedic.natal'),
        options: const PdfReportOptions(
          localeTag: 'tr',
          sectionIds: <String>['chart'],
        ),
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('duplicate handler registration is rejected', () {
    final service = _RecordingService(<int>[1]);
    expect(
      () => PersistedCalculationPdfRouter(
        handlers: <PersistedCalculationPdfHandler>[
          PersistedCalculationPdfHandler(
            calculationType: 'western.natal',
            service: service,
          ),
          PersistedCalculationPdfHandler(
            calculationType: 'western.natal',
            service: service,
          ),
        ],
      ),
      throwsStateError,
    );
  });

  test('empty handler registry is rejected', () {
    expect(
      () => PersistedCalculationPdfRouter(
        handlers: const <PersistedCalculationPdfHandler>[],
      ),
      throwsFormatException,
    );
  });
}

PersistedCalculationPdfSnapshot _snapshot(String calculationType) {
  return PersistedCalculationPdfSnapshot(
    recordId: 'calc-1',
    ownerEntityId: 'owner-1',
    calculationType: calculationType,
    payload: const <String, Object?>{},
    createdAtUtc: DateTime.utc(2026, 8, 22),
    manifest: CalculationManifest(
      id: EntityId.parse('22222222-2222-4222-8222-222222222222'),
      engineId: calculationType,
      engineVersion: '1.0.0',
      algorithmVersion: '1',
      dataVersion: '1',
      localDateTime: DateTime.parse('2026-08-22T03:00:00+03:00'),
      utcDateTime: DateTime.utc(2026, 8, 22),
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

final class _RecordingService
    implements PdfService<PersistedCalculationPdfSnapshot> {
  _RecordingService(this.bytes);

  final List<int> bytes;
  int calls = 0;

  @override
  Future<List<int>> buildReport({
    required PersistedCalculationPdfSnapshot snapshot,
    required PdfReportOptions options,
  }) async {
    calls += 1;
    return List<int>.from(bytes);
  }
}
