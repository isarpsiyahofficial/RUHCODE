#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/ui/backup/backup_ui_contract.dart'
TEST = ROOT / 'test/ui/backup/backup_ui_contract_test.dart'
EVIDENCE = ROOT / 'evidence/backup/ui_state_contract.json'

required_source_tokens = [
    "enum RuhLocale { tr, en }",
    "saveLabel: 'Tam Yedek Oluştur'",
    "shareLabel: 'Yedeği Paylaş'",
    "chooseLabel: 'Yedek Dosyası Seç'",
    "mergeLabel: 'Mevcut Verilerle Birleştir'",
    "replaceLabel: 'Mevcut Verileri Değiştir'",
    "saveLabel: 'Create Full Backup'",
    "shareLabel: 'Share Backup'",
    "chooseLabel: 'Choose Backup File'",
    'BackupUiPhase.cancelled',
    'BackupUiPhase.invalidBackup',
    'BackupUiPhase.rollbackRestored',
    'BackupUiPhase.rollbackFailed',
    'BackupUiPhase.shareUnavailable',
    'selection.preview.valid',
    'BackupShareStatus.unavailable',
    'Data integrity must be checked',
    'veri bütünlüğü kontrol edilmeli',
]

required_test_tokens = [
    'TR and EN expose the same complete action/state surface',
    'portable backup actions are not mislabeled as single CSV import/export',
    'dismissed share remains cancellation rather than failure',
    'unavailable share has a dedicated recoverable UI state',
    'cancelled picker cannot enable restore actions',
    'failed rollback never claims that existing data is preserved',
    'UI distinguishes restored rollback from failed rollback',
]

errors = []
if not SOURCE.exists():
    errors.append(f'missing {SOURCE.relative_to(ROOT)}')
else:
    text = SOURCE.read_text(encoding='utf-8')
    for token in required_source_tokens:
        if token not in text:
            errors.append(f'backup UI source missing token: {token}')

if not TEST.exists():
    errors.append(f'missing {TEST.relative_to(ROOT)}')
else:
    text = TEST.read_text(encoding='utf-8')
    for token in required_test_tokens:
        if token not in text:
            errors.append(f'backup UI test missing token: {token}')

if not EVIDENCE.exists():
    errors.append(f'missing {EVIDENCE.relative_to(ROOT)}')
else:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if evidence.get('contract') != 'backup-ui-action-state-v1':
        errors.append('unexpected backup UI evidence contract id')
    if evidence.get('done') is not False:
        errors.append('backup UI evidence must remain done=false until approved visual/device/workflow proof exists')
    if evidence.get('portableFormat') != '.ruhcode.zip':
        errors.append('portable backup format must be .ruhcode.zip')
    if set(evidence.get('localeContract', {}).get('supported', [])) != {'tr', 'en'}:
        errors.append('backup UI evidence must cover exactly TR and EN')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Backup UI action/state structural contract OK (source-level, not DONE).')