from pathlib import Path
import json
import hashlib

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0071_composite_chart_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/composite_chart.dart'
TEST = ROOT / 'test/calculation_core/western/composite_chart_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

EXPECTED = 'Composite chart desteklenilecek.'
EXPECTED_SHA = '32637f90580010771b7e264074f8630fc6140156eae21c1fc5735428f67e7a4a'

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0071 evidence: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirements', {}).get('RC-0071') != EXPECTED:
    raise SystemExit('RC-0071 contract text mismatch')
if hashlib.sha256(EXPECTED.encode('utf-8')).hexdigest() != EXPECTED_SHA:
    raise SystemExit('RC-0071 requirement hash mismatch')
if '71. ' + EXPECTED not in SPEC.read_text(encoding='utf-8'):
    raise SystemExit('RC-0071 binding specification text not found')

runtime = RUNTIME.read_text(encoding='utf-8')
required_runtime_tokens = [
    'WesternCompositeChart',
    'WesternCompositeChartBuilder',
    '_circularMidpoint',
    'personAJdTt',
    'personBJdTt',
    'sourceId',
    'dataVersion',
    'matching ephemeris provenance',
    'identical natal body sets',
]
for token in required_runtime_tokens:
    if token not in runtime:
        raise SystemExit(f'RC-0071 runtime invariant missing: {token}')
if 'DateTime.now' in runtime or 'http://' in runtime or 'https://' in runtime:
    raise SystemExit('RC-0071 runtime must not depend on device current time/network')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'shortest circular midpoint',
    'fails closed for mismatched provenance',
    'fails closed for unequal body sets',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0071 regression coverage missing: {token}')

print('RC-0071 composite chart contract: PASS')
