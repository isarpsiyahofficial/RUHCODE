#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/full_lifecycle_contract.json'
TEST = ROOT / 'test/backup/backup_full_lifecycle_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, TEST):
        if not path.exists():
            fail(f'Full lifecycle contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-FULL-LIFECYCLE-V1':
        fail('Unexpected full backup lifecycle contract id.')
    if data.get('done') is not False:
        fail('Full backup lifecycle must remain done=false until exact runtime/final proof passes.')

    invariants = data.get('invariants', {})
    for key in [
        'real_sqlite_source_and_target',
        'all_registered_backup_tables_compared',
        'portable_zip_round_trip',
        'strict_preview_before_mutation',
        'production_import_store',
        'storage_equality_after_restore',
        'same_backup_second_import_idempotent',
        'tr_en_manifest_locale_does_not_mutate_machine_storage',
        'offline_only',
    ]:
        if invariants.get(key) is not True:
            fail(f'Full backup lifecycle evidence is missing invariant: {key}')

    source = TEST.read_text(encoding='utf-8')
    for token in [
        'SqfliteLocalDatabase',
        'LocalDatabaseBackupExporter',
        'PortableZipBackupCodec',
        'BackupPackageReader',
        'BackupImportCoordinator',
        'LocalDatabaseBackupImportStore',
        '_snapshotRegisteredTables',
        'BackupSchemaRegistry.tables',
        'same portable backup twice',
        "('tr', trTarget)",
        "('en', enTarget)",
    ]:
        if token not in source:
            fail(f'Full backup lifecycle test is missing required token: {token}')

    print('Full portable SQLite backup lifecycle structural contract OK.')


if __name__ == '__main__':
    main()
