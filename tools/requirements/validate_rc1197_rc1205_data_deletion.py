from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1197_rc1205_data_deletion_contract.json'
POLICY = ROOT / 'lib/src/data/data_deletion_policy.dart'
TEST = ROOT / 'test/data/data_deletion_rc1197_rc1205_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    test = read(TEST)
    expected = [f'RC-{i:04d}' for i in range(1197, 1206)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'DeleteAllPlan',
        'eraseAllApplicationData => true',
        'ClientDeletionPreview',
        'planClientDeletion',
        'clientId == clientId',
        '_cascadeDeleteKinds',
        'DeletableRecordKind.note',
        'ClientDeletionMode.archiveReports',
        'archiveIds.add(record.id)',
        'DeletionTombstoneLedger',
        'RestoreDeletedRecordPolicy.keepDeleted',
        'RestoreDeletedRecordPolicy.restoreExplicitly',
        'requiresExplicitConfirmation => true',
    ):
        assert token in policy, f'missing RC1197-RC1205 policy token: {token}'

    for token in (
        'delete all is a single explicit destructive operation',
        'single client delete previews every linked record before mutation',
        'cascade delete rules are explicit and unrelated clients are untouched',
        'profile can be deleted while consultation reports are archived',
        'restore keeps previously deleted records deleted by default',
        'restore may reintroduce deleted records only after explicit user choice',
    ):
        assert token in test, f'missing RC1197-RC1205 regression token: {token}'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1197_RC1205_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1197_RC1205_OK')
