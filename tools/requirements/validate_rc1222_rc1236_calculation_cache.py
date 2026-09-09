from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1222_rc1236_calculation_cache_contract.json'
POLICY = ROOT / 'lib/src/calculation_core/calculation_cache_policy.dart'
TEST = ROOT / 'test/calculation_core/calculation_cache_rc1222_rc1236_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    test = read(TEST)
    expected = [f'RC-{i:04d}' for i in range(1222, 1237)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'CalculationCacheKey',
        'inputFingerprint',
        'engineVersion',
        'subjectId',
        'String get stableId',
        'CalculationCacheKind.natal',
        'CalculationCacheKind.daily',
        'CalculationCacheKind.planetaryHour',
        'CalculationCacheKind.transit',
        'CalculationCacheKind.solarReturn',
        'record.key.matches(expectedKey)',
        'localDayId',
        'planetaryHourWindowId',
        'calculationTimezoneId',
        'natalLocationId',
        'currentLocationId',
        'solarReturnLocationId',
        'computeFromSource',
        'CalculationManifestOverrides',
    ):
        assert token in policy, f'missing RC1222-RC1236 policy token: {token}'

    for token in (
        'same natal chart is reused instead of recomputed on every screen open',
        'cache identity includes canonical input and engineVersion',
        'engine version change invalidates old cache automatically',
        'wrong-client cache can never be shown',
        'cache is derivative and deletion deterministically rebuilds from source',
        'daily cache expires on local day or timezone change',
        'planetary-hour cache expires when hour window changes',
        'transit current location is separate from natal birthplace',
        'solar return technique location must be explicit',
        'non-default user settings are carried into Calculation Manifest overrides',
    ):
        assert token in test, f'missing RC1222-RC1236 regression token: {token}'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1222_RC1236_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1222_RC1236_OK')
