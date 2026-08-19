import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/local/json_record_repository.dart';
import 'package:ruh_code/src/data/local/local_database.dart';

void main() {
  test('save find and delete use transactional storage', () async {
    final database = _MemoryDatabase();
    final repository = _repository(database);
    final item = _Item('item-1', 'alpha');

    await repository.save(item);
    expect(await repository.findById('item-1'), item);

    await repository.deleteById('item-1');
    expect(await repository.findById('item-1'), isNull);
    expect(database.transactionCount, 4);
  });

  test('atomic replace moves an entity to a new id in one transaction', () async {
    final database = _MemoryDatabase();
    final repository = _repository(database);
    final oldItem = _Item('old-id', 'old');
    final newItem = _Item('new-id', 'new');

    await repository.save(oldItem);
    final beforeReplaceTransactions = database.transactionCount;
    await repository.replaceAtomically(oldValue: oldItem, newValue: newItem);

    expect(database.transactionCount, beforeReplaceTransactions + 1);
    expect(await repository.findById('old-id'), isNull);
    expect(await repository.findById('new-id'), newItem);
  });

  test('failed atomic replace rolls the delete back', () async {
    final database = _MemoryDatabase()..failNextPutForId = 'new-id';
    final repository = _repository(database);
    final oldItem = _Item('old-id', 'old');
    final newItem = _Item('new-id', 'new');

    database.failNextPutForId = null;
    await repository.save(oldItem);
    database.failNextPutForId = 'new-id';

    await expectLater(
      repository.replaceAtomically(oldValue: oldItem, newValue: newItem),
      throwsStateError,
    );

    expect(await repository.findById('old-id'), oldItem);
    expect(await repository.findById('new-id'), isNull);
  });
}

JsonRecordRepository<_Item> _repository(LocalDatabase database) {
  return JsonRecordRepository<_Item>(
    database: database,
    table: 'items',
    idOf: (value) => value.id,
    encode: (value) => <String, Object?>{'id': value.id, 'label': value.label},
    decode: (value) => _Item(value['id']! as String, value['label']! as String),
  );
}

final class _Item {
  const _Item(this.id, this.label);
  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is _Item && other.id == id && other.label == label;

  @override
  int get hashCode => Object.hash(id, label);
}

final class _MemoryDatabase implements LocalDatabase {
  Map<String, Map<String, Map<String, Object?>>> _tables = {};
  String? failNextPutForId;
  int transactionCount = 0;

  @override
  int get schemaVersion => 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<IntegrityCheckResult> integrityCheck() async {
    return const IntegrityCheckResult(ok: true);
  }

  @override
  Future<void> migrate({required int fromVersion, required int toVersion}) async {
    if (fromVersion != toVersion) {
      throw UnsupportedError('Memory test database has no migrations.');
    }
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(LocalDatabaseTransaction tx) action,
  ) async {
    transactionCount += 1;
    final snapshot = _clone(_tables);
    final tx = _MemoryTransaction(this);
    try {
      return await action(tx);
    } catch (_) {
      _tables = snapshot;
      rethrow;
    }
  }

  static Map<String, Map<String, Map<String, Object?>>> _clone(
    Map<String, Map<String, Map<String, Object?>>> source,
  ) {
    return source.map(
      (table, rows) => MapEntry(
        table,
        rows.map((id, value) => MapEntry(id, Map<String, Object?>.from(value))),
      ),
    );
  }
}

final class _MemoryTransaction implements LocalDatabaseTransaction {
  _MemoryTransaction(this.database);
  final _MemoryDatabase database;

  @override
  Future<void> put({
    required String table,
    required String id,
    required Map<String, Object?> value,
  }) async {
    if (database.failNextPutForId == id) {
      database.failNextPutForId = null;
      throw StateError('Injected put failure.');
    }
    final rows = database._tables.putIfAbsent(
      table,
      () => <String, Map<String, Object?>>{},
    );
    rows[id] = Map<String, Object?>.from(value);
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
    return rows.map(
      (id, value) => MapEntry(id, Map<String, Object?>.from(value)),
    );
  }

  @override
  Future<void> clearTable(String table) async {
    database._tables.remove(table);
  }
}
