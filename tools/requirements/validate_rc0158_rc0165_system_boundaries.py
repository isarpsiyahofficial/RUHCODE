from pathlib import Path
import csv
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0158_rc0165_system_boundaries_contract.json'
BAZI = ROOT / 'lib/src/calculation_core/bazi/bazi_compatibility.dart'
ZIWEI = ROOT / 'lib/src/calculation_core/ziwei/zi_wei_engine.dart'
NUM = ROOT / 'lib/src/calculation_core/numerology/numerology_system.dart'
TEST = ROOT / 'test/calculation_core/system_boundaries_rc0158_rc0165_test.dart'
MATRIX = ROOT / 'requirements/requirement_state.csv'


def fail(message: str) -> None:
    raise SystemExit(f'RC0158_RC0165_FAIL: {message}')

for path in (SPEC, CONTRACT, BAZI, ZIWEI, NUM, TEST, MATRIX):
    if not path.exists():
        fail(f'missing {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
for number in range(158, 166):
    if not re.search(rf'(?m)^{number}\.\s+', spec):
        fail(f'binding specification missing numbered entry {number}.')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(158, 166)]
if contract.get('requirements') != expected:
    fail('contract requirement list mismatch')

bazi = BAZI.read_text(encoding='utf-8')
for token in ('BaziCompatibilityRule', 'BaziCompatibilityEngine', 'sourceId', 'version'):
    if token not in bazi:
        fail(f'BaZi compatibility binding missing {token}')

ziwei = ZIWEI.read_text(encoding='utf-8')
if 'ZiWeiDouShuEngine' not in ziwei:
    fail('Zi Wei dedicated engine contract missing')
if re.search(r"import\s+['\"].*bazi", ziwei, re.IGNORECASE):
    fail('Zi Wei engine must not import BaZi')
if 'BaZi' in ziwei.replace('BaZi package', '').replace('BaZi types', '').replace('BaZi sub-feature', ''):
    fail('Zi Wei production contract contains an unexpected BaZi coupling')

num = NUM.read_text(encoding='utf-8')
for token in (
    'NumerologySystemId',
    'PythagoreanNumerologySystem',
    'ChaldeanNumerologySystem',
    'LoShuGridSystem',
    'systemDisplayName',
):
    if token not in num:
        fail(f'numerology system boundary missing {token}')

text = TEST.read_text(encoding='utf-8')
for rc in expected:
    if rc not in text:
        fail(f'regression does not name {rc}')

with MATRIX.open(encoding='utf-8', newline='') as f:
    rows = list(csv.DictReader(f))
ids = {row['rc_id'] for row in rows}
missing = set(expected) - ids
if missing:
    fail(f'missing matrix rows: {sorted(missing)}')

print('RC0158_RC0165_OK')
