#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/portable_file_store_contract.json'
SOURCE = ROOT / 'lib/src/backup/portable_backup_file_store.dart'
TEST = ROOT / 'test/backup/portable_backup_file_store_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST):
        if not path.exists():
            fail(f'Portable file-store contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-PORTABLE-FILE-STORE-V1':
        fail('Unexpected portable file-store contract id.')
    if data.get('done') is not False:
        fail('Portable file-store contract must remain done=false until device/lifecycle proof passes.')

    invariants = data.get('invariants', {})
    for key in [
        'native_local_file_only',
        'network_independent',
        'explicit_user_selected_path_contract',
        'atomic_same_directory_temp_write',
        'flush_before_rename',
        'temp_cleanup_on_failure',
        'read_size_guard',
        'write_size_guard',
        'logical_package_zip_bridge',
    ]:
        if invariants.get(key) is not True:
            fail(f'Portable file-store evidence is missing invariant: {key}')
    if invariants.get('canonical_extension') != '.ruhcode.zip':
        fail('Portable file-store extension contract must be .ruhcode.zip.')

    source = SOURCE.read_text(encoding='utf-8')
    for token in [
        'PortableBackupFileStore',
        "requiredExtension = '.ruhcode.zip'",
        "File('${target.path}.tmp')",
        'await sink.flush()',
        'await temp.rename(target.path)',
        'maxFileBytes',
        'savePackage',
        'openPackage',
    ]:
        if token not in source:
            fail(f'Portable file-store source is missing required contract token: {token}')

    test_source = TEST.read_text(encoding='utf-8')
    for scenario in [
        'atomically saves and opens portable backup bytes',
        'replaces an existing target without leaving temp bytes',
        'rejects non-canonical extension',
        'rejects missing destination directory',
        'rejects empty and oversized files',
        'savePackage/openPackage preserves logical package members',
    ]:
        if scenario not in test_source:
            fail(f'Portable file-store tests are missing scenario: {scenario}')

    print('Portable backup file-store structural contract OK.')


if __name__ == '__main__':
    main()
