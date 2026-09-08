from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0613_rc0632_quick_calculation_contract.json'
PROD = ROOT / 'lib/src/professional/quick_calculation_workspace.dart'
TEST = ROOT / 'test/professional/quick_calculation_workspace_rc0613_rc0632_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(613, 633):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'QuickCalculationKind.astrology', 'QuickCalculationKind.numerology', 'QuickBirthInput',
    'QuickCalculationSettings', 'QuickCalculationResult', 'QuickCalculationSession',
    'attachVerifiedResult', 'ProfessionalRecentState', 'rememberCity', 'rememberSettings',
    'ProfessionalPreset', 'startTemporary', 'saveAsClientProfile', 'ProductUtilityContract',
    'ProfessionalNeed.normalUser', 'ProfessionalNeed.astrologer', 'ProfessionalNeed.vedicAstrologer',
    'ProfessionalNeed.numerologist', 'ProfessionalNeed.spiritualConsultant', 'ProfessionalNeed.coach',
    'ProfessionalNeed.student', 'ProfessionalNeed.contentCreator'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in ['temporary chart', 'Quick numerology', 'Recent cities and settings', 'Product utility contract', 'Ambiguous quick input']:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until runtime/performance/UI/release evidence exists')

print('RC-0613..RC-0632 quick calculation contract OK')
