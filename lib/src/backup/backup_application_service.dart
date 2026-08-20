import 'backup_import_coordinator.dart';
import 'backup_package_codec.dart';
import 'backup_platform_gateway.dart';
import 'backup_service.dart';
import 'local_database_backup_exporter.dart';
import 'portable_zip_backup_codec.dart';

abstract interface class BackupPackageSource {
  Future<BackupPackageBytes> exportPackage({
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  });
}

final class LocalDatabaseBackupPackageSource implements BackupPackageSource {
  const LocalDatabaseBackupPackageSource(this.exporter);

  final LocalDatabaseBackupExporter exporter;

  @override
  Future<BackupPackageBytes> exportPackage({
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) {
    return exporter.exportPackage(
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
  }
}

enum BackupUserOperationStatus { completed, cancelled }

final class BackupSaveResult {
  const BackupSaveResult({required this.status, this.uri});
  final BackupUserOperationStatus status;
  final Uri? uri;
}

final class BackupShareResult {
  const BackupShareResult({required this.status, this.shareStatus});
  final BackupUserOperationStatus status;
  final BackupShareStatus? shareStatus;
}

final class BackupRestoreSelection {
  const BackupRestoreSelection({
    required this.fileName,
    required this.preview,
  });

  final String fileName;
  final BackupImportPreview preview;
}

final class BackupPickResult {
  const BackupPickResult({required this.status, this.selection});
  final BackupUserOperationStatus status;
  final BackupRestoreSelection? selection;
}

/// Application-level orchestration for user-directed backup actions.
///
/// Serialization, ZIP validation, platform I/O and database mutation remain
/// separate dependencies. User cancellation is a normal result, not an error.
final class BackupApplicationService {
  const BackupApplicationService({
    required this.packageSource,
    required this.platformGateway,
    required this.importCoordinator,
    this.zipCodec = const PortableZipBackupCodec(),
    this.packageReader = const BackupPackageReader(),
  });

  final BackupPackageSource packageSource;
  final BackupPlatformGateway platformGateway;
  final BackupImportCoordinator importCoordinator;
  final PortableZipBackupCodec zipCodec;
  final BackupPackageReader packageReader;

  Future<BackupSaveResult> exportAndSave({
    required String suggestedFileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) async {
    final bytes = await _buildPortableBackup(
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
    final uri = await platformGateway.saveBackup(
      suggestedFileName: suggestedFileName,
      bytes: bytes,
    );
    return BackupSaveResult(
      status: uri == null ? BackupUserOperationStatus.cancelled : BackupUserOperationStatus.completed,
      uri: uri,
    );
  }

  Future<BackupShareResult> exportAndShare({
    required String fileName,
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
    String? title,
    String? text,
  }) async {
    final bytes = await _buildPortableBackup(
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
    final status = await platformGateway.shareBackup(
      fileName: fileName,
      bytes: bytes,
      title: title,
      text: text,
    );
    return BackupShareResult(
      status: status == BackupShareStatus.dismissed
          ? BackupUserOperationStatus.cancelled
          : BackupUserOperationStatus.completed,
      shareStatus: status,
    );
  }

  Future<BackupPickResult> pickAndPreviewRestore() async {
    final picked = await platformGateway.pickBackup();
    if (picked == null) {
      return const BackupPickResult(status: BackupUserOperationStatus.cancelled);
    }
    final package = zipCodec.decode(picked.bytes);
    final preview = packageReader.preview(package);
    return BackupPickResult(
      status: BackupUserOperationStatus.completed,
      selection: BackupRestoreSelection(fileName: picked.name, preview: preview),
    );
  }

  Future<BackupImportResult> applyRestore({
    required BackupRestoreSelection selection,
    required BackupImportMode mode,
  }) {
    return importCoordinator.apply(preview: selection.preview, mode: mode);
  }

  Future<List<int>> _buildPortableBackup({
    required String appVersion,
    required String engineVersion,
    required String localeTag,
    required DateTime exportedAtUtc,
  }) async {
    final package = await packageSource.exportPackage(
      appVersion: appVersion,
      engineVersion: engineVersion,
      localeTag: localeTag,
      exportedAtUtc: exportedAtUtc,
    );
    return zipCodec.encode(package);
  }
}
