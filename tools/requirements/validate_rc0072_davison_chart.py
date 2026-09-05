from pathlib import Path
import json
import hashlib

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0072_davison_chart_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/davison_chart.dart'
TEST = ROOT / 'test/calculation_core/western/davison_chart_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

EXPECTED = 'Davison chart ilerleyen aşamada desteklenilecek.'
EXPECTED_SHA = '0cb7cbb51bba796546cf6ee9c2900c0832e53164b174352aa59d8811cef979ee'

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0072 evidence: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirements', {}).get('RC-0072') != EXPECTED:
    raise SystemExit('RC-0072 contract text mismatch')
if hashlib.sha256(EXPECTED.encode('utf-8')).hexdigest() != EXPECTED_SHA:
    raise SystemExit('RC-0072 requirement hash mismatch')
if '72. ' + EXPECTED not in SPEC.read_text(encoding='utf-8'):
    raise SystemExit('RC-0072 binding specification text not found')

runtime = RUNTIME.read_text(encoding='utf-8')
required_runtime_tokens = [
    'WesternDavisonChart',
    'WesternDavisonChartBuilder',
    'GeographicPoint',
    'midpointJdTt',
    '_sphericalMidpoint',
    'ephemeris.stateAt',
    'provenance/instant mismatch',
    'antipodal locations',
]
for token in required_runtime_tokens:
    if token not in runtime:
        raise SystemExit(f'RC-0072 runtime invariant missing: {token}')
if 'DateTime.now' in runtime or 'http://' in runtime or 'https://' in runtime:
    raise SystemExit('RC-0072 runtime must not depend on device current time/network')
if '_circularMidpoint' in runtime:
    raise SystemExit('RC-0072 must not reuse composite longitude midpoint calculation')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'uses real midpoint TT and freshly evaluates ephemeris states',
    'uses spherical geographic midpoint across the date line',
    'fails closed for antipodal geographic midpoint',
    'fails closed for duplicate body requests',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0072 regression coverage missing: {token}')

print('RC-0072 Davison chart contract: PASS')
