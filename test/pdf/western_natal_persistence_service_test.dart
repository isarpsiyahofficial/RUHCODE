import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_snapshot.dart';
import 'package:ruh_code/src/pdf/western_natal_persistence_service.dart';

void main() {
  test('manifest and sealed snapshot persist atomically and round-trip', () async {
    final database = _MemoryDatabase();
    final service = WesternNatalPersistenceService(database: database);
    final manifest = _manifest();
    final snapshot = _snapshot();

    final result = await service.save(
      calculationId: 'calc-western-1',
      ownerEntityId: 'owner-1',
      manifest: manifest,
      snapshot: snapshot,
      createdAtUtc: DateTime.utc(2026, 8, 22, 12),
    );

    expect(database.transactionCount, 1);
    expect(result.snapshotSha256, snapshot.sha256Hex);
    final source = LocalDatabaseProfessionalPdfSnapshotSource(database: database);
    final persisted = await source.loadByRecordId('calc-western-1');
    expect(persisted, isNotNull);
    expect(persisted!.manifest.id, manifest.id);
    expect(persisted.calculationType, persistedWesternNatalCalculationType);
    final envelope = PersistedWesternNatalEnvelope.fromCalculationResult(
      persisted.payload.map((key, value) => MapEntry(key, value)),
    );
    expect(envelope.snapshotSha256, snapshot.sha256Hex);
    expect(envelope.snapshot.canonicalJson, snapshot.canonicalJson);
  });

  test('calculation write failure rolls manifest back in same transaction', () async {
    final database = _MemoryDatabase()..failTable = 'calculations';
    final manifest = _manifest();

    await expectLater(
      WesternNatalPersistenceService(database: database).save(
        calculationId: 'calc-western-rollback',
        ownerEntityId: 'owner-1',
        manifest: manifest,
        snapshot: _snapshot(),
        createdAtUtc: DateTime.utc(2026, 8, 22, 12),
      ),
      throwsStateError,
    );

    final manifestRows = await database.transaction((tx) => tx.readTable('calculation_manifests'));
    final calculationRows = await database.transaction((tx) => tx.readTable('calculations'));
    expect(manifestRows, isEmpty);
    expect(calculationRows, isEmpty);
  });

  test('manifest provenance mismatch is rejected before transaction', () async {
    final database = _MemoryDatabase();
    final badManifest = _manifest(engineVersion: 'wrong-engine-version');

    await expectLater(
      WesternNatalPersistenceService(database: database).save(
        calculationId: 'calc-western-bad',
        ownerEntityId: 'owner-1',
        manifest: badManifest,
        snapshot: _snapshot(),
        createdAtUtc: DateTime.utc(2026, 8, 22, 12),
      ),
      throwsStateError,
    );
    expect(database.transactionCount, 0);
  });
}

CalculationManifest _manifest({String engineVersion = 'western-engine-1'}) {
  return CalculationManifest(
    id: EntityId.parse('123e4567-e89b-42d3-a456-426614174000'),
    engineId: 'western.natal',
    engineVersion: engineVersion,
    algorithmVersion: 'western-algorithm-1',
    dataVersion: 'ephemeris-test-1',
    timezoneDatabaseVersion: 'tzdb-test-1',
    localDateTime: DateTime(1990, 1, 1, 12),
    utcDateTime: DateTime.utc(1990, 1, 1, 10),
    location: const LocationRecord(
      label: 'Test City',
      countryCode: 'TR',
      latitude: 40.0,
      longitude: 30.0,
      ianaTimeZoneId: 'Europe/Istanbul',
    ),
    validity: CalculationValidity.valid,
    houseSystemId: 'wholeSign',
    zodiacSystemId: 'tropical',
  );
}

PersistedWesternNatalSnapshot _snapshot() {
  return PersistedWesternNatalSnapshot(
    engineVersion: 'western-engine-1',
    algorithmVersion: 'western-algorithm-1',
    dataVersion: 'ephemeris-test-1',
    ttJulianDay: 2447892.0,
    sourceId: 'fixture-source',
    requestedHouseSystem: 'wholeSign',
    effectiveHouseSystem: 'wholeSign',
    houseCuspsDeg: List<double>.generate(12, (index) => index * 30.0),
    placements: const <PersistedWesternNatalPlacement>[
      PersistedWesternNatalPlacement(
        body: 'sun',
        longitudeDeg: 0.0,
        houseNumber: 1,
        motion: 'direct',
      ),
      PersistedWesternNatalPlacement(
        body: 'moon',
        longitudeDeg: 60.0,
        houseNumber: 3,
        motion: 'direct',
      ),
    ],
    aspects: const <PersistedWesternNatalAspect>[
      PersistedWesternNatalAspect(
        bodyA: 'sun',
        bodyB: 'moon',
        type: 'sextile',
        exactAngleDeg: 60.0,
        separationDeg: 60.0,
        deltaFromExactDeg: 0.0,
        allowedOrbDeg: 6.0,
      ),
    ],
  );
}

final class _MemoryDatabase implements LocalDatabase {
  Map<String, Map<String, Map<String, Object?>>> _tables = {};
  String? failTable;
  int transactionCount = 0;

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async =>
      const IntegrityCheckResult(ok: true);

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) async {
    transactionCount += 1;
    final snapshot = _tables.map(
      (table, rows) => MapEntry(
        table,
        rows.map((id, value) => MapEntry(id, Map<String, Object?>.from(value))),
      ),
    );
    try {
      return await action(_MemoryTransaction(this));
    } catch (_) {
      _tables = snapshot;
      rethrow;
    }
  }
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  _MemoryTransaction(this.database);
  final _MemoryDatabase database;

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    if (database.failTable == table) throw StateError('Injected $table failure.');
    database._tables.putIfAbsent(table, () => <String, Map<String, Object?>>{})[id] =
        Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = database._tables[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    database._tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async {
    final rows = database._tables[table] ?? const <String, Map<String, Object?>>{};
    return rows.map((id, value) => MapEntry(id, Map<String, Object?>.from(value)));
  }

  @override
  Future<void> clearTable(String table) async {
    database._tables.remove(table);
  }
}
