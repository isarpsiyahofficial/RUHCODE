import 'local_database.dart';

typedef RecordEncoder<T> = Map<String, Object?> Function(T value);
typedef RecordDecoder<T> = T Function(Map<String, Object?> value);
typedef RecordId<T> = String Function(T value);

final class JsonRecordRepository<T> {
  const JsonRecordRepository({
    required this.database,
    required this.table,
    required this.idOf,
    required this.encode,
    required this.decode,
  });

  final LocalDatabase database;
  final String table;
  final RecordId<T> idOf;
  final RecordEncoder<T> encode;
  final RecordDecoder<T> decode;

  Future<void> save(T value) {
    return database.transaction((tx) async {
      await tx.put(table: table, id: idOf(value), value: encode(value));
    });
  }

  Future<T?> findById(String id) {
    return database.transaction((tx) async {
      final stored = await tx.get(table: table, id: id);
      return stored == null ? null : decode(stored);
    });
  }

  Future<void> deleteById(String id) {
    return database.transaction((tx) async {
      await tx.delete(table: table, id: id);
    });
  }

  Future<void> replaceAtomically({required T oldValue, required T newValue}) {
    return database.transaction((tx) async {
      final oldId = idOf(oldValue);
      final newId = idOf(newValue);
      if (oldId != newId) {
        await tx.delete(table: table, id: oldId);
      }
      await tx.put(table: table, id: newId, value: encode(newValue));
    });
  }
}
