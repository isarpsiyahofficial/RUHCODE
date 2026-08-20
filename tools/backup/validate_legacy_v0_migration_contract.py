#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/legacy_v0_migration_contract.json'
SOURCE = ROOT / 'lib/src/backup/legacy_backup_v0_migrator.dart'
TEST = ROOT / 'test/backup/legacy_backup_v0_migrator_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST):
        if not path.exists():
            fail(f'Legacy backup migration contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-LEGACY-V0-MIGRATION-V1':
        fail('Unexpected legacy backup migration contract id.')
    if data.get('done') is not False:
        fail('Legacy migration must remain done=false until runtime/final proof is visible.')

    rules = data.get('migration_rules', {})
    for key in [
        'unknown_time_never_defaults_to_midnight',
        'tables_absent_in_v0_become_empty_current_tables',
        'unknown_legacy_members_rejected',
        'unknown_legacy_headers_rejected',
        'migration_emits_current_schema_package',
        'strict_current_preview_after_migration',
        'production_import_after_migration',
    ]:
        if rules.get(key) is not True:
            fail(f'Legacy migration evidence is missing rule: {key}')

    source = SOURCE.read_text(encoding='utf-8')
    for token in [
        'LegacyBackupV0Migrator',
        'legacyProfileHeader',
        'legacySettingsHeader',
        "'birth_time_knowledge'",
        "? 'unknown' : 'exact'",
        'BackupSchemaRegistry.tables',
        'writer.write',
        'unexpected',
    ]:
        if token not in source:
            fail(f'Legacy migration source is missing required token: {token}')

    test = TEST.read_text(encoding='utf-8')
    for token in [
        'missing birth time becomes unknown, never midnight',
        "expect(row[3], 'unknown')",
        "expect(row[4], isNot('00:00:00'))",
        'BackupPackageReader().preview',
        'LocalDatabaseBackupImportStore',
        'CoreRepositories',
        'throwsFormatException',
    ]:
        if token not in test:
            fail(f'Legacy migration test is missing required token: {token}')

    print('Legacy v0 backup migration structural contract OK.')


if __name__ == '__main__':
    main()
