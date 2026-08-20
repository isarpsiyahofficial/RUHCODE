import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/local_database.dart';
import 'package:ruh_code/src/entitlements/local_entitlement_time_anchor.dart';

final class _WallClock implements EntitlementWallClock {
  _WallClock(this.value);
  DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _MemoryDatabase implements LocalDatabase {
  final Map<String, Map<String, Map<String, Object?>>> tables = {};

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async => const IntegrityCheckResult(ok: true);

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action) =>
      action(_MemoryTransaction(tables));
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  _MemoryTransaction(this.tables);
  final Map<String, Map<String, Map<String, Object?>>> tables;

  @override
  Future<void> put({required String table, required String id, required Map<String, Object?> value}) async {
    tables.putIfAbsent(table, () => {})[id] = Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> get({required String table, required String id}) async {
    final value = tables[table]?[id];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete({required String table, required String id}) async => tables[table]?.remove(id);

  @override
  Future<Map<String, Map<String, Object?>>> readTable(String table) async =>
      Map<String, Map<String, Object?>>.from(tables[table] ?? {});

  @override
  Future<void> clearTable(String table) async => tables.remove(table);
}

void main() {
  test('first observation stores exact UTC wall time', () async {
    final db = _MemoryDatabase();
    final wall = _WallClock(DateTime.utc(2026, 8, 20, 10));
    final clock = LocalRollbackResistantEntitlementClock(database: db, wallClock: wall);

    final now = await clock.nowUtc();

    expect(now, DateTime.utc(2026, 8, 20, 10));
    expect(
      db.tables[LocalRollbackResistantEntitlementClock.tableName]?
          [LocalRollbackResistantEntitlementClock.recordId]?
          [LocalRollbackResistantEntitlementClock.valueKey],
      '2026-08-20T10:00:00.000Z',
    );
  });

  test('device clock rollback cannot move effective entitlement time backwards', () async {
    final db = _MemoryDatabase();
    final wall = _WallClock(DateTime.utc(2026, 8, 20, 12));
    final clock = LocalRollbackResistantEntitlementClock(database: db, wallClock: wall);
    expect(await clock.nowUtc(), DateTime.utc(2026, 8, 20, 12));

    wall.value = DateTime.utc(2026, 8, 20, 8);

    expect(await clock.nowUtc(), DateTime.utc(2026, 8, 20, 12));
  });

  test('later legitimate wall time advances the persistent anchor', () async {
    final db = _MemoryDatabase();
    final wall = _WallClock(DateTime.utc(2026, 8, 20, 12));
    final clock = LocalRollbackResistantEntitlementClock(database: db, wallClock: wall);
    await clock.nowUtc();

    wall.value = DateTime.utc(2026, 8, 21, 9);

    expect(await clock.nowUtc(), DateTime.utc(2026, 8, 21, 9));
    expect(
      db.tables[LocalRollbackResistantEntitlementClock.tableName]?
          [LocalRollbackResistantEntitlementClock.recordId]?
          [LocalRollbackResistantEntitlementClock.valueKey],
      '2026-08-21T09:00:00.000Z',
    );
  });

  test('time anchor never mutates domain records', () async {
    final db = _MemoryDatabase();
    db.tables['profiles'] = {
      'p1': <String, Object?>{'displayName': 'Keep'},
    };
    final wall = _WallClock(DateTime.utc(2026, 8, 20, 12));
    final clock = LocalRollbackResistantEntitlementClock(database: db, wallClock: wall);

    await clock.nowUtc();
    wall.value = DateTime.utc(2026, 8, 20, 6);
    await clock.nowUtc();

    expect(db.tables['profiles']?['p1']?['displayName'], 'Keep');
  });

  test('non UTC wall clock is rejected', () async {
    final clock = LocalRollbackResistantEntitlementClock(
      database: _MemoryDatabase(),
      wallClock: _WallClock(DateTime(2026, 8, 20, 12)),
    );

    await expectLater(clock.nowUtc(), throwsStateError);
  });
}
