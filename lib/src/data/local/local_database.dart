abstract interface class LocalDatabase {
  int get schemaVersion;

  Future<void> open();
  Future<void> close();
  Future<IntegrityCheckResult> integrityCheck();

  Future<T> transaction<T>(Future<T> Function(LocalDatabaseTransaction tx) action);
  Future<void> migrate({required int fromVersion, required int toVersion});
}

abstract interface class LocalDatabaseTransaction {
  Future<void> put({required String table, required String id, required Map<String, Object?> value});
  Future<Map<String, Object?>?> get({required String table, required String id});
  Future<void> delete({required String table, required String id});

  /// Returns every logical record in [table], keyed by its stable record id.
  /// Backup/restore uses this only inside a database transaction so snapshots
  /// and destructive replacement never observe a partially mutated table.
  Future<Map<String, Map<String, Object?>>> readTable(String table);

  /// Removes every logical record in [table]. This is intentionally available
  /// only on the transaction interface; callers cannot perform a destructive
  /// table clear outside an atomic transaction.
  Future<void> clearTable(String table);
}

final class IntegrityCheckResult {
  const IntegrityCheckResult({required this.ok, this.details = const <String>[]});
  final bool ok;
  final List<String> details;
}
