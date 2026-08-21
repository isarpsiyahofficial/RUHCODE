#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence' / 'backup' / 'schema_registry_contract.json'
SCHEMA = ROOT / 'lib' / 'src' / 'backup' / 'backup_schema.dart'
PACKAGE = ROOT / 'lib' / 'src' / 'backup' / 'backup_package_codec.dart'
VALIDATOR = ROOT / 'lib' / 'src' / 'backup' / 'backup_schema_validator.dart'
TEST = ROOT / 'test' / 'backup' / 'backup_schema_test.dart'
PACKAGE_TEST = ROOT / 'test' / 'backup' / 'backup_package_codec_test.dart'

REQUIRED_TABLES = {
    'profiles.csv', 'clients.csv', 'consultations.csv', 'notes.csv',
    'calculations.csv', 'calculation_manifests.csv', 'journal_entries.csv',
    'goals.csv', 'habits.csv', 'tarot_sessions.csv', 'tarot_cards.csv', 'favorites.csv',
    'settings.csv', 'professional_presets.csv', 'interpretation_templates.csv',
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SCHEMA, PACKAGE, VALIDATOR, TEST, PACKAGE_TEST):
        require(path.is_file(), f'missing required file: {path.relative_to(ROOT)}')

    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    require(evidence.get('contractVersion') == 2, 'unexpected contractVersion')
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
        'tarotCardsNormalizedBySession', 'legacySchemaV1WithoutTarotCardsAcceptedAsEmpty',
        'newSchemaV1WriterAlwaysEmitsTarotCards',
    }
    require(all(invariants.get(key) is True for key in required_invariants), 'one or more mandatory backup invariants are missing')

    schema_text = SCHEMA.read_text(encoding='utf-8')
    for table in REQUIRED_TABLES:
        require(f"fileName: '{table}'" in schema_text, f'{table} missing from BackupSchemaRegistry')
    require('static const int schemaVersion = 1;' in schema_text, 'schema version is not explicit in code')
    require("additiveOptionalForLegacyV1 = <String>{'tarot_cards.csv'}" in schema_text, 'legacy additive tarot_cards compatibility declaration missing')
    require("foreignKey: BackupForeignKey(table: 'tarot_sessions.csv', column: 'id')" in schema_text, 'tarot_cards session foreign key missing')
    require("enumValues: {'upright', 'reversed'}" in schema_text, 'tarot card orientation enum is not locale independent')
    require('BackupForeignKey' in schema_text, 'foreign key metadata type missing')
    require('enumValues' in schema_text, 'enum metadata missing')

    package_text = PACKAGE.read_text(encoding='utf-8')
    require('missing.difference(BackupSchemaRegistry.additiveOptionalForLegacyV1)' in package_text, 'package reader does not preserve legacy schema-v1 compatibility')
    require("rowsByTable.putIfAbsent(optionalName" in package_text, 'missing legacy tarot_cards table is not materialized as empty')

    validator_text = VALIDATOR.read_text(encoding='utf-8')
    for token in ('Duplicate primary key', 'unresolved foreign key', 'unknown enum id', 'UTC ISO-8601', 'validateForeignKeys'):
        require(token in validator_text, f'validator contract token missing: {token}')

    test_text = TEST.read_text(encoding='utf-8')
    for token in ('locale-formatted decimal', 'unknown enum', 'duplicate primary key', 'foreign keys', 'tarot card row whose session does not exist'):
        require(token in test_text, f'test coverage token missing: {token}')
    package_test_text = PACKAGE_TEST.read_text(encoding='utf-8')
    for token in ('tarot_cards.csv', 'older schema-v1 package that predates tarot_cards.csv'):
        require(token in package_test_text, f'package compatibility test token missing: {token}')

    print('backup schema contract: OK')


if __name__ == '__main__':
    main()
