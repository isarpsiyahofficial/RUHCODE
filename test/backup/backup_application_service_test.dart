import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_application_service.dart';
import 'package:ruh_code/src/backup/backup_import_coordinator.dart';
import 'package:ruh_code/src/backup/backup_package_codec.dart';
import 'package:ruh_code/src/backup/backup_platform_gateway.dart';
import 'package:ruh_code/src/backup/backup_schema.dart';
import 'package:ruh_code/src/backup/portable_zip_backup_codec.dart';

void main() {
  group('BackupApplicationService', () {
    test('save cancellation is a normal result', () async {
      final gateway = _FakeGateway(saveUri: null);
      final service = _service(gateway);

      final result = await service.exportAndSave(
        suggestedFileName: 'ruh-code.ruhcode.zip',
        appVersion: '1.0.0',
        engineVersion: '1',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      );

      expect(result.status, BackupUserOperationStatus.cancelled);
      expect(result.uri, isNull);
      expect(gateway.lastSavedBytes, isNotEmpty);
    });

    test('picker cancellation does not attempt import', () async {
      final gateway = _FakeGateway(picked: null);
      final store = _RecordingStore();
      final service = _service(gateway, store: store);

      final result = await service.pickAndPreviewRestore();

      expect(result.status, BackupUserOperationStatus.cancelled);
      expect(result.selection, isNull);
      expect(store.transactionCount, 0);
    });

    test('picked portable backup is strictly previewed before mutation', () async {
      const writer = BackupPackageWriter();
      const zip = PortableZipBackupCodec();
      final package = writer.write(
        rowsByTable: {
          for (final table in BackupSchemaRegistry.tables)
            table.fileName: const <List<String?>>[],
        },
        appVersion: '1.0.0',
        engineVersion: '1',
        localeTag: 'en',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      );
      final gateway = _FakeGateway(
        picked: PickedBackupDocument(
          name: 'restore.ruhcode.zip',
          bytes: zip.encode(package),
        ),
      );
      final store = _RecordingStore();
      final service = _service(gateway, store: store);

      final picked = await service.pickAndPreviewRestore();
      expect(picked.status, BackupUserOperationStatus.completed);
      expect(picked.selection!.preview.valid, isTrue);
      expect(store.transactionCount, 0, reason: 'preview must not mutate storage');

      final applied = await service.applyRestore(
        selection: picked.selection!,
        mode: BackupImportMode.merge,
      );
      expect(applied.mode, BackupImportMode.merge);
      expect(store.transactionCount, 1);
    });

    test('dismissed share is reported as user cancellation', () async {
      final gateway = _FakeGateway(shareStatus: BackupShareStatus.dismissed);
      final service = _service(gateway);

      final result = await service.exportAndShare(
        fileName: 'ruh-code.ruhcode.zip',
        appVersion: '1.0.0',
        engineVersion: '1',
        localeTag: 'tr',
        exportedAtUtc: DateTime.utc(2026, 8, 20),
      );

      expect(result.status, BackupUserOperationStatus.cancelled);
      expect(result.shareStatus, BackupShareStatus.dismissed);
    });
  });
}

BackupApplicationService _service(
  _FakeGateway gateway, {
  _RecordingStore? store,
}) {
  final importStore = store ?? _RecordingStore();
  return BackupApplicationService(
    packageSource: const _EmptyPackageSource(),
    platformGateway: gateway,
    importCoordinator: BackupImportCoordinator(store: importStore),
  );
}

final class _EmptyPackageSource implements BackupPackageSource {
  const _EmptyPackageSource();

  @override
  Future<BackupPackageBytes> exportPackage({
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) async {
    return const BackupPackageWriter().write(
      rowsByTable: {
        for (final table in BackupSchemaRegistry.tables)
          table.fileName: const <List<String?>>[],
      },
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
  }
}

final class _FakeGateway implements BackupPlatformGateway {
  _FakeGateway({
    this.saveUri,
    this.picked,
    this.shareStatus = BackupShareStatus.success,
  });

  final Uri? saveUri;
  final PickedBackupDocument? picked;
  final BackupShareStatus shareStatus;
  List<int> lastSavedBytes = const [];

  @override
  Future<PickedBackupDocument?> pickBackup() async => picked;

  @override
  Future<Uri?> saveBackup({
    required String suggestedFileName,
    required List<int> bytes,
  }) async {
    lastSavedBytes = List<int>.from(bytes);
    return saveUri;
  }

  @override
  Future<BackupShareStatus> shareBackup({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  }) async => shareStatus;
}

final class _RecordingStore implements BackupImportStore {
  int transactionCount = 0;

  @override
  Future<Object> createSafetySnapshot() async => Object();

  @override
  Future<void> restoreSafetySnapshot(Object snapshotToken) async {}

  @override
  Future<T> transaction<T>(Future<T> Function(BackupImportTransaction transaction) action) async {
    transactionCount += 1;
    return action(_NoOpTransaction());
  }
}

final class _NoOpTransaction implements BackupImportTransaction {
  @override
  Future<void> replaceTable(String fileName, List<List<String?>> rows) async {}

  @override
  Future<void> upsertTable({
    required String fileName,
    required int primaryKeyIndex,
    required List<List<String?>> rows,
  }) async {}
}
