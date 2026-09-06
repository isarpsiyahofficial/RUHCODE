from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc0121_vedic_planet_strength_contract.json'
production_path = ROOT / 'lib/src/calculation_core/vedic/vedic_planet_strength.dart'
test_path = ROOT / 'test/calculation_core/vedic/vedic_planet_strength_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
assert contract['requirements'] == ['RC-0121']
for rel in contract['production'] + contract['tests']:
    assert (ROOT / rel).is_file(), f'missing bound evidence: {rel}'

production = production_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
for token in [
    'VedicStrengthMetric',
    'VedicPlanetStrengthProfile',
    'VedicPlanetStrengthSnapshot',
    'shadbala.totalRupa',
    'methodVersion',
    'sourceId',
    'No hidden weighting or synthetic combined score',
]:
    assert token in production, f'missing production invariant token: {token}'
for token in ['without hidden weighting', 'separately sourced strength metric', 'duplicate metric ids']:
    assert token in tests, f'missing regression evidence token: {token}'
print('RC-0121 Vedic planet-strength binding OK')
