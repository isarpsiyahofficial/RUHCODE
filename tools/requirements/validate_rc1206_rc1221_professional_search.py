from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1206_rc1221_professional_search_contract.json'
POLICY = ROOT / 'lib/src/data/professional_search.dart'
TEST = ROOT / 'test/data/professional_search_rc1206_rc1221_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    test = read(TEST)
    expected = [f'RC-{i:04d}' for i in range(1206, 1222)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'ClientSearchDocument',
        'LocalSearchQuery',
        'normalizedName',
        'normalizedTag',
        'fromUtc',
        'toUtc',
        'numerologyValue',
        'LocalSearchPageSource',
        'requiresServer',
        'ProfessionalSearchCoordinator',
        'maxPageSize',
        'InMemoryIndexedSearchSource',
        '_namePrefixBuckets',
        'hasMore',
    ):
        assert token in policy, f'missing RC1206-RC1221 policy token: {token}'

    for token in (
        'professional search works by client name without server',
        'tag search supports professional labels such as Saturn return',
        'date search filters local indexed records',
        'numerology result can be used as a local filter',
        '1000 client scenario remains paged rather than all-at-once',
        '10000 profile stress scenario uses bounded pagination',
        'search coordinator never accepts a server-required source',
    ):
        assert token in test, f'missing RC1206-RC1221 regression token: {token}'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1206_RC1221_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1206_RC1221_OK')
