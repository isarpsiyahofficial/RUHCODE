#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/import_transaction_contract.json'
SOURCE = ROOT / 'lib/src/backup/backup_import_coordinator.dart'
TEST = ROOT / 'test/backup/backup_import_coordinator_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST):
        if not path.exists():
            fail(f'Missing backup import contract file: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract') != 'RUH_CODE_BACKUP_IMPORT_TRANSACTION_V1':
        fail('Unexpected backup import contract id.')
    if data.get('done') is not False:
        fail('Backup import contract must remain done=false until production/runtime proof passes.')
    if not data.get('preconditions', {}).get('validPreviewRequired'):
        fail('Backup import must require a valid preview before mutation.')
    if not data.get('merge', {}).get('sameBackupReimportIdempotent'):
        fail('Backup merge must specify idempotent re-import.')
    if not data.get('replace', {}).get('failureRestoresSafetySnapshot'):
        fail('Backup replace must restore a safety snapshot on failure.')

    source = SOURCE.read_text(encoding='utf-8')
    required_tokens = [
        'Invalid backup preview cannot mutate storage',
        'transaction<void>',
        'createSafetySnapshot',
        'restoreSafetySnapshot',
        'upsertTable',
        'replaceTable',
    ]
    missing = [token for token in required_tokens if token not in source]
    if missing:
        fail(f'Backup import source is missing required contract tokens: {missing}')

    tests = TEST.read_text(encoding='utf-8')
    for phrase in [
        'idempotent by primary key',
        'creates safety snapshot',
        'failure restores',
        'invalid preview is rejected',
    ]:
        if phrase not in tests:
            fail(f'Backup import tests are missing scenario: {phrase}')

    print('Backup import transactional contract OK.')


if __name__ == '__main__':
    main()
