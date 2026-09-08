import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1004_rc1039_edge_validity_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CORE = ROOT / 'lib/src/calculation_core/calculation_validity.dart'
GOLDEN = ROOT / 'lib/src/calculation_core/golden/golden_dataset_policy.dart'
TEST = ROOT / 'test/calculation_core/calculation_validity_rc1004_rc1039_test.dart'

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
ids = contract['requirements']
expected = [f'RC-{i:04d}' for i in range(1004, 1040)]
if ids != expected:
    raise SystemExit('RC1004_RC1039_FAIL: contract ID range/order mismatch')

master = MASTER.read_text(encoding='utf-8')
for i in range(1004, 1040):
    if f'{i}.' not in master:
        raise SystemExit(f'RC1004_RC1039_FAIL: master requirement {i} missing')

for path in (CORE, GOLDEN, TEST):
    if not path.exists() or not path.read_text(encoding='utf-8').strip():
        raise SystemExit(f'RC1004_RC1039_FAIL: missing evidence {path}')

core = CORE.read_text(encoding='utf-8')
golden = GOLDEN.read_text(encoding='utf-8')
required_core_tokens = [
    'CalculationValidity', 'valid', 'partial', 'unavailable', 'error',
    'MissingBirthTimePolicy', 'PlanetaryHourAvailabilityPolicy',
    'CalculationDeterminismKey', 'DeterminismGuard',
    'birth_time_required', 'polar',
]
for token in required_core_tokens:
    if token not in core:
        raise SystemExit(f'RC1004_RC1039_FAIL: missing core token {token}')

required_edge_tokens = [
    'signBoundary', 'longitudeNearTwentyNineFiftyNine', 'longitudeNearZero',
    'nakshatraBoundary', 'padaBoundary', 'houseCuspBoundary',
    'retrogradeStation', 'sunriseBoundary', 'sunsetBoundary',
    'dstSpringForward', 'dstFallBack', 'historicalTimezoneChange',
    'halfHourTimezone', 'fortyFiveMinuteTimezone', 'utcPlusFourteen',
    'internationalDateLine', 'polarCircle', 'polarDayOrNight',
]
for token in required_edge_tokens:
    if token not in core or token not in golden:
        raise SystemExit(f'RC1004_RC1039_FAIL: missing edge taxonomy {token}')

for forbidden in ('catch { return 0;', 'catch{return 0;', "return double.nan;"):
    if forbidden in core.lower():
        raise SystemExit(f'RC1004_RC1039_FAIL: silent fallback found: {forbidden}')

print('RC1004_RC1039_OK')
