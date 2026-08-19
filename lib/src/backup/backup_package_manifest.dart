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

  factory BackupFileManifestEntry.fromJson(Map<String, Object?> json) {
    final fileName = json['fileName'];
    final recordCount = json['recordCount'];
    final byteLength = json['byteLength'];
    final digest = json['sha256'];
    if (fileName is! String || fileName.isEmpty) {
      throw const FormatException('Backup manifest fileName must be a non-empty string.');
    }
    if (recordCount is! int || recordCount < 0) {
      throw FormatException('Backup manifest recordCount is invalid for $fileName.');
    }
    if (byteLength is! int || byteLength < 0) {
      throw FormatException('Backup manifest byteLength is invalid for $fileName.');
    }
    if (digest is! String || !RegExp(r'^[0-9a-f]{64}$').hasMatch(digest)) {
      throw FormatException('Backup manifest SHA-256 is invalid for $fileName.');
    }
    return BackupFileManifestEntry(
      fileName: fileName,
      recordCount: recordCount,
      byteLength: byteLength,
      sha256Hex: digest,
    );
  }
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

  factory BackupPackageManifestV1.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    final appVersion = json['appVersion'];
    final engineVersion = json['engineVersion'];
    final exportedAtRaw = json['exportedAtUtc'];
    final localeTag = json['localeTag'];
    final rawFiles = json['files'];
    if (schemaVersion is! int || schemaVersion < 1) {
      throw const FormatException('Backup manifest schemaVersion is invalid.');
    }
    if (appVersion is! String || appVersion.isEmpty) {
      throw const FormatException('Backup manifest appVersion is invalid.');
    }
    if (engineVersion is! String || engineVersion.isEmpty) {
      throw const FormatException('Backup manifest engineVersion is invalid.');
    }
    if (exportedAtRaw is! String) {
      throw const FormatException('Backup manifest exportedAtUtc is invalid.');
    }
    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null || !exportedAt.isUtc || !exportedAtRaw.endsWith('Z')) {
      throw const FormatException('Backup manifest exportedAtUtc must be UTC ISO-8601 ending in Z.');
    }
    if (localeTag is! String || localeTag.isEmpty) {
      throw const FormatException('Backup manifest localeTag is invalid.');
    }
    if (rawFiles is! List) {
      throw const FormatException('Backup manifest files must be a list.');
    }
    final files = rawFiles.map((item) {
      if (item is! Map) {
        throw const FormatException('Backup manifest file entry must be an object.');
      }
      return BackupFileManifestEntry.fromJson(Map<String, Object?>.from(item));
    }).toList(growable: false);
    return BackupPackageManifestBuilder().build(
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      engineVersion: engineVersion,
      exportedAtUtc: exportedAt,
      localeTag: localeTag,
      files: files,
    );
  }

  factory BackupPackageManifestV1.parse(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Backup manifest root must be an object.');
    }
    return BackupPackageManifestV1.fromJson(Map<String, Object?>.from(decoded));
  }
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
    if (schemaVersion < 1) throw ArgumentError.value(schemaVersion, 'schemaVersion');
    if (appVersion.isEmpty) throw ArgumentError.value(appVersion, 'appVersion');
    if (engineVersion.isEmpty) throw ArgumentError.value(engineVersion, 'engineVersion');
    if (localeTag.isEmpty) throw ArgumentError.value(localeTag, 'localeTag');
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
