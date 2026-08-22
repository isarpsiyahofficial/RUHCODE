import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_pdf.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_snapshot.dart';

PersistedWesternNatalSnapshot _westernSnapshot({
  String engineVersion = 'western-engine-1',
  String algorithmVersion = 'western-natal-1',
  String dataVersion = 'ephemeris-1',
}) =>
    PersistedWesternNatalSnapshot(
      engineVersion: engineVersion,
      algorithmVersion: algorithmVersion,
      dataVersion: dataVersion,
      ttJulianDay: 2461041.5,
      sourceId: 'fixture-ephemeris',
      requestedHouseSystem: 'EQUAL',
      effectiveHouseSystem: 'EQUAL',
      houseCuspsDeg: const <double>[
        90,
        120,
        150,
        180,
        210,
        240,
        270,
        300,
        330,
        0,
        30,
        60,
      ],
      placements: const <PersistedWesternNatalPlacement>[
        PersistedWesternNatalPlacement(
          body: 'sun',
          longitudeDeg: 45,
          houseNumber: 11,
          motion: 'direct',
        ),
        PersistedWesternNatalPlacement(
          body: 'moon',
          longitudeDeg: 165,
          houseNumber: 3,
          motion: 'direct',
        ),
      ],
      aspects: const <PersistedWesternNatalAspect>[
        PersistedWesternNatalAspect(
          bodyA: 'sun',
          bodyB: 'moon',
          type: 'trine',
          exactAngleDeg: 120,
          separationDeg: 120,
          deltaFromExactDeg: 0,
          allowedOrbDeg: 7,
        ),
      ],
    );

CalculationManifest _manifest({
  String engineVersion = 'western-engine-1',
  String algorithmVersion = 'western-natal-1',
  String dataVersion = 'ephemeris-1',
}) =>
    CalculationManifest(
      id: EntityId.parse('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
      engineId: 'western.natal',
      engineVersion: engineVersion,
      algorithmVersion: algorithmVersion,
      dataVersion: dataVersion,
      localDateTime: DateTime(2026, 8, 22, 12),
      utcDateTime: DateTime.utc(2026, 8, 22, 9),
      location: const LocationRecord(
        label: 'İstanbul',
        countryCode: 'TR',
        latitude: 41.0082,
        longitude: 28.9784,
        ianaTimeZoneId: 'Europe/Istanbul',
      ),
      validity: CalculationValidity.valid,
      houseSystemId: 'EQUAL',
      zodiacSystemId: 'TROPICAL',
    );

PersistedCalculationPdfSnapshot _persisted({
  String calculationType = persistedWesternNatalCalculationType,
  String manifestEngineVersion = 'western-engine-1',
  String manifestAlgorithmVersion = 'western-natal-1',
  String manifestDataVersion = 'ephemeris-1',
}) {
  final western = _westernSnapshot();
  final envelope = PersistedWesternNatalEnvelope.seal(western);
  return PersistedCalculationPdfSnapshot(
    recordId: 'calc-1',
    ownerEntityId: 'profile-1',
    calculationType: calculationType,
    payload: Map<String, Object?>.from(envelope.toCalculationResult()),
    createdAtUtc: DateTime.utc(2026, 8, 22, 9),
    manifest: _manifest(
      engineVersion: manifestEngineVersion,
      algorithmVersion: manifestAlgorithmVersion,
      dataVersion: manifestDataVersion,
    ),
  );
}

void main() {
  test('reader returns fingerprinted geometry from exact persisted snapshot', () {
    final data = PersistedWesternNatalPdfReader.read(_persisted());

    expect(data.recordId, 'calc-1');
    expect(data.snapshotSha256, data.snapshot.sha256Hex);
    expect(data.geometry.houseRays, hasLength(12));
    expect(data.geometry.planetMarkers, hasLength(2));
    expect(data.geometry.aspectChords, hasLength(1));
  });

  test('wrong calculation type fails closed', () {
    expect(
      () => PersistedWesternNatalPdfReader.read(
        _persisted(calculationType: 'numerology.pythagorean'),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('manifest engine version drift fails closed', () {
    expect(
      () => PersistedWesternNatalPdfReader.read(
        _persisted(manifestEngineVersion: 'western-engine-2'),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('manifest algorithm version drift fails closed', () {
    expect(
      () => PersistedWesternNatalPdfReader.read(
        _persisted(manifestAlgorithmVersion: 'western-natal-2'),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('manifest data version drift fails closed', () {
    expect(
      () => PersistedWesternNatalPdfReader.read(
        _persisted(manifestDataVersion: 'ephemeris-2'),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
