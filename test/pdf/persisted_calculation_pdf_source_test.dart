import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/core_model_codecs.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/pdf/persisted_calculation_pdf_source.dart';

void main() {
  const calculationId = '11111111-1111-4111-8111-111111111111';
  const manifestId = '22222222-2222-4222-8222-222222222222';
  const ownerId = '33333333-3333-4333-8333-333333333333';

  CalculationManifest manifest({
    CalculationValidity validity = CalculationValidity.valid,
  }) => CalculationManifest(
        id: EntityId.parse(manifestId),
        engineId: 'numerology.pythagorean',
        engineVersion: '1.0.0',
        algorithmVersion: '1',
        dataVersion: '1',
        localDateTime: DateTime.parse('2026-08-22T04:00:00+03:00'),
        utcDateTime: DateTime.parse('2026-08-22T01:00:00Z'),
        location: const LocationRecord(
          label: 'Antalya, Türkiye',
          countryCode: 'TR',
          latitude: 36.8969,
          longitude: 30.7133,
          ianaTimeZoneId: 'Europe/Istanbul',
        ),
        validity: validity,
      );

  Map<String, Object?> calculationRow({String id = calculationId}) =>
      <String, Object?>{
        'id': id,
        'manifestId': manifestId,
        'ownerEntityId': ownerId,
        'calculationType': 'numerology.pythagorean',
        'payloadJson': <String, Object?>{'lifePath': 7},
        'createdAtUtc': '2026-08-22T01:01:00.000Z',
      };

  test('loads calculation and manifest atomically', () async {
    final database = _MemoryDatabase(
      tables: <String, Map<String, Map<String, Object?>>>{
        'calculations': <String, Map<String, Object?>>{
          calculationId: calculationRow(),
        },
        'calculation_manifests': <String, Map<String, Object?>>{
          manifestId: CoreModelCodecs.calculationManifestToMap(manifest()),
        },
      },
    );
    final source = LocalDatabaseProfessionalPdfSnapshotSource(database: database);

    final snapshot = await source.loadByRecordId(calculationId);

    expect(snapshot, isNotNull);
    expect(snapshot!.recordId, calculationId);
    expect(snapshot.ownerEntityId, ownerId);
    expect(snapshot.payload['lifePath'], 7);
    expect(snapshot.manifest.id.value, manifestId);
    expect(database.transactionCount, 1);
  });

  test('missing manifest fails closed', () async {
    final database = _MemoryDatabase(
      tables: <String, Map<String, Map<String, Object?>>>{
        'calculations': <String, Map<String, Object?>>{
          calculationId: calculationRow(),
        },
      },
    );
    final source = LocalDatabaseProfessionalPdfSnapshotSource(database: database);

    await expectLater(
      source.loadByRecordId(calculationId),
      throwsA(isA<StateError>()),
    );
  });

  test('unavailable calculation cannot become professional PDF input', () async {
    final database = _MemoryDatabase(
      tables: <String, Map<String, Map<String, Object?>>>{
        'calculations': <String, Map<String, Object?>>{
          calculationId: calculationRow(),
        },
        'calculation_manifests': <String, Map<String, Object?>>{
          manifestId: CoreModelCodecs.calculationManifestToMap(
            manifest(validity: CalculationValidity.unavailable),
          ),
        },
      },
    );
    final source = LocalDatabaseProfessionalPdfSnapshotSource(database: database);

    await expectLater(
      source.loadByRecordId(calculationId),
      throwsA(isA<StateError>()),
    );
  });

  test('catalog is typed, deterministic and newest first', () async {
    const olderId = '44444444-4444-4444-8444-444444444444';
    final database = _MemoryDatabase(
      tables: <String, Map<String, Map<String, Object?>>>{
        'calculations': <String, Map<String, Object?>>{
          olderId: <String, Object?>{
            ...calculationRow(id: olderId),
            'createdAtUtc': '2026-08-21T01:01:00.000Z',
          },
          calculationId: calculationRow(),
        },
        'calculation_manifests': <String, Map<String, Object?>>{
          manifestId: CoreModelCodecs.calculationManifestToMap(manifest()),
        },
      },
    );
    final source = LocalDatabaseProfessionalPdfSnapshotSource(database: database);

    final records = await source.listAvailableRecords();

    expect(records.map((record) => record.recordId), <String>[calculationId, olderId]);
    expect(records.first.calculationType, 'numerology.pythagorean');
  });
}

final class _MemoryDatabase implements LocalDatabase {
  _MemoryDatabase({
    required Map<String, Map<String, Map<String, Object?>>> tables,
  }) : _tables = tables;

  final Map<String, Map<String, Map<String, Object?>>> _tables;
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
  Future<T> transaction<T>(
    Future<T> Function(LocalDatabaseTransaction tx) action,
  ) async {
    transactionCount += 1;
    return action(_MemoryTransaction(_tables));
  }
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  const _MemoryTransaction(this.tables);
  final Map<String, Map<String, Map<String, Object?>>> tables;

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async =>
      tables[table]?[id] == null
          ? null
          : Map<String, Object?>.from(tables[table]![id]!);

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      <String, Map<String, Object?>>{
        for (final entry in (tables[table] ?? const <String, Map<String, Object?>>{}).entries)
          entry.key: Map<String, Object?>.from(entry.value),
      };

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    (tables[table] ??= <String, Map<String, Object?>>{})[id] = Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    tables[table]?.remove(id);
  }

  @override
  Future<void> clearTable(String table) async {
    tables[table] = <String, Map<String, Object?>>{};
  }
}
