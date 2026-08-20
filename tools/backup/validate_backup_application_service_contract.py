#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = json.loads((ROOT / 'evidence/backup/application_service_contract.json').read_text())
source = (ROOT / 'lib/src/backup/backup_application_service.dart').read_text()
test = (ROOT / 'test/backup/backup_application_service_test.dart').read_text()

assert manifest['contract'] == 'backup-application-service'
assert manifest['status'] == 'SOURCE_LEVEL_IMPLEMENTED'
assert manifest['done'] is False
assert manifest['properties']['userCancelIsNotError'] is True
assert manifest['properties']['previewBeforeMutation'] is True
assert manifest['properties']['networkRequired'] is False
assert manifest['properties']['portableFormat'] == '.ruhcode.zip'

for token in [
    'exportAndSave(',
    'exportAndShare(',
    'pickAndPreviewRestore()',
    'applyRestore(',
    'zipCodec.decode(',
    'packageReader.preview(',
    'importCoordinator.apply(',
    'BackupUserOperationStatus.cancelled',
]:
    assert token in source, token

for token in [
    'save cancellation is a normal result',
    'picker cancellation does not attempt import',
    'picked portable backup is strictly previewed before mutation',
    'dismissed share is reported as user cancellation',
    "reason: 'preview must not mutate storage'",
]:
    assert token in test, token

print('backup application service contract: OK')
