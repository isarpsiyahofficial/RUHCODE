from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1237_rc1248_portable_backup_contract.json'
POLICY = ROOT / 'lib/src/backup/backup_portability_policy.dart'
TEST = ROOT / 'test/backup/backup_portability_rc1237_rc1248_test.dart'
DOC = ROOT / 'docs/backup/portable-backup-format-v1.md'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    test = read(TEST)
    doc = read(DOC)
    expected = [f'RC-{i:04d}' for i in range(1237, 1249)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'ProfessionalPresetBackup',
        'orbSettings',
        'interpretationTemplates',
        "normalized.startsWith('data:')",
        "normalized.startsWith('base64:')",
        "'asset:$assetId'",
        "relativePath.startsWith('assets/')",
        "code: 'missing_optional_logo'",
        'BackupReferenceSeverity.warning',
        "code: 'missing_client_id'",
        'BackupReferenceSeverity.critical',
        "formatId = 'ruh-code-portable-backup-v1'",
        "recordsDirectory = 'records/'",
        'toMachineReadableJson',
    ):
        assert token in policy, f'missing RC1237-RC1248 policy token: {token}'

    for token in (
        'professional preset round-trips orb settings and interpretation templates',
        'logo binary is never embedded as base64 in CSV fields',
        'binary assets live in separate package assets directory and CSV references stable asset ID',
        'missing optional logo is warning but missing client ID is critical corruption',
        'portable index is machine-readable and not a proprietary opaque-only backup',
    ):
        assert token in test, f'missing RC1237-RC1248 regression token: {token}'

    for token in (
        'ruh-code-portable-backup-v1',
        'records/',
        'assets/',
        'asset:<asset-id>',
        'missing optional professional logo',
        'missing referenced customer/client ID',
        'opaque proprietary binary',
        'machine-readable',
    ):
        assert token.lower() in doc.lower(), f'missing RC1237-RC1248 documentation token: {token}'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1237_RC1248_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1237_RC1248_OK')
