#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/package_codec_contract.json'
SOURCE = ROOT / 'lib/src/backup/backup_package_codec.dart'
TEST = ROOT / 'test/backup/backup_package_codec_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    if not EVIDENCE.exists() or not SOURCE.exists() or not TEST.exists():
        fail('Backup package contract files are missing.')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract') != 'RUH_CODE_BACKUP_PACKAGE_CODEC_V1':
        fail('Unexpected backup package contract id.')
    if data.get('done') is not False:
        fail('Backup package contract must remain done=false until runtime proof gates pass.')
    if data.get('requiredMembers', {}).get('csvTables') != 14:
        fail('Backup package contract must cover all 14 registered CSV tables.')

    source = SOURCE.read_text(encoding='utf-8')
    required_tokens = [
        "manifest.json",
        'BackupPackageWriter',
        'BackupPackageReader',
        'BackupImportPreview',
        'verifyFile',
        'validateTable',
        'validateForeignKeys',
        'allowMalformed: false',
        'record-count mismatch',
        'unmanifested payload files',
    ]
    missing = [token for token in required_tokens if token not in source]
    if missing:
        fail(f'Backup package source is missing required contract tokens: {missing}')

    test_source = TEST.read_text(encoding='utf-8')
    for phrase in [
        'deterministically',
        'Unicode profile data',
        'tampered CSV',
        'unresolved foreign keys',
    ]:
        if phrase not in test_source:
            fail(f'Backup package tests are missing scenario: {phrase}')

    print('Backup package structural contract OK.')


if __name__ == '__main__':
    main()
