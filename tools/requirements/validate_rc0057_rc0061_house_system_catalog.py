#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]

spec = (ROOT / 'RUH_CODE_MASTER_SARTNAME.md').read_text(encoding='utf-8')
catalog_path = ROOT / 'lib/src/calculation_core/western/house_system_catalog.dart'
test_path = ROOT / 'test/calculation_core/western/house_system_catalog_test.dart'
porphyry_path = ROOT / 'lib/src/calculation_core/western/porphyry_houses.dart'
contract_path = ROOT / 'requirements/contracts/rc0057_rc0061_house_system_catalog_contract.json'

required_spec = {
    'RC-0057': '57. Koch desteklenmesi değerlendirilecek.',
    'RC-0058': '58. Campanus desteklenmesi değerlendirilecek.',
    'RC-0059': '59. Regiomontanus desteklenmesi değerlendirilecek.',
    'RC-0060': '60. Porphyry desteklenmesi değerlendirilecek.',
    'RC-0061': '61. Kullanıcı veya astrolog hangi ev sistemini kullandığını açıkça görebilecek.',
}
for rc_id, text in required_spec.items():
    if text not in spec:
        raise SystemExit(f'{rc_id}: binding specification text missing or changed')

for path in (catalog_path, test_path, porphyry_path, contract_path):
    if not path.is_file():
        raise SystemExit(f'missing required evidence file: {path.relative_to(ROOT)}')

contract = json.loads(contract_path.read_text(encoding='utf-8'))
if contract.get('requirement_ids') != ['RC-0057', 'RC-0058', 'RC-0059', 'RC-0060', 'RC-0061']:
    raise SystemExit('contract requirement_ids mismatch')

catalog = catalog_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')
porphyry = porphyry_path.read_text(encoding='utf-8')

for token in ('placidus', 'wholeSign', 'equal', 'koch', 'campanus', 'regiomontanus', 'porphyry'):
    if token not in catalog:
        raise SystemExit(f'catalog missing house system: {token}')

for token in ('HouseSystemSupport', 'evaluatedNotImplemented', 'supported', 'visibleTitle', 'requireExecutable'):
    if token not in catalog:
        raise SystemExit(f'catalog missing required fail-closed/visibility token: {token}')

# Evaluated systems must not silently become supported without this validator changing.
for system in ('koch', 'campanus', 'regiomontanus'):
    marker = f'WesternHouseSystem.{system}: HouseSystemDescriptor('
    start = catalog.find(marker)
    if start < 0:
        raise SystemExit(f'missing descriptor for {system}')
    block = catalog[start: catalog.find('),', start) + 2]
    if 'HouseSystemSupport.evaluatedNotImplemented' not in block:
        raise SystemExit(f'{system} must remain evaluatedNotImplemented until separately validated')

start = catalog.find('WesternHouseSystem.porphyry: HouseSystemDescriptor(')
block = catalog[start: catalog.find('),', start) + 2]
if start < 0 or 'HouseSystemSupport.supported' not in block:
    raise SystemExit('Porphyry must be marked supported because an executable runtime exists')
if 'abstract final class PorphyryHouses' not in porphyry or 'static PorphyryHouseCusps calculate' not in porphyry:
    raise SystemExit('Porphyry executable runtime missing')

for language in ("'tr'", "'en'"):
    if language not in catalog:
        raise SystemExit(f'active house-system visibility missing language {language}')

for phrase in (
    'catalog covers every declared Western house system exactly once',
    'explicitly evaluated but fail closed',
    'Porphyry is an executable evaluated house system',
    'active system title is explicit in both supported product languages',
):
    if phrase not in test:
        raise SystemExit(f'compiled regression missing: {phrase}')

print('RC-0057..RC-0061 house-system catalog contract: OK')
