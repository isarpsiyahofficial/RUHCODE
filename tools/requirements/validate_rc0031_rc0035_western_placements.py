from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0031_rc0035_western_placements_contract.json'
PLACEMENTS = ROOT / 'lib/src/calculation_core/western/natal_placements.dart'
HOUSES = ROOT / 'lib/src/calculation_core/western/placidus_houses.dart'
TEST_PLACEMENTS = ROOT / 'test/calculation_core/western/natal_placements_test.dart'
TEST_HOUSES = ROOT / 'test/calculation_core/western/placidus_houses_test.dart'

expected = {
    'RC-0031': '31. Kullanıcının bütün gezegen yerleşimleri gösterilecek.',
    'RC-0032': '32. Gezegenlerin hangi burçta olduğu gösterilecek.',
    'RC-0033': '33. Gezegen dereceleri gösterilecek.',
    'RC-0034': '34. Gezegenlerin hangi evlerde bulunduğu gösterilecek.',
    'RC-0035': '35. 12 ev ayrı ayrı hesaplanacak.',
}

for p in (SPEC, CONTRACT, PLACEMENTS, HOUSES, TEST_PLACEMENTS, TEST_HOUSES):
    if not p.is_file():
        raise SystemExit(f'missing required evidence: {p.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
for rc, line in expected.items():
    if line not in spec:
        raise SystemExit(f'{rc} binding text drifted or missing')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('promotion_ceiling') != 'TESTED':
    raise SystemExit('promotion ceiling must remain TESTED')
for rc, line in expected.items():
    if contract['requirements'].get(rc) != line.split('. ', 1)[1]:
        raise SystemExit(f'{rc} contract text does not match binding specification')

placements = PLACEMENTS.read_text(encoding='utf-8')
for token in (
    'final AstroBody body;',
    'final double longitudeDegrees;',
    'final TropicalZodiacSign sign;',
    'final double degreeInSign;',
    'final int houseNumber;',
    'houses.houseForLongitude(state.longitudeDegrees)',
    'placements.sort((a, b) => a.body.index.compareTo(b.body.index))',
):
    if token not in placements:
        raise SystemExit(f'natal placement runtime evidence missing: {token}')

houses = HOUSES.read_text(encoding='utf-8')
for token in ('HouseCusps', 'List<double>', '12'):
    if token not in houses:
        raise SystemExit(f'12-house runtime evidence missing: {token}')

print('RC-0031..RC-0035 exact Western placement/house binding validated')
