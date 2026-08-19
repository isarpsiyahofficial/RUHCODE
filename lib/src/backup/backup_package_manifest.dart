import 'dart:convert';

import 'package:crypto/crypto.dart';

final class BackupFileManifestEntry {
  const BackupFileManifestEntry({
    required this.fileName,
    required this.recordCount,
    required this.byteLength,
    required this.sha256Hex,
  });

  final String fileName;
  final int recordCount;
  final int byteLength;
  final String sha256Hex;

  Map<String, Object> toJson() => <String, Object>{
        'fileName': fileName,
        'recordCount': recordCount,
        'byteLength': byteLength,
        'sha256': sha256Hex,
      };
}

final class BackupPackageManifestV1 {
  const BackupPackageManifestV1({
    required this.schemaVersion,
    required this.appVersion,
    required this.engineVersion,
    required this.exportedAtUtc,
    required this.localeTag,
    required this.files,
  });

  final int schemaVersion;
  final String appVersion;
  final String engineVersion;
  final DateTime exportedAtUtc;
  final String localeTag;
  final List<BackupFileManifestEntry> files;

  Map<String, Object> toJson() => <String, Object>{
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'engineVersion': engineVersion,
        'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
        'localeTag': localeTag,
        'files': files.map((entry) => entry.toJson()).toList(growable: false),
      };

  String toCanonicalJson() => jsonEncode(toJson());
}

final class BackupPackageManifestBuilder {
  const BackupPackageManifestBuilder();

  BackupFileManifestEntry fileEntry({
    required String fileName,
    required List<int> utf8Bytes,
    required int recordCount,
  }) {
    if (fileName.isEmpty) throw ArgumentError.value(fileName, 'fileName');
    if (recordCount < 0) throw ArgumentError.value(recordCount, 'recordCount');
    return BackupFileManifestEntry(
      fileName: fileName,
      recordCount: recordCount,
      byteLength: utf8Bytes.length,
      sha256Hex: sha256.convert(utf8Bytes).toString(),
    );
  }

  BackupPackageManifestV1 build({
    required int schemaVersion,
    required String appVersion,
    required String engineVersion,
    required DateTime exportedAtUtc,
    required String localeTag,
    required List<BackupFileManifestEntry> files,
  }) {
    if (!exportedAtUtc.isUtc) {
      throw ArgumentError.value(exportedAtUtc, 'exportedAtUtc', 'must be UTC');
    }
    final names = <String>{};
    for (final file in files) {
      if (!names.add(file.fileName)) {
        throw ArgumentError('Duplicate backup manifest file: ${file.fileName}');
      }
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(file.sha256Hex)) {
        throw ArgumentError('Invalid SHA-256 for ${file.fileName}');
      }
    }

    final sorted = List<BackupFileManifestEntry>.of(files)
      ..sort((left, right) => left.fileName.compareTo(right.fileName));

    return BackupPackageManifestV1(
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      engineVersion: engineVersion,
      exportedAtUtc: exportedAtUtc,
      localeTag: localeTag,
      files: List.unmodifiable(sorted),
    );
  }

  bool verifyFile(BackupFileManifestEntry expected, List<int> bytes) {
    if (expected.byteLength != bytes.length) return false;
    return sha256.convert(bytes).toString() == expected.sha256Hex;
  }
}
