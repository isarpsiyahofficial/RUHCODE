#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/full_lifecycle_contract.json'
LIFECYCLE_TEST = ROOT / 'test/backup/backup_full_lifecycle_test.dart'
SYMMETRY_TEST = ROOT / 'test/backup/backup_all_tables_symmetry_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, LIFECYCLE_TEST, SYMMETRY_TEST):
        if not path.exists():
            fail(f'Full lifecycle contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-FULL-LIFECYCLE-V1':
        fail('Unexpected full backup lifecycle contract id.')
    if data.get('done') is not False:
        fail('Full backup lifecycle must remain done=false until exact runtime/final proof passes.')

    expected_tests = {
        'test/backup/backup_full_lifecycle_test.dart',
        'test/backup/backup_all_tables_symmetry_test.dart',
    }
    if not expected_tests.issubset(set(data.get('tests', []))):
        fail('Full backup lifecycle evidence does not list every required lifecycle test.')

    invariants = data.get('invariants', {})
    for key in [
        'real_sqlite_source_and_target',
        'all_registered_backup_tables_compared',
        'all_14_tables_non_empty_representative_fixture',
        'cross_table_foreign_keys_in_fixture',
        'portable_zip_round_trip',
        'strict_preview_before_mutation',
        'production_import_store',
        'storage_equality_after_restore',
        'export_erase_restore_raw_equality',
        'export_erase_restore_domain_object_equality',
        'same_backup_second_import_idempotent',
        'tr_en_manifest_locale_does_not_mutate_machine_storage',
        'large_data_2500_record_replace_restore',
        'unicode_stress_payload',
        'offline_only',
    ]:
        if invariants.get(key) is not True:
            fail(f'Full backup lifecycle evidence is missing invariant: {key}')

    lifecycle = LIFECYCLE_TEST.read_text(encoding='utf-8')
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
        '2500 deterministic records',
        "'değer-$index-İÜşğ'",
        'BackupImportMode.replace',
    ]:
        if token not in lifecycle:
            fail(f'Full backup lifecycle test is missing required token: {token}')

    symmetry = SYMMETRY_TEST.read_text(encoding='utf-8')
    for token in [
        'all 14 logical tables are non-empty',
        '_seedAllTables',
        "table: 'profiles'",
        "table: 'clients'",
        "table: 'consultations'",
        "table: 'notes'",
        "table: 'calculation_manifests'",
        "table: 'calculations'",
        "table: 'journal_entries'",
        "table: 'goals'",
        "table: 'habits'",
        "table: 'tarot_sessions'",
        "table: 'professional_presets'",
        "table: 'interpretation_templates'",
        "table: 'settings'",
        "table: 'favorites'",
        'export -> erase -> restore preserves domain objects',
        'CoreRepositories',
        'CoreModelCodecs',
        'tx.clearTable',
        '_domainSnapshot',
    ]:
        if token not in symmetry:
            fail(f'All-table backup symmetry test is missing required token: {token}')

    print('Full portable SQLite backup lifecycle structural contract OK.')


if __name__ == '__main__':
    main()
