import 'dart:collection';
import 'dart:convert';

enum BackupReferenceSeverity { warning, critical }

final class BackupReferenceIssue {
  const BackupReferenceIssue({
    required this.code,
    required this.severity,
    required this.recordId,
    required this.message,
  });

  final String code;
  final BackupReferenceSeverity severity;
  final String recordId;
  final String message;
}

final class BackupAssetRef {
  const BackupAssetRef({
    required this.assetId,
    required this.relativePath,
    required this.mediaType,
  });

  final String assetId;
  final String relativePath;
  final String mediaType;

  String get csvReference => 'asset:$assetId';

  void validate() {
    if (assetId.trim().isEmpty) throw ArgumentError('Backup assetId must not be empty');
    if (relativePath.trim().isEmpty) throw ArgumentError('Backup asset path must not be empty');
    if (relativePath.startsWith('/') || relativePath.contains('..')) {
      throw ArgumentError('Backup asset path must be package-relative and traversal-safe');
    }
    if (!relativePath.startsWith('assets/')) {
      throw ArgumentError('Binary backup assets must live below assets/');
    }
    if (mediaType.trim().isEmpty) throw ArgumentError('Backup asset mediaType must not be empty');
  }
}

final class ProfessionalPresetBackup {
  ProfessionalPresetBackup({
    required this.presetId,
    required this.name,
    required Map<String, double> orbSettings,
    required Map<String, String> interpretationTemplates,
  })  : orbSettings = Map.unmodifiable(Map.of(orbSettings)),
        interpretationTemplates = Map.unmodifiable(Map.of(interpretationTemplates)) {
    if (presetId.trim().isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Professional preset id/name must not be empty');
    }
    for (final entry in this.orbSettings.entries) {
      if (entry.key.trim().isEmpty || !entry.value.isFinite || entry.value < 0) {
        throw ArgumentError('Orb setting is invalid: ${entry.key}');
      }
    }
    for (final entry in this.interpretationTemplates.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) {
        throw ArgumentError('Interpretation template is invalid: ${entry.key}');
      }
    }
  }

  final String presetId;
  final String name;
  final Map<String, double> orbSettings;
  final Map<String, String> interpretationTemplates;

  Map<String, Object> toJson() => <String, Object>{
        'presetId': presetId,
        'name': name,
        'orbSettings': orbSettings,
        'interpretationTemplates': interpretationTemplates,
      };

  String toMachineReadableJson() => jsonEncode(toJson());

  factory ProfessionalPresetBackup.fromJson(Map<String, Object?> json) {
    final presetId = json['presetId'];
    final name = json['name'];
    final rawOrbs = json['orbSettings'];
    final rawTemplates = json['interpretationTemplates'];
    if (presetId is! String || name is! String || rawOrbs is! Map || rawTemplates is! Map) {
      throw const FormatException('Professional preset backup is malformed');
    }
    return ProfessionalPresetBackup(
      presetId: presetId,
      name: name,
      orbSettings: rawOrbs.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
      interpretationTemplates: rawTemplates.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  }
}

final class PortableBackupRecord {
  const PortableBackupRecord({
    required this.recordId,
    required this.clientId,
    this.logoAssetReference,
  });

  final String recordId;
  final String clientId;
  final String? logoAssetReference;
}

final class PortableBackupPackagePolicy {
  const PortableBackupPackagePolicy();

  static const String formatId = 'ruh-code-portable-backup-v1';
  static const String assetsDirectory = 'assets/';
  static const String recordsDirectory = 'records/';

  void validateCsvAssetReference(String? value) {
    if (value == null || value.isEmpty) return;
    final normalized = value.trim().toLowerCase();
    if (normalized.startsWith('data:') || normalized.startsWith('base64:')) {
      throw const FormatException('Binary logo data must not be embedded in CSV');
    }
    if (!value.startsWith('asset:')) {
      throw const FormatException('CSV binary references must use asset:<id>');
    }
  }

  List<BackupReferenceIssue> validateRestoreReferences({
    required Iterable<PortableBackupRecord> records,
    required Set<String> availableClientIds,
    required Set<String> availableAssetIds,
  }) {
    final issues = <BackupReferenceIssue>[];
    for (final record in records) {
      if (!availableClientIds.contains(record.clientId)) {
        issues.add(
          BackupReferenceIssue(
            code: 'missing_client_id',
            severity: BackupReferenceSeverity.critical,
            recordId: record.recordId,
            message: 'Referenced client ID is missing',
          ),
        );
      }
      final logoRef = record.logoAssetReference;
      if (logoRef != null && logoRef.isNotEmpty) {
        validateCsvAssetReference(logoRef);
        final assetId = logoRef.substring('asset:'.length);
        if (!availableAssetIds.contains(assetId)) {
          issues.add(
            BackupReferenceIssue(
              code: 'missing_optional_logo',
              severity: BackupReferenceSeverity.warning,
              recordId: record.recordId,
              message: 'Optional professional logo is missing; core records remain restorable',
            ),
          );
        }
      }
    }
    return List.unmodifiable(issues);
  }

  bool hasCriticalIssues(Iterable<BackupReferenceIssue> issues) =>
      issues.any((issue) => issue.severity == BackupReferenceSeverity.critical);

  Map<String, Object> portableIndex({
    required Iterable<String> recordFiles,
    required Iterable<BackupAssetRef> assets,
    required Iterable<ProfessionalPresetBackup> presets,
  }) {
    final assetList = assets.toList(growable: false);
    for (final asset in assetList) {
      asset.validate();
    }
    final files = recordFiles.toList(growable: false);
    if (files.any((path) => !path.startsWith(recordsDirectory))) {
      throw ArgumentError('Machine-readable record files must live below records/');
    }
    return UnmodifiableMapView(<String, Object>{
      'format': formatId,
      'records': List.unmodifiable(files),
      'assets': List.unmodifiable(
        assetList
            .map((asset) => <String, String>{
                  'assetId': asset.assetId,
                  'path': asset.relativePath,
                  'mediaType': asset.mediaType,
                })
            .toList(growable: false),
      ),
      'professionalPresets': List.unmodifiable(
        presets.map((preset) => preset.toJson()).toList(growable: false),
      ),
    });
  }
}
