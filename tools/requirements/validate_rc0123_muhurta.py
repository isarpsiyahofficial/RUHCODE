from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc0123_muhurta_contract.json'
production_path = ROOT / 'lib/src/calculation_core/vedic/vedic_muhurta.dart'
test_path = ROOT / 'test/calculation_core/vedic/vedic_muhurta_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
assert contract['requirements'] == ['RC-0123']
for rel in contract['production'] + contract['tests']:
    assert (ROOT / rel).is_file(), f'missing bound evidence: {rel}'

production = production_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
for token in [
    'MuhurtaPanchangaField',
    'MuhurtaRule',
    'VedicMuhurtaEngine',
    'ruleSourceId',
    'sunriseSourceId',
    'tithiIndex',
    'nakshatraIndex',
    'yogaIndex',
    'karanaHalfTithiIndex',
    'Duplicate Muhurta rule id',
    'does not embed a universal electional doctrine',
]:
    assert token in production, f'missing production invariant token: {token}'
for token in ['Panchanga-based Muhurta rules independently', 'nonmatching rule visible', 'duplicate Muhurta rule ids']:
    assert token in tests, f'missing regression evidence token: {token}'
print('RC-0123 Muhurta binding OK')
