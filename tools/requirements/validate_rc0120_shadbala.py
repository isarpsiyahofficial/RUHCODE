from pathlib import Path
import json
import re

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

# Bind the requirement to the enum declaration itself rather than requiring
# call-site syntax such as `ShadbalaComponent.sthana` inside production code.
match = re.search(r'enum\s+ShadbalaComponent\s*\{([^}]*)\}', production, re.S)
assert match is not None, 'missing ShadbalaComponent enum declaration'
components = {
    token.strip()
    for token in match.group(1).split(',')
    if token.strip()
}
expected_components = {
    'sthana',
    'dig',
    'kala',
    'cheshta',
    'naisargika',
    'drik',
}
assert components == expected_components, (
    f'Shadbala component catalog drift: expected {sorted(expected_components)}, '
    f'got {sorted(components)}'
)

for token in [
    'ShadbalaComponent.values',
    'methodVersion',
    'sourceId',
    'exactly the six canonical component groups',
    'totalRupa',
]:
    assert token in production, f'missing production invariant token: {token}'

# Regression evidence must exercise every canonical component explicitly, in
# addition to incomplete/duplicate fail-closed paths.
for component in sorted(expected_components):
    token = f'ShadbalaComponent.{component}'
    assert token in tests, f'missing regression component evidence: {token}'
for token in [
    'six canonical Shadbala groups',
    'incomplete component sets',
    'duplicate components',
]:
    assert token in tests, f'missing regression evidence token: {token}'

print('RC-0120 Shadbala binding OK')
