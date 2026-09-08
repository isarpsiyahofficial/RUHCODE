from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0674_rc0694_calculation_boundary_contract.json'
PROD = ROOT / 'lib/src/architecture/calculation_interpretation_boundary.dart'
TEST = ROOT / 'test/architecture/calculation_interpretation_boundary_rc0674_rc0694_test.dart'
MODULES = [
    ROOT / 'lib/src/calculation_core/western',
    ROOT / 'lib/src/calculation_core/vedic',
    ROOT / 'lib/src/calculation_core/planetary_hours',
    ROOT / 'lib/src/calculation_core/chinese',
    ROOT / 'lib/src/calculation_core/bazi',
    ROOT / 'lib/src/calculation_core/numerology',
]

for path in (SPEC, CONTRACT, PROD, TEST, *MODULES):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(674, 695):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'VerifiedCalculationFact', 'InterpretationInput', 'requireFact', 'DeterministicDailyMessageTrace',
    'deterministicKey', 'CalculationLayerContract', 'InterpretationPolicy', 'acceptsVerifiedObjectsOnly',
    'acceptsRawUserForm', 'languageVariationCanChangeFacts', 'PresentationConcern.tarot',
    'PresentationConcern.personalGrowth', 'PresentationConcern.monetization', 'PresentationConcern.pdf',
    "'lib/src/calculation_core/western'", "'lib/src/calculation_core/vedic'",
    "'lib/src/calculation_core/planetary_hours'", "'lib/src/calculation_core/chinese'",
    "'lib/src/calculation_core/bazi'", "'lib/src/calculation_core/numerology'"
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in [
    'Daily message trace is deterministic', 'cannot invent a transit Dasha or numerology fact',
    'never raw user form data', 'independent calculation_core module paths',
    'stay outside calculation core', 'Duplicate calculation fact identity fails closed'
]:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until authoritative/golden/release evidence exists')

print('RC-0674..RC-0694 calculation/interpretation boundary contract OK')
