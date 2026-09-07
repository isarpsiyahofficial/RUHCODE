from pathlib import Path
import csv
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0154_rc0157_bazi_professional_cycles_contract.json'
PROD = ROOT / 'lib/src/calculation_core/bazi/bazi_professional_cycles.dart'
TEST = ROOT / 'test/calculation_core/bazi_professional_cycles_test.dart'
MATRIX = ROOT / 'requirements/requirement_state.csv'


def fail(message: str) -> None:
    raise SystemExit(f'RC0154_RC0157_FAIL: {message}')

for path in (SPEC, CONTRACT, PROD, TEST, MATRIX):
    if not path.exists():
        fail(f'missing {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
for number in range(154, 158):
    if not re.search(rf'(?m)^{number}\.\s+', spec):
        fail(f'binding specification missing numbered entry {number}.')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(154, 158)]
if contract.get('requirements') != expected:
    fail('contract requirement list mismatch')

prod = PROD.read_text(encoding='utf-8')
required_tokens = [
    'BaziElementBalanceEngine',
    'StructuralOccurrenceBalanceMethod',
    'DaYunConventionProvider',
    'DaYunEngine',
    'BaziPeriodPillarProvider',
    'BaziPeriodInfluenceEngine',
    'BaziPeriodKind.annual',
    'BaziPeriodKind.monthly',
    "throw ArgumentError.value(value, 'instantUtc', 'must be UTC')",
]
for token in required_tokens:
    if token not in prod:
        fail(f'production binding missing token: {token}')

if 'seasonal qi' not in prod or 'direction and start age' not in prod:
    fail('convention-sensitive limitations must remain explicit in production comments')

test = TEST.read_text(encoding='utf-8')
for rc in expected:
    if rc not in test:
        fail(f'regression does not name {rc}')

with MATRIX.open(encoding='utf-8', newline='') as f:
    rows = list(csv.DictReader(f))
ids = {row['rc_id'] for row in rows}
missing = set(expected) - ids
if missing:
    fail(f'missing matrix rows: {sorted(missing)}')

print('RC0154_RC0157_OK')
