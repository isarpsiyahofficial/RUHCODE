from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc0122_vedic_compatibility_contract.json'
production_path = ROOT / 'lib/src/calculation_core/vedic/vedic_compatibility.dart'
test_path = ROOT / 'test/calculation_core/vedic/vedic_compatibility_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
assert contract['requirements'] == ['RC-0122']
for rel in contract['production'] + contract['tests']:
    assert (ROOT / rel).is_file(), f'missing bound evidence: {rel}'

production = production_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
for token in [
    'VedicCompatibilityRule',
    'VedicCompatibilityEngine',
    'allowedRelativeRashiDistances',
    'ruleSourceId',
    'totalPoints',
    'Duplicate Vedic compatibility rule id',
    'No disputed Kuta/compatibility table',
]:
    assert token in production, f'missing production invariant token: {token}'
for token in ['versioned compatibility rules separately', 'does not award points', 'duplicate rule ids']:
    assert token in tests, f'missing regression evidence token: {token}'
assert 'western' not in production.lower()
print('RC-0122 Vedic compatibility binding OK')
