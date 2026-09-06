from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc0119_ashtakavarga_contract.json'
production_path = ROOT / 'lib/src/calculation_core/vedic/vedic_ashtakavarga.dart'
test_path = ROOT / 'test/calculation_core/vedic/vedic_ashtakavarga_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
assert contract['requirements'] == ['RC-0119']
for rel in contract['production'] + contract['tests']:
    assert (ROOT / rel).is_file(), f'missing bound evidence: {rel}'

production = production_path.read_text(encoding='utf-8')
tests = test_path.read_text(encoding='utf-8')
required_tokens = [
    'AshtakavargaRuleSet',
    'VedicAshtakavargaEngine',
    'bhinnaBindusBySubject',
    'sarvaBindusByRashi',
    'ruleSetSourceId',
    'favorableRelativeHouses',
    'AshtakavargaContributorKind.lagna',
    'Duplicate Ashtakavarga subject/contributor rule',
]
for token in required_tokens:
    assert token in production, f'missing production invariant token: {token}'
for token in ['fails closed', 'duplicate subject/contributor', 'Sarva totals']:
    assert token in tests, f'missing regression evidence token: {token}'

assert 'Western' not in production
print('RC-0119 Ashtakavarga binding OK')
