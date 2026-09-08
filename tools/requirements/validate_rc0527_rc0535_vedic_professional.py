from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0527_rc0535_vedic_professional_contract.json'
PROD = ROOT / 'lib/src/professional/vedic_workspace.dart'
TEST = ROOT / 'test/professional/vedic_workspace_rc0527_rc0535_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(527, 536):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

required_prod_tokens = [
    'VedicProfessionalWorkspace', 'VedicPeriod', 'VedicGocharaHit',
    'activeAt(', 'antardashaChanges(', 'combinedTiming(', 'sideBySide(',
    'VargaChart.d1', 'VargaChart.d9', 'VargaChart.d10',
]
for token in required_prod_tokens:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for rc in ('RC-0527', 'RC-0530', 'RC-0531', 'RC-0534'):
    if rc not in test:
        raise SystemExit(f'test binding missing: {rc}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until production/golden/UI release evidence exists')

print('RC-0527..RC-0535 Vedic professional contract OK')
