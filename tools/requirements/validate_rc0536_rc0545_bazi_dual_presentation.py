from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0536_rc0545_bazi_dual_presentation_contract.json'
PROD = ROOT / 'lib/src/professional/bazi_workspace.dart'
TEST = ROOT / 'test/professional/bazi_workspace_rc0536_rc0545_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(536, 546):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in (
    'BaziProfessionalWorkspace', 'LuckPillarPeriod', 'AnnualPillarRef',
    'BaziRelation', 'luckTimeline(', 'relationsForAnnualYear(',
    'BaziPresentationLevel.simple', 'BaziPresentationLevel.professional',
    'WesternDualPresentation', 'degree', 'aspects', 'orbs', 'dispositor',
):
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for rc in ('RC-0536', 'RC-0540', 'RC-0541', 'RC-0545'):
    if rc not in test:
        raise SystemExit(f'test binding missing: {rc}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until authoritative/reference/UI/release evidence exists')

print('RC-0536..RC-0545 BaZi dual-presentation contract OK')
