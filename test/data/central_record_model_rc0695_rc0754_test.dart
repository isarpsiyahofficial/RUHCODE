import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/central_record_model.dart';

RecordMetadata meta(String id, RecordKind kind) => RecordMetadata(
  id: OpaqueLocalId(id),
  kind: kind,
  createdAt: DateTime.utc(2026, 9, 8, 7),
  updatedAt: DateTime.utc(2026, 9, 8, 8),
);

BirthPlace place() => BirthPlace(
  countryCode: 'TR',
  cityName: 'Antalya',
  displayText: 'Antalya, Türkiye',
  latitude: 36.8969,
  longitude: 30.7133,
  ianaTimezoneId: 'Europe/Istanbul',
);

CalculationManifestRecord manifest(String engine) => CalculationManifestRecord(
  engineVersion: engine,
  algorithmVersion: 'alg-1',
  dataVersion: 'data-1',
  timezoneDatabaseVersion: '2026a',
  houseSystem: 'Placidus',
  zodiacSystem: 'Tropical',
  nodeMode: 'true',
  latitude: 36.8969,
  longitude: 30.7133,
  utcDateTime: DateTime.utc(2026, 9, 8, 7),
  localDateTimeIso: '2026-09-08T10:00:00+03:00',
  professionalSettings: const {'orbProfile': 'professional-default'},
);

void main() {
  test('Same display name never implies same identity', () {
    final first = OpaqueLocalId('local-0001');
    final second = OpaqueLocalId('local-0002');
    expect(first, isNot(second));
  });

  test('Record metadata preserves UTC creation/update lifecycle', () {
    expect(meta('profile-0001', RecordKind.profile).updatedAt.isUtc, isTrue);
    expect(
      () => RecordMetadata(
        id: OpaqueLocalId('profile-0002'),
        kind: RecordKind.profile,
        createdAt: DateTime.utc(2026, 9, 8, 9),
        updatedAt: DateTime.utc(2026, 9, 8, 8),
      ),
      throwsArgumentError,
    );
  });

  test('Unknown birth time cannot silently become midnight', () {
    final data = BirthData(
      birthDate: DateTime(1990, 5, 12),
      timePrecision: BirthTimePrecision.unknown,
      birthPlace: place(),
    );
    expect(data.localBirthDateTime, isNull);
    expect(
      () => BirthData(
        birthDate: DateTime(1990, 5, 12),
        timePrecision: BirthTimePrecision.unknown,
        birthPlace: place(),
        localBirthDateTime: DateTime(1990, 5, 12),
      ),
      throwsArgumentError,
    );
  });

  test('Approximate and exact birth times remain explicit states', () {
    final approx = BirthData(
      birthDate: DateTime(1990, 5, 12),
      timePrecision: BirthTimePrecision.approximate,
      birthPlace: place(),
      localBirthDateTime: DateTime(1990, 5, 12, 14, 30),
    );
    expect(approx.timePrecision, BirthTimePrecision.approximate);
  });

  test('Sidereal manifest fails closed without ayanamsha', () {
    expect(
      () => CalculationManifestRecord(
        engineVersion: 'e1', algorithmVersion: 'a1', dataVersion: 'd1', timezoneDatabaseVersion: '2026a',
        houseSystem: 'Whole Sign', zodiacSystem: 'Sidereal', nodeMode: 'mean', latitude: 0, longitude: 0,
        utcDateTime: DateTime.utc(2026), localDateTimeIso: '2026-01-01T00:00:00+00:00', professionalSettings: const {},
      ),
      throwsArgumentError,
    );
  });

  test('Old and recalculated results can coexist and be compared', () {
    final old = SavedCalculationRecord(
      meta: meta('calc-old-0001', RecordKind.calculation),
      profileId: OpaqueLocalId('profile-0001'),
      manifest: manifest('engine-1'),
      payloadRef: 'result://old',
    );
    final fresh = SavedCalculationRecord(
      meta: meta('calc-new-0001', RecordKind.calculation),
      profileId: OpaqueLocalId('profile-0001'),
      manifest: manifest('engine-2'),
      payloadRef: 'result://new',
    );
    final comparison = RecalculationComparison(original: old, recalculated: fresh);
    expect(comparison.engineChanged, isTrue);
    expect(comparison.original.payloadRef, 'result://old');
  });

  test('Migration is copy-first and advances schema one step at a time', () {
    final source = DataEnvelope(
      schemaVersion: 1,
      appVersion: '1.0.0',
      engineVersion: 'engine-1',
      exportedAt: DateTime.utc(2026, 9, 8),
      languageCode: 'tr',
      platform: 'android',
      payload: const {'name': 'original'},
    );
    final engine = CopyFirstMigrationEngine(latestSchemaVersion: 3, steps: {
      1: (value) => value.copyWith(schemaVersion: 2, payload: {...value.payload, 'v2': true}),
      2: (value) => value.copyWith(schemaVersion: 3, payload: {...value.payload, 'v3': true}),
    });
    final migrated = engine.migrate(source);
    expect(migrated.schemaVersion, 3);
    expect(source.schemaVersion, 1);
    expect(source.payload.containsKey('v2'), isFalse);
  });

  test('Migration fails closed if an intermediate version is missing', () {
    final source = DataEnvelope(
      schemaVersion: 1, appVersion: '1', engineVersion: '1', exportedAt: DateTime.utc(2026), languageCode: 'en', platform: 'android', payload: const {},
    );
    final engine = CopyFirstMigrationEngine(latestSchemaVersion: 3, steps: {
      1: (value) => value.copyWith(schemaVersion: 2, payload: value.payload),
    });
    expect(() => engine.migrate(source), throwsStateError);
  });
}
