import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

const String kRuhCodeBackupExtension = '.ruhcode.zip';
const String kRuhCodeBackupMimeType = 'application/zip';

final class PickedBackupDocument {
  const PickedBackupDocument({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

enum BackupShareStatus {
  success,
  dismissed,
  unavailable,
}

final class BackupPlatformPolicy {
  const BackupPlatformPolicy({
    this.maxBackupBytes = 64 * 1024 * 1024,
  });

  final int maxBackupBytes;

  Uint8List validateBytes(List<int> bytes) {
    if (maxBackupBytes <= 0) {
      throw StateError('Backup platform size limit must be positive.');
    }
    if (bytes.isEmpty) {
      throw const FormatException('Portable backup bytes cannot be empty.');
    }
    if (bytes.length > maxBackupBytes) {
      throw FormatException(
        'Portable backup exceeds platform size limit: ${bytes.length} > $maxBackupBytes.',
      );
    }
    return Uint8List.fromList(bytes);
  }

  String validateFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Portable backup file name cannot be empty.');
    }
    if (trimmed.contains('/') || trimmed.contains('\\')) {
      throw const FormatException('Portable backup file name must not contain a path.');
    }
    if (!trimmed.toLowerCase().endsWith(kRuhCodeBackupExtension)) {
      throw const FormatException(
        'Portable backup file name must end with .ruhcode.zip.',
      );
    }
    return trimmed;
  }
}

abstract interface class BackupPlatformGateway {
  Future<Uri?> saveBackup({
    required String suggestedFileName,
    required List<int> bytes,
  });

  Future<PickedBackupDocument?> pickBackup();

  Future<BackupShareStatus> shareBackup({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  });
}

/// Native/platform adapter for user-directed backup import/export operations.
///
/// This layer is intentionally separate from backup serialization and SQLite.
/// It delegates file selection to the operating system and never performs
/// network I/O. Portable backup bytes remain the same bytes produced by the
/// strict ZIP/package layer.
final class NativeBackupPlatformGateway implements BackupPlatformGateway {
  const NativeBackupPlatformGateway({
    this.policy = const BackupPlatformPolicy(),
  });

  final BackupPlatformPolicy policy;

  @override
  Future<Uri?> saveBackup({
    required String suggestedFileName,
    required List<int> bytes,
  }) async {
    final safeName = policy.validateFileName(suggestedFileName);
    final data = policy.validateBytes(bytes);

    return FilePicker.saveFile(
      dialogTitle: 'Ruh Code yedeğini kaydet',
      fileName: safeName,
      bytes: data,
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
  }

  @override
  Future<PickedBackupDocument?> pickBackup() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (file == null) {
      return null;
    }

    final safeName = policy.validateFileName(file.name);
    final bytes = policy.validateBytes(await file.readAsBytes());
    return PickedBackupDocument(name: safeName, bytes: bytes);
  }

  @override
  Future<BackupShareStatus> shareBackup({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  }) async {
    final safeName = policy.validateFileName(fileName);
    final data = policy.validateBytes(bytes);

    final result = await SharePlus.instance.share(
      ShareParams(
        title: title,
        text: text,
        files: [
          XFile.fromData(
            data,
            mimeType: kRuhCodeBackupMimeType,
          ),
        ],
        fileNameOverrides: [safeName],
      ),
    );

    return switch (result.status) {
      ShareResultStatus.success => BackupShareStatus.success,
      ShareResultStatus.dismissed => BackupShareStatus.dismissed,
      ShareResultStatus.unavailable => BackupShareStatus.unavailable,
    };
  }
}