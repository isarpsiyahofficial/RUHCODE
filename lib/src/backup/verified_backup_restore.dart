import 'backup_import_coordinator.dart';
import 'backup_package_codec.dart';

abstract interface class BackupPostImportVerifier {
  Future<bool> verify();
}

final class VerifiedBackupRestoreException implements Exception {
  const VerifiedBackupRestoreException({
    required this.cause,
    required this.rollbackRestored,
    this.rollbackFailure,
  });

  final Object cause;
  final bool rollbackRestored;
  final Object? rollbackFailure;

  @override
  String toString() => rollbackRestored
      ? 'Verified backup restore failed and the pre-import snapshot was restored: $cause'
      : 'Verified backup restore failed; rollback also failed. cause=$cause rollback=$rollbackFailure';
}

/// Adds the RC-0847 post-import integrity gate to both merge and replace modes.
///
/// A safety snapshot is created before either mode. This matters for merge: an
/// otherwise valid transaction may commit successfully and only then reveal a
/// cross-table or storage-level integrity problem. The wrapper restores the
/// pre-import snapshot instead of leaving a partially acceptable dataset active.
final class VerifiedBackupRestoreCoordinator {
  const VerifiedBackupRestoreCoordinator({
    required this.coordinator,
    required this.store,
    required this.verifier,
  });

  final BackupImportCoordinator coordinator;
  final BackupImportStore store;
  final BackupPostImportVerifier verifier;

  Future<BackupImportResult> apply({
    required BackupImportPreview preview,
    required BackupImportMode mode,
  }) async {
    if (!preview.valid) {
      throw StateError('Invalid backup preview cannot mutate storage.');
    }

    final preImportSnapshot = await store.createSafetySnapshot();
    try {
      final result = await coordinator.apply(preview: preview, mode: mode);
      final healthy = await verifier.verify();
      if (!healthy) {
        throw StateError('Post-import data integrity validation failed.');
      }
      return result;
    } catch (cause) {
      try {
        await store.restoreSafetySnapshot(preImportSnapshot);
      } catch (rollbackFailure) {
        throw VerifiedBackupRestoreException(
          cause: cause,
          rollbackRestored: false,
          rollbackFailure: rollbackFailure,
        );
      }
      throw VerifiedBackupRestoreException(cause: cause, rollbackRestored: true);
    }
  }
}
