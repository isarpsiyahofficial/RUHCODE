export 'backup_service.dart' show BackupImportMode;

import 'backup_package_codec.dart';
import 'backup_schema.dart';
import 'backup_service.dart';

abstract interface class BackupImportTransaction {
  Future<void> replaceTable(String fileName, List<List<String?>> rows);

  /// Upserts by the schema primary key. Re-importing the same package must not
  /// create duplicate records.
  Future<void> upsertTable({
    required String fileName,
    required int primaryKeyIndex,
    required List<List<String?>> rows,
  });
}

abstract interface class BackupImportStore {
  Future<T> transaction<T>(Future<T> Function(BackupImportTransaction transaction) action);

  /// A replace import creates a durable pre-import snapshot before destructive
  /// table mutation. The store decides how the opaque snapshot token is kept.
  Future<Object> createSafetySnapshot();

  Future<void> restoreSafetySnapshot(Object snapshotToken);
}

final class BackupImportResult {
  const BackupImportResult({
    required this.mode,
    required this.importedRecordCount,
    required this.safetySnapshotCreated,
  });

  final BackupImportMode mode;
  final int importedRecordCount;
  final bool safetySnapshotCreated;
}

/// Typed failure for a replace restore after a safety snapshot was created.
///
/// The UI may only claim that the safety snapshot was restored when
/// [rollbackRestored] is true. The original failure is preserved as [cause].
final class BackupRestoreException implements Exception {
  const BackupRestoreException({
    required this.cause,
    required this.rollbackRestored,
    this.rollbackFailure,
  });

  final Object cause;
  final bool rollbackRestored;
  final Object? rollbackFailure;

  @override
  String toString() {
    if (rollbackRestored) {
      return 'Backup restore failed; safety snapshot was restored. Cause: $cause';
    }
    return 'Backup restore failed and safety snapshot restoration also failed. '
        'Cause: $cause; rollback failure: $rollbackFailure';
  }
}

final class BackupImportCoordinator {
  const BackupImportCoordinator({required this.store});

  final BackupImportStore store;

  Future<BackupImportResult> apply({
    required BackupImportPreview preview,
    required BackupImportMode mode,
  }) async {
    if (!preview.valid) {
      throw StateError('Invalid backup preview cannot mutate storage.');
    }

    switch (mode) {
      case BackupImportMode.merge:
        await store.transaction<void>((transaction) async {
          for (final schema in BackupSchemaRegistry.tables) {
            final primaryKeyIndex = schema.columns.indexWhere(
              (column) => column.name == schema.primaryKey,
            );
            if (primaryKeyIndex < 0) {
              throw StateError('Missing primary key in schema ${schema.fileName}.');
            }
            await transaction.upsertTable(
              fileName: schema.fileName,
              primaryKeyIndex: primaryKeyIndex,
              rows: preview.rowsByTable[schema.fileName] ?? const <List<String?>>[],
            );
          }
        });
        return BackupImportResult(
          mode: mode,
          importedRecordCount: preview.totalRecords,
          safetySnapshotCreated: false,
        );

      case BackupImportMode.replace:
        final snapshot = await store.createSafetySnapshot();
        try {
          await store.transaction<void>((transaction) async {
            // FK parents are replaced before dependants according to the
            // canonical registry order. A real SQL adapter may defer FK checks
            // inside the transaction while preserving the same logical order.
            for (final schema in BackupSchemaRegistry.tables) {
              await transaction.replaceTable(
                schema.fileName,
                preview.rowsByTable[schema.fileName] ?? const <List<String?>>[],
              );
            }
          });
        } catch (cause) {
          try {
            await store.restoreSafetySnapshot(snapshot);
          } catch (rollbackFailure) {
            throw BackupRestoreException(
              cause: cause,
              rollbackRestored: false,
              rollbackFailure: rollbackFailure,
            );
          }
          throw BackupRestoreException(
            cause: cause,
            rollbackRestored: true,
          );
        }
        return BackupImportResult(
          mode: mode,
          importedRecordCount: preview.totalRecords,
          safetySnapshotCreated: true,
        );
    }
  }
}
