import 'local_database.dart';

enum NonDestructiveContext {
  appUpdate,
  localeChange,
  themeChange,
  freeToPro,
  proToFree,
}

final class RecordMutation {
  const RecordMutation.put({
    required this.table,
    required this.id,
    required this.value,
  }) : delete = false;

  const RecordMutation.delete({required this.table, required this.id})
      : value = null,
        delete = true;

  final String table;
  final String id;
  final Map<String, Object?>? value;
  final bool delete;
}

final class LocalDataSnapshot {
  LocalDataSnapshot({
    required this.id,
    required DateTime createdAt,
    required this.schemaVersion,
    required Map<String, Map<String, Map<String, Object?>>> tables,
  })  : createdAt = createdAt.toUtc(),
        tables = Map<String, Map<String, Map<String, Object?>>>.unmodifiable({
          for (final entry in tables.entries)
            entry.key: Map<String, Map<String, Object?>>.unmodifiable({
              for (final record in entry.value.entries)
                record.key: Map<String, Object?>.unmodifiable(record.value),
            }),
        }) {
    if (id.trim().isEmpty) throw ArgumentError('snapshot id must not be empty');
    if (schemaVersion < 1) throw ArgumentError('schemaVersion must be positive');
  }

  final String id;
  final DateTime createdAt;
  final int schemaVersion;
  final Map<String, Map<String, Map<String, Object?>>> tables;
}

abstract interface class LocalSnapshotStore {
  Future<void> save(LocalDataSnapshot snapshot);
  Future<LocalDataSnapshot?> load(String id);
  Future<List<LocalDataSnapshot>> list();
}

enum StartupIntegrityState { healthy, recoveryRequired }

final class StartupIntegrityReport {
  const StartupIntegrityReport({
    required this.state,
    required this.details,
    required this.availableSnapshotIds,
  });

  final StartupIntegrityState state;
  final List<String> details;
  final List<String> availableSnapshotIds;
}

/// Owns the fail-closed data-safety boundary for RC-0755..RC-0773.
///
/// Presentation/entitlement changes have no mutation API here. Persistent user
/// data can only change through explicit record transactions, snapshot restore,
/// migration, or backup/import services. This keeps app updates, locale/theme,
/// and Free/PRO transitions from becoming destructive record operations.
final class DataSafetyCoordinator {
  DataSafetyCoordinator({required LocalDatabase database, required LocalSnapshotStore snapshots})
      : _database = database,
        _snapshots = snapshots;

  final LocalDatabase _database;
  final LocalSnapshotStore _snapshots;

  /// Explicitly documents that these state changes are retention-neutral.
  /// No record deletion/rewrite is performed and callers receive no database
  /// transaction handle from this method.
  Future<void> applyNonDestructiveContext(NonDestructiveContext context) async {
    switch (context) {
      case NonDestructiveContext.appUpdate:
      case NonDestructiveContext.localeChange:
      case NonDestructiveContext.themeChange:
      case NonDestructiveContext.freeToPro:
      case NonDestructiveContext.proToFree:
        return;
    }
  }

  /// Applies related mutations atomically. Any exception aborts the complete
  /// transaction so a half-written client/profile/consultation graph cannot be
  /// committed.
  Future<void> atomicMutate(Iterable<RecordMutation> mutations) async {
    final batch = List<RecordMutation>.unmodifiable(mutations);
    if (batch.isEmpty) return;
    for (final mutation in batch) {
      if (mutation.table.trim().isEmpty || mutation.id.trim().isEmpty) {
        throw ArgumentError('mutation table/id must not be empty');
      }
      if (!mutation.delete && mutation.value == null) {
        throw ArgumentError('put mutation requires a value');
      }
    }
    await _database.transaction((tx) async {
      for (final mutation in batch) {
        if (mutation.delete) {
          await tx.delete(table: mutation.table, id: mutation.id);
        } else {
          await tx.put(
            table: mutation.table,
            id: mutation.id,
            value: Map<String, Object?>.from(mutation.value!),
          );
        }
      }
    });
  }

  /// Performs the required database-open integrity gate and exposes only local
  /// recovery choices when corruption is detected.
  Future<StartupIntegrityReport> startupIntegrityCheck() async {
    final result = await _database.integrityCheck();
    final snapshots = await _snapshots.list();
    return StartupIntegrityReport(
      state: result.ok
          ? StartupIntegrityState.healthy
          : StartupIntegrityState.recoveryRequired,
      details: List<String>.unmodifiable(result.details),
      availableSnapshotIds:
          List<String>.unmodifiable(snapshots.map((snapshot) => snapshot.id)),
    );
  }

  /// Captures a transactionally consistent, device-local logical snapshot.
  Future<LocalDataSnapshot> createSnapshot({
    required String snapshotId,
    required Iterable<String> tables,
    DateTime? now,
  }) async {
    final tableList = tables.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet().toList()..sort();
    if (tableList.isEmpty) throw ArgumentError('at least one table is required');

    final captured = await _database.transaction((tx) async {
      final result = <String, Map<String, Map<String, Object?>>>{};
      for (final table in tableList) {
        result[table] = await tx.readTable(table);
      }
      return result;
    });

    final snapshot = LocalDataSnapshot(
      id: snapshotId,
      createdAt: now ?? DateTime.now().toUtc(),
      schemaVersion: _database.schemaVersion,
      tables: captured,
    );
    await _snapshots.save(snapshot);
    return snapshot;
  }

  /// Restores a snapshot atomically. A pre-restore safety snapshot is mandatory
  /// so a post-restore integrity failure can be rolled back without cloud access.
  Future<void> restoreSnapshot({
    required String snapshotId,
    required String safetySnapshotId,
  }) async {
    final target = await _snapshots.load(snapshotId);
    if (target == null) throw StateError('Snapshot not found: $snapshotId');
    if (target.schemaVersion != _database.schemaVersion) {
      throw StateError('Snapshot schema does not match active database schema.');
    }

    final affectedTables = target.tables.keys.toList(growable: false);
    final safety = await createSnapshot(
      snapshotId: safetySnapshotId,
      tables: affectedTables,
    );

    await _replaceTables(target);
    final integrity = await _database.integrityCheck();
    if (integrity.ok) return;

    await _replaceTables(safety);
    final rollbackIntegrity = await _database.integrityCheck();
    if (!rollbackIntegrity.ok) {
      throw StateError('Snapshot restore failed and rollback integrity is not healthy.');
    }
    throw StateError('Snapshot restore failed integrity validation and was rolled back.');
  }

  Future<void> _replaceTables(LocalDataSnapshot snapshot) async {
    await _database.transaction((tx) async {
      for (final table in snapshot.tables.keys) {
        await tx.clearTable(table);
        final records = snapshot.tables[table]!;
        for (final entry in records.entries) {
          await tx.put(table: table, id: entry.key, value: entry.value);
        }
      }
    });
  }
}