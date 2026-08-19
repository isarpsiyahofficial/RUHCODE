#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence' / 'backup' / 'schema_registry_contract.json'
SCHEMA = ROOT / 'lib' / 'src' / 'backup' / 'backup_schema.dart'
VALIDATOR = ROOT / 'lib' / 'src' / 'backup' / 'backup_schema_validator.dart'
TEST = ROOT / 'test' / 'backup' / 'backup_schema_test.dart'

REQUIRED_TABLES = {
    'profiles.csv', 'clients.csv', 'consultations.csv', 'notes.csv',
    'calculations.csv', 'calculation_manifests.csv', 'journal_entries.csv',
    'goals.csv', 'habits.csv', 'tarot_sessions.csv', 'favorites.csv',
    'settings.csv', 'professional_presets.csv', 'interpretation_templates.csv',
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SCHEMA, VALIDATOR, TEST):
        require(path.is_file(), f'missing required file: {path.relative_to(ROOT)}')

    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    require(evidence.get('contractVersion') == 1, 'unexpected contractVersion')
    require(evidence.get('schemaVersion') == 1, 'unexpected schemaVersion')
    require(evidence.get('status') == 'SOURCE_LEVEL_IMPLEMENTED', 'status must remain SOURCE_LEVEL_IMPLEMENTED until proof is complete')
    require(evidence.get('done') is False, 'backup schema must not be marked done before end-to-end proof')

    declared = set(evidence.get('requiredTables', []))
    require(declared == REQUIRED_TABLES, f'requiredTables mismatch: missing={sorted(REQUIRED_TABLES-declared)} extra={sorted(declared-REQUIRED_TABLES)}')

    invariants = evidence.get('invariants', {})
    required_invariants = {
        'fixedColumnOrder', 'uniqueTableNames', 'uniqueColumnsPerTable', 'primaryKeyRequired',
        'localeIndependentEnums', 'isoMachineDates', 'utcMachineDateTimes',
        'localeIndependentDecimals', 'foreignKeysDeclared', 'unknownEnumRejected',
        'duplicatePrimaryKeyRejected', 'unresolvedForeignKeyRejected',
    }
    require(all(invariants.get(key) is True for key in required_invariants), 'one or more mandatory backup invariants are missing')

    schema_text = SCHEMA.read_text(encoding='utf-8')
    for table in REQUIRED_TABLES:
        require(f"fileName: '{table}'" in schema_text, f'{table} missing from BackupSchemaRegistry')
    require('static const int schemaVersion = 1;' in schema_text, 'schema version is not explicit in code')
    require('BackupForeignKey' in schema_text, 'foreign key metadata type missing')
    require('enumValues' in schema_text, 'enum metadata missing')

    validator_text = VALIDATOR.read_text(encoding='utf-8')
    for token in ('Duplicate primary key', 'unresolved foreign key', 'unknown enum id', 'UTC ISO-8601', 'validateForeignKeys'):
        require(token in validator_text, f'validator contract token missing: {token}')

    test_text = TEST.read_text(encoding='utf-8')
    for token in ('locale-formatted decimal', 'unknown enum', 'duplicate primary key', 'foreign keys'):
        require(token in test_text, f'test coverage token missing: {token}')

    print('backup schema contract: OK')


if __name__ == '__main__':
    main()
