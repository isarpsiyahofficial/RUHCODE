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
}

final class IntegrityCheckResult {
  const IntegrityCheckResult({required this.ok, this.details = const <String>[]});
  final bool ok;
  final List<String> details;
}
