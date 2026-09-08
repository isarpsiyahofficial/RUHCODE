import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_package_manifest.dart';
import 'package:ruh_code/src/backup/backup_service.dart';
import 'package:ruh_code/src/backup/verified_backup_restore.dart';

void main() {
  test('post-import integrity failure restores pre-import snapshot for merge', () async {
    final store = _Store();
    final coordinator = BackupImportCoordinator(store: store);
    final verified = VerifiedBackupRestoreCoordinator(
      coordinator: coordinator,
      store: store,
      verifier: _Verifier(false),
    );

    expect(
      () => verified.apply(preview: _validPreview(), mode: BackupImportMode.merge),
      throwsA(isA<VerifiedBackupRestoreException>()),
    );
    expect(store.snapshotCount, 1);
    expect(store.restoreCount, 1);
  });

  test('post-import integrity success keeps imported data active', () async {
    final store = _Store();
    final verified = VerifiedBackupRestoreCoordinator(
      coordinator: BackupImportCoordinator(store: store),
      store: store,
      verifier: _Verifier(true),
    );

    final result = await verified.apply(
      preview: _validPreview(),
      mode: BackupImportMode.merge,
    );
    expect(result.mode, BackupImportMode.merge);
    expect(store.restoreCount, 0);
  });

  test('invalid preview never creates a safety snapshot or mutates storage', () async {
    final store = _Store();
    final verified = VerifiedBackupRestoreCoordinator(
      coordinator: BackupImportCoordinator(store: store),
      store: store,
      verifier: _Verifier(true),
    );
    final invalid = BackupImportPreview(
      manifest: _manifest(),
      rowsByTable: const {},
      recordCounts: const {},
      issues: const [BackupValidationIssue(code: 'invalid', message: 'invalid')],
    );

    expect(
      () => verified.apply(preview: invalid, mode: BackupImportMode.replace),
      throwsStateError,
    );
    expect(store.snapshotCount, 0);
  });
}

BackupImportPreview _validPreview() => BackupImportPreview(
      manifest: _manifest(),
      rowsByTable: const {},
      recordCounts: const {},
      issues: const [],
    );

BackupPackageManifestV1 _manifest() => BackupPackageManifestV1(
      schemaVersion: 1,
      appVersion: '1.0.0',
      engineVersion: 'engine-1',
      exportedAtUtc: DateTime.utc(2026, 9, 8),
      localeTag: 'tr',
      files: const [],
    );

final class _Verifier implements BackupPostImportVerifier {
  const _Verifier(this.result);
  final bool result;

  @override
  Future<bool> verify() async => result;
}

final class _Store implements BackupImportStore {
  int snapshotCount = 0;
  int restoreCount = 0;

  @override
  Future<Object> createSafetySnapshot() async {
    snapshotCount++;
    return 'snapshot-$snapshotCount';
  }

  @override
  Future<void> restoreSafetySnapshot(Object snapshotToken) async {
    restoreCount++;
  }

  @override
  Future<T> transaction<T>(Future<T> Function(BackupImportTransaction transaction) action) =>
      action(_Transaction());
}

final class _Transaction implements BackupImportTransaction {
  @override
  Future<void> replaceTable(String fileName, List<List<String?>> rows) async {}

  @override
  Future<void> upsertTable({
    required String fileName,
    required int primaryKeyIndex,
    required List<List<String?>> rows,
  }) async {}
}
