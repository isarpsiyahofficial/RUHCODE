#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/local_export_contract.json'
SOURCE = ROOT / 'lib/src/backup/local_database_backup_exporter.dart'
TEST = ROOT / 'test/backup/local_database_backup_exporter_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST):
        if not path.exists():
            fail(f'Local export contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-LOCAL-EXPORT-V1':
        fail('Unexpected local export contract id.')
    if data.get('done') is not False:
        fail('Local export contract must remain done=false until runtime/lifecycle proof passes.')

    invariants = data.get('invariants', {})
    for key in [
        'single_transaction_snapshot',
        'all_registered_tables_exported',
        'stable_record_id_order',
        'shared_schema_registry',
        'locale_independent_machine_values',
        'enum_ids_not_translated',
        'canonical_json_key_order',
        'runtime_profile_mapping',
        'record_key_payload_id_consistency',
        'strict_package_preview_acceptance_test',
    ]:
        if invariants.get(key) is not True:
            fail(f'Local export evidence is missing invariant: {key}')

    source = SOURCE.read_text(encoding='utf-8')
    for token in [
        'LocalDatabaseBackupExporter',
        'database.transaction',
        'BackupSchemaRegistry.tables',
        "case 'profiles.csv'",
        'jsonEncode(_canonicalJsonValue(value))',
        'Stored record id mismatch',
        'exportPackage',
    ]:
        if token not in source:
            fail(f'Local export source is missing required contract token: {token}')

    test_source = TEST.read_text(encoding='utf-8')
    for scenario in [
        'exports runtime profile payload to canonical CSV schema',
        'stable id order and canonicalizes JSON object keys',
        'package accepted by strict package preview',
        'rejects storage key/payload id mismatch',
    ]:
        if scenario not in test_source:
            fail(f'Local export tests are missing scenario: {scenario}')

    print('LocalDatabase backup export structural contract OK.')


if __name__ == '__main__':
    main()
