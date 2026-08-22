import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_western_chart_geometry.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_snapshot.dart';

PersistedWesternNatalSnapshot _snapshot() => PersistedWesternNatalSnapshot(
      engineVersion: 'western-engine-1',
      algorithmVersion: 'western-natal-1',
      dataVersion: 'ephemeris-test-1',
      ttJulianDay: 2461041.5,
      sourceId: 'fixture-ephemeris',
      requestedHouseSystem: 'PLACIDUS',
      effectiveHouseSystem: 'PLACIDUS',
      houseCuspsDeg: const <double>[
        90,
        121,
        151,
        180,
        211,
        241,
        270,
        301,
        331,
        0,
        31,
        61,
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

void main() {
  test('sealed Western snapshot round-trips with exact SHA-256', () {
    final original = _snapshot();
    final envelope = PersistedWesternNatalEnvelope.seal(original);
    final parsed = PersistedWesternNatalEnvelope.fromCalculationResult(
      Map<String, dynamic>.from(envelope.toCalculationResult()),
    );

    expect(parsed.snapshotSha256, original.sha256Hex);
    expect(parsed.snapshot.canonicalJson, original.canonicalJson);
    expect(parsed.snapshot.houseCuspsDeg, original.houseCuspsDeg);
    expect(parsed.snapshot.requestedHouseSystem, 'PLACIDUS');
    expect(parsed.snapshot.effectiveHouseSystem, 'PLACIDUS');
  });

  test('tampered persisted Western snapshot is rejected before rendering', () {
    final envelope = PersistedWesternNatalEnvelope.seal(_snapshot());
    final result = Map<String, dynamic>.from(envelope.toCalculationResult());
    final snapshot = Map<String, dynamic>.from(result['snapshot']! as Map);
    final placements = List<dynamic>.from(snapshot['placements']! as List);
    final first = Map<String, dynamic>.from(placements.first as Map);
    first['longitudeDeg'] = 46.0;
    placements[0] = first;
    snapshot['placements'] = placements;
    result['snapshot'] = snapshot;

    expect(
      () => PersistedWesternNatalEnvelope.fromCalculationResult(result),
      throwsA(isA<FormatException>()),
    );
  });

  test('persisted PDF geometry is produced without recalculating chart values', () {
    final snapshot = _snapshot();
    final geometry = PdfWesternChartGeometryAdapter.fromPersistedSnapshot(snapshot);

    expect(geometry.jdTt, snapshot.ttJulianDay);
    expect(geometry.sourceId, snapshot.sourceId);
    expect(geometry.dataVersion, snapshot.dataVersion);
    expect(geometry.ascendantLongitude, 90);
    expect(geometry.houseRays, hasLength(12));
    expect(geometry.houseRays.first.longitudeDegrees, 90);
    expect(geometry.planetMarkers, hasLength(2));
    expect(geometry.planetMarkers.first.longitudeDegrees, 45);
    expect(geometry.aspectChords, hasLength(1));
    expect(geometry.aspectChords.single.aspect.name, 'trine');
  });

  test('snapshot rejects aspects that reference bodies outside placements', () {
    expect(
      () => PersistedWesternNatalSnapshot(
        engineVersion: 'western-engine-1',
        algorithmVersion: 'western-natal-1',
        dataVersion: 'ephemeris-test-1',
        ttJulianDay: 2461041.5,
        sourceId: 'fixture-ephemeris',
        requestedHouseSystem: 'EQUAL',
        effectiveHouseSystem: 'EQUAL',
        houseCuspsDeg: List<double>.generate(12, (index) => index * 30.0),
        placements: const <PersistedWesternNatalPlacement>[
          PersistedWesternNatalPlacement(
            body: 'sun',
            longitudeDeg: 45,
            houseNumber: 2,
            motion: 'direct',
          ),
        ],
        aspects: const <PersistedWesternNatalAspect>[
          PersistedWesternNatalAspect(
            bodyA: 'sun',
            bodyB: 'moon',
            type: 'conjunction',
            exactAngleDeg: 0,
            separationDeg: 0,
            deltaFromExactDeg: 0,
            allowedOrbDeg: 8,
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('unknown persisted body/aspect names fail closed at PDF geometry boundary', () {
    final snapshot = PersistedWesternNatalSnapshot(
      engineVersion: 'western-engine-1',
      algorithmVersion: 'western-natal-1',
      dataVersion: 'ephemeris-test-1',
      ttJulianDay: 2461041.5,
      sourceId: 'fixture-ephemeris',
      requestedHouseSystem: 'EQUAL',
      effectiveHouseSystem: 'EQUAL',
      houseCuspsDeg: List<double>.generate(12, (index) => index * 30.0),
      placements: const <PersistedWesternNatalPlacement>[
        PersistedWesternNatalPlacement(
          body: 'futureBody',
          longitudeDeg: 45,
          houseNumber: 2,
          motion: 'direct',
        ),
      ],
      aspects: const <PersistedWesternNatalAspect>[],
    );

    expect(
      () => PdfWesternChartGeometryAdapter.fromPersistedSnapshot(snapshot),
      throwsA(isA<FormatException>()),
    );
  });
}
