from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc0120_shadbala_contract.json'
production_path = ROOT / 'lib/src/calculation_core/vedic/vedic_shadbala.dart'
test_path = ROOT / 'test/calculation_core/vedic/vedic_shadbala_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
assert contract['requirements'] == ['RC-0120']
for rel in contract['production'] + contract['tests']:
    assert (ROOT / rel).is_file(), f'missing bound evidence: {rel}'

production = production_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
for token in [
    'ShadbalaComponent.sthana',
    'ShadbalaComponent.dig',
    'ShadbalaComponent.kala',
    'ShadbalaComponent.cheshta',
    'ShadbalaComponent.naisargika',
    'ShadbalaComponent.drik',
    'methodVersion',
    'sourceId',
    'exactly the six canonical component groups',
    'totalRupa',
]:
    assert token in production, f'missing production invariant token: {token}'
for token in ['six canonical Shadbala groups', 'incomplete component sets', 'duplicate components']:
    assert token in tests, f'missing regression evidence token: {token}'
print('RC-0120 Shadbala binding OK')
