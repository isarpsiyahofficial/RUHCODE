import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/data_safety_coordinator.dart';
import 'package:ruh_code/src/data/local/local_database.dart';

void main() {
  test('app/locale/theme/tier transitions never mutate stored records', () async {
    final db = _MemoryDatabase();
    final store = _MemorySnapshotStore();
    final coordinator = DataSafetyCoordinator(database: db, snapshots: store);
    await db.transaction((tx) => tx.put(table: 'clients', id: 'c1', value: {'name': 'Ada'}));

    for (final context in NonDestructiveContext.values) {
      await coordinator.applyNonDestructiveContext(context);
    }

    final record = await db.transaction((tx) => tx.get(table: 'clients', id: 'c1'));
    expect(record, {'name': 'Ada'});
  });

  test('related writes are atomic when a later mutation fails', () async {
    final db = _MemoryDatabase(failOnId: 'bad');
    final coordinator = DataSafetyCoordinator(database: db, snapshots: _MemorySnapshotStore());

    expect(
      () => coordinator.atomicMutate(const [
        RecordMutation.put(table: 'clients', id: 'good', value: {'name': 'First'}),
        RecordMutation.put(table: 'clients', id: 'bad', value: {'name': 'Second'}),
      ]),
      throwsStateError,
    );

    final good = await db.transaction((tx) => tx.get(table: 'clients', id: 'good'));
    expect(good, isNull);
  });

  test('startup integrity failure exposes local recovery snapshots', () async {
    final db = _MemoryDatabase(integrityOk: false);
    final store = _MemorySnapshotStore();
    final coordinator = DataSafetyCoordinator(database: db, snapshots: store);
    await store.save(LocalDataSnapshot(
      id: 'snap-1',
      createdAt: DateTime.utc(2026, 9, 8),
      schemaVersion: 1,
      tables: const {'clients': {}},
    ));

    final report = await coordinator.startupIntegrityCheck();
    expect(report.state, StartupIntegrityState.recoveryRequired);
    expect(report.availableSnapshotIds, contains('snap-1'));
  });

  test('snapshot captures and restores complete affected tables atomically', () async {
    final db = _MemoryDatabase();
    final store = _MemorySnapshotStore();
    final coordinator = DataSafetyCoordinator(database: db, snapshots: store);
    await coordinator.atomicMutate(const [
      RecordMutation.put(table: 'clients', id: 'c1', value: {'name': 'Ada'}),
      RecordMutation.put(table: 'notes', id: 'n1', value: {'body': 'first'}),
    ]);
    await coordinator.createSnapshot(
      snapshotId: 'before',
      tables: const ['clients', 'notes'],
      now: DateTime.utc(2026, 9, 8),
    );

    await coordinator.atomicMutate(const [
      RecordMutation.put(table: 'clients', id: 'c1', value: {'name': 'Changed'}),
      RecordMutation.delete(table: 'notes', id: 'n1'),
    ]);
    await coordinator.restoreSnapshot(snapshotId: 'before', safetySnapshotId: 'safety');

    final client = await db.transaction((tx) => tx.get(table: 'clients', id: 'c1'));
    final note = await db.transaction((tx) => tx.get(table: 'notes', id: 'n1'));
    expect(client, {'name': 'Ada'});
    expect(note, {'body': 'first'});
    expect(await store.load('safety'), isNotNull);
  });

  test('snapshot restore rejects incompatible schema before destructive work', () async {
    final db = _MemoryDatabase();
    final store = _MemorySnapshotStore();
    final coordinator = DataSafetyCoordinator(database: db, snapshots: store);
    await store.save(LocalDataSnapshot(
      id: 'future',
      createdAt: DateTime.utc(2026, 9, 8),
      schemaVersion: 2,
      tables: const {'clients': {}},
    ));

    expect(
      () => coordinator.restoreSnapshot(snapshotId: 'future', safetySnapshotId: 'safety'),
      throwsStateError,
    );
    expect(await store.load('safety'), isNull);
  });
}

final class _MemorySnapshotStore implements LocalSnapshotStore {
  final Map<String, LocalDataSnapshot> values = {};

  @override
  Future<LocalDataSnapshot?> load(String id) async => values[id];

  @override
  Future<List<LocalDataSnapshot>> list() async => values.values.toList(growable: false);

  @override
  Future<void> save(LocalDataSnapshot snapshot) async {
    values[snapshot.id] = snapshot;
  }
}

final class _MemoryDatabase implements LocalDatabase {
  _MemoryDatabase({this.failOnId, this.integrityOk = true});

  final String? failOnId;
  bool integrityOk;
  Map<String, Map<String, Map<String, Object?>>> _tables = {};

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async => IntegrityCheckResult(
        ok: integrityOk,
        details: integrityOk ? const ['ok'] : const ['corrupt'],
      );

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) async {
    final working = _deepCopy(_tables);
    final tx = _MemoryTransaction(working, failOnId: failOnId);
    final result = await action(tx);
    _tables = working;
    return result;
  }

  static Map<String, Map<String, Map<String, Object?>>> _deepCopy(
    Map<String, Map<String, Map<String, Object?>>> source,
  ) => {
        for (final table in source.entries)
          table.key: {
            for (final record in table.value.entries)
              record.key: Map<String, Object?>.from(record.value),
          },
      };
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  _MemoryTransaction(this.tables, {this.failOnId});

  final Map<String, Map<String, Map<String, Object?>>> tables;
  final String? failOnId;

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    if (id == failOnId) throw StateError('injected transaction failure');
    tables.putIfAbsent(table, () => {})[id] = Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = tables[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async {
    if (id == failOnId) throw StateError('injected transaction failure');
    tables[table]?.remove(id);
  }

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async => {
        for (final entry in (tables[table] ?? const {}).entries)
          entry.key: Map<String, Object?>.from(entry.value),
      };

  @override
  Future<void> clearTable(String table) async {
    tables[table] = {};
  }
}
