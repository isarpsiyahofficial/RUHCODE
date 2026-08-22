import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/pdf_report_contract.dart';
import 'package:ruh_code/src/pdf/persisted_manifest_section.dart';

void main() {
  test('technical section projects persisted manifest without recomputation', () {
    final manifest = CalculationManifest(
      id: EntityId.parse('123e4567-e89b-42d3-a456-426614174000'),
      engineId: 'western.natal',
      engineVersion: 'engine-1',
      algorithmVersion: 'algo-1',
      dataVersion: 'data-1',
      timezoneDatabaseVersion: '2026a',
      localDateTime: DateTime(1990, 1, 1, 12, 30),
      utcDateTime: DateTime.utc(1990, 1, 1, 9, 30),
      location: const LocationRecord(
        label: 'İstanbul',
        countryCode: 'TR',
        latitude: 41.008238,
        longitude: 28.978359,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: CalculationValidity.valid,
      houseSystemId: 'placidus',
      zodiacSystemId: 'tropical',
    );

    final section = PersistedManifestSectionAdapter.build(
      manifest: manifest,
      snapshotDigest: 'a' * 64,
      title: 'Teknik Bilgiler',
      fieldHeader: 'Alan',
      valueHeader: 'Değer',
      labelForField: (id) => id,
    );

    expect(section.sectionId, PdfSectionIds.technicalManifest);
    expect(section.snapshotDigest, 'a' * 64);
    final rows = {for (final row in section.rows.skip(1)) row[0]: row[1]};
    expect(rows['engineId'], 'western.natal');
    expect(rows['houseSystemId'], 'placidus');
    expect(rows['zodiacSystemId'], 'tropical');
    expect(rows['ianaTimeZoneId'], 'Europe/Istanbul');
    expect(rows['latitude'], '41.008238');
    expect(rows['longitude'], '28.978359');
    expect(rows['utcDateTime'], '1990-01-01T09:30:00.000Z');
  });

  test('missing localization fails closed', () {
    final manifest = CalculationManifest(
      id: EntityId.parse('123e4567-e89b-42d3-a456-426614174000'),
      engineId: 'western.natal',
      engineVersion: 'engine-1',
      algorithmVersion: 'algo-1',
      dataVersion: 'data-1',
      localDateTime: DateTime(1990, 1, 1),
      utcDateTime: DateTime.utc(1989, 12, 31, 21),
      location: const LocationRecord(
        label: 'İstanbul',
        countryCode: 'TR',
        latitude: 41.0,
        longitude: 29.0,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: CalculationValidity.valid,
    );

    expect(
      () => PersistedManifestSectionAdapter.build(
        manifest: manifest,
        snapshotDigest: 'b' * 64,
        title: 'Technical',
        fieldHeader: 'Field',
        valueHeader: 'Value',
        labelForField: (_) => '',
      ),
      throwsFormatException,
    );
  });
}
