import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/backup/backup_portability_policy.dart';

void main() {
  group('RC-1237 through RC-1248 portable backup', () {
    test('professional preset round-trips orb settings and interpretation templates', () {
      final preset = ProfessionalPresetBackup(
        presetId: 'preset-pro-1',
        name: 'Professional Default',
        orbSettings: const {
          'conjunction': 8.0,
          'opposition': 7.5,
        },
        interpretationTemplates: const {
          'sun_aries': 'Template A',
          'moon_taurus': 'Template B',
        },
      );

      final decoded = jsonDecode(preset.toMachineReadableJson()) as Map<String, Object?>;
      final restored = ProfessionalPresetBackup.fromJson(decoded);
      expect(restored.presetId, 'preset-pro-1');
      expect(restored.orbSettings['conjunction'], 8.0);
      expect(restored.interpretationTemplates['sun_aries'], 'Template A');
    });

    test('logo binary is never embedded as base64 in CSV fields', () {
      const policy = PortableBackupPackagePolicy();
      expect(() => policy.validateCsvAssetReference('asset:logo-123'), returnsNormally);
      expect(
        () => policy.validateCsvAssetReference('data:image/png;base64,AAAA'),
        throwsFormatException,
      );
      expect(
        () => policy.validateCsvAssetReference('base64:AAAA'),
        throwsFormatException,
      );
    });

    test('binary assets live in separate package assets directory and CSV references stable asset ID', () {
      const policy = PortableBackupPackagePolicy();
      const asset = BackupAssetRef(
        assetId: 'logo-123',
        relativePath: 'assets/logos/logo-123.svg',
        mediaType: 'image/svg+xml',
      );
      asset.validate();
      expect(asset.csvReference, 'asset:logo-123');

      final index = policy.portableIndex(
        recordFiles: const ['records/clients.csv', 'records/profiles.csv'],
        assets: const [asset],
        presets: const [],
      );
      expect(index['format'], PortableBackupPackagePolicy.formatId);
      expect((index['assets'] as List).single, containsPair('path', 'assets/logos/logo-123.svg'));
    });

    test('missing optional logo is warning but missing client ID is critical corruption', () {
      const policy = PortableBackupPackagePolicy();
      final records = [
        const PortableBackupRecord(
          recordId: 'profile-1',
          clientId: 'client-1',
          logoAssetReference: 'asset:missing-logo',
        ),
        const PortableBackupRecord(
          recordId: 'profile-2',
          clientId: 'missing-client',
        ),
      ];
      final issues = policy.validateRestoreReferences(
        records: records,
        availableClientIds: {'client-1'},
        availableAssetIds: const {},
      );

      expect(
        issues.where((issue) => issue.code == 'missing_optional_logo').single.severity,
        BackupReferenceSeverity.warning,
      );
      expect(
        issues.where((issue) => issue.code == 'missing_client_id').single.severity,
        BackupReferenceSeverity.critical,
      );
      expect(policy.hasCriticalIssues(issues), isTrue);
    });

    test('portable index is machine-readable and not a proprietary opaque-only backup', () {
      const policy = PortableBackupPackagePolicy();
      final index = policy.portableIndex(
        recordFiles: const [
          'records/clients.csv',
          'records/profiles.csv',
          'records/presets.json',
        ],
        assets: const [],
        presets: [
          ProfessionalPresetBackup(
            presetId: 'preset-1',
            name: 'My Preset',
            orbSettings: const {'square': 6.0},
            interpretationTemplates: const {'square': 'Tension template'},
          ),
        ],
      );

      final encoded = jsonEncode(index);
      final decoded = jsonDecode(encoded) as Map<String, Object?>;
      expect(decoded['format'], 'ruh-code-portable-backup-v1');
      expect(decoded['records'], isA<List>());
      expect(decoded['professionalPresets'], isA<List>());
    });
  });
}
