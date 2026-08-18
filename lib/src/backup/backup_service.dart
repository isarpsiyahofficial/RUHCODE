import '../domain/models/core_models.dart';

abstract interface class BackupService {
  Future<BackupExport> exportAll();
  Future<BackupPreview> previewImport(List<int> bytes);
  Future<void> importAll(List<int> bytes, {required BackupImportMode mode});
}

enum BackupImportMode { merge, replace }

final class BackupExport {
  const BackupExport({required this.manifest, required this.bytes});
  final BackupManifest manifest;
  final List<int> bytes;
}

final class BackupPreview {
  const BackupPreview({required this.manifest, required this.recordCounts, required this.valid});
  final BackupManifest manifest;
  final Map<String, int> recordCounts;
  final bool valid;
}
