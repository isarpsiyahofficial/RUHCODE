import 'dart:io';

import 'portable_zip_backup_codec.dart';

/// Native file-system adapter for portable Ruh Code backup ZIP bytes.
///
/// Path selection remains a UI/platform concern. This adapter receives an
/// explicit user-selected path, writes atomically in the same directory, and
/// never performs network I/O.
final class PortableBackupFileStore {
  const PortableBackupFileStore({
    this.maxFileBytes = 64 * 1024 * 1024,
    this.requiredExtension = '.ruhcode.zip',
  });

  final int maxFileBytes;
  final String requiredExtension;

  Future<void> save({
    required String path,
    required List<int> zipBytes,
  }) async {
    _validateConfiguration();
    final target = File(_validatePath(path));
    if (zipBytes.isEmpty) {
      throw const FormatException('Portable backup bytes cannot be empty.');
    }
    if (zipBytes.length > maxFileBytes) {
      throw FormatException(
        'Portable backup exceeds file size limit: ${zipBytes.length} > $maxFileBytes.',
      );
    }

    final parent = target.parent;
    if (!await parent.exists()) {
      throw FileSystemException('Backup destination directory does not exist.', parent.path);
    }

    final temp = File('${target.path}.tmp');
    try {
      if (await temp.exists()) {
        await temp.delete();
      }
      final sink = temp.openWrite(mode: FileMode.writeOnly);
      sink.add(zipBytes);
      await sink.flush();
      await sink.close();

      final tempLength = await temp.length();
      if (tempLength != zipBytes.length) {
        throw FileSystemException(
          'Portable backup atomic write length mismatch.',
          temp.path,
        );
      }

      if (await target.exists()) {
        await target.delete();
      }
      await temp.rename(target.path);
    } catch (_) {
      if (await temp.exists()) {
        try {
          await temp.delete();
        } catch (_) {
          // Cleanup failure must not hide the original write failure.
        }
      }
      rethrow;
    }
  }

  Future<List<int>> open(String path) async {
    _validateConfiguration();
    final file = File(_validatePath(path));
    if (!await file.exists()) {
      throw FileSystemException('Portable backup file does not exist.', file.path);
    }
    final length = await file.length();
    if (length <= 0) {
      throw const FormatException('Portable backup file is empty.');
    }
    if (length > maxFileBytes) {
      throw FormatException(
        'Portable backup file exceeds size limit: $length > $maxFileBytes.',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.length != length) {
      throw FileSystemException('Portable backup file changed while being read.', file.path);
    }
    return List<int>.unmodifiable(bytes);
  }

  Future<void> savePackage({
    required String path,
    required BackupPackageBytes package,
    PortableZipBackupCodec codec = const PortableZipBackupCodec(),
  }) {
    return save(path: path, zipBytes: codec.encode(package));
  }

  Future<BackupPackageBytes> openPackage({
    required String path,
    PortableZipBackupCodec codec = const PortableZipBackupCodec(),
  }) async {
    return codec.decode(await open(path));
  }

  String _validatePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Portable backup file path cannot be empty.');
    }
    if (!trimmed.toLowerCase().endsWith(requiredExtension.toLowerCase())) {
      throw FormatException(
        'Portable backup path must end with $requiredExtension.',
      );
    }
    return trimmed;
  }

  void _validateConfiguration() {
    if (maxFileBytes <= 0) {
      throw StateError('Portable backup file size limit must be positive.');
    }
    if (requiredExtension.isEmpty || !requiredExtension.startsWith('.')) {
      throw StateError('Portable backup extension must be a dot-prefixed suffix.');
    }
  }
}
