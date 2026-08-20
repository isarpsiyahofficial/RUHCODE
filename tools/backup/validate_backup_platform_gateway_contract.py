#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = json.loads((ROOT / 'evidence/backup/platform_gateway_contract.json').read_text())
source = (ROOT / 'lib/src/backup/backup_platform_gateway.dart').read_text()
pubspec = (ROOT / 'pubspec.yaml').read_text()
test = (ROOT / 'test/backup/backup_platform_gateway_test.dart').read_text()

assert manifest['contract'] == 'backup-platform-gateway'
assert manifest['status'] == 'SOURCE_LEVEL_IMPLEMENTED'
assert manifest['done'] is False
assert manifest['properties']['networkRequired'] is False
assert manifest['properties']['portableSuffix'] == '.ruhcode.zip'
assert manifest['properties']['mimeType'] == 'application/zip'
assert manifest['properties']['coreSerializationSeparatedFromPlatform'] is True

for token in [
    'FilePicker.saveFile(',
    'FilePicker.pickFile(',
    'SharePlus.instance.share(',
    'XFile.fromData(',
    'fileNameOverrides:',
    'BackupPlatformPolicy',
    'allowedExtensions: const [\'zip\']',
]:
    assert token in source, token

for dependency in ['file_picker: ^12.0.0', 'share_plus: ^13.3.0']:
    assert dependency in pubspec, dependency

for token in [
    'rejects wrong extension and path injection',
    'rejects empty and oversized payloads',
    'BACKUP.RUHCODE.ZIP',
]:
    assert token in test, token

print('backup platform gateway contract: OK')