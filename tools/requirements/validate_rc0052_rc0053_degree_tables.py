#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / 'requirements/requirement_state.csv'
CONTRACT = ROOT / 'requirements/contracts/rc0052_rc0053_degree_tables_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/degree_tables.dart'
TEST = ROOT / 'test/calculation_core/western/degree_tables_test.dart'

rows = {r['rc_id']: r for r in csv.DictReader(MATRIX.open(encoding='utf-8', newline=''))}
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {
    'RC-0052': '56623fcd87dd35668d4defc2a67f3dae28e35531580f548a269a61e3beee36b4',
    'RC-0053': 'a0bd8ee9de0dd67778e814eed1ce2d14c6e249f096c13a4ab295120d51d1ef7b',
}
if contract.get('promotionCeiling') != 'TESTED':
    raise SystemExit('promotion ceiling must remain TESTED')
for rc, sha in expected.items():
    if rows[rc]['source_text_sha256'] != sha:
        raise SystemExit(f'{rc} binding SHA drift')
    if contract['requirements'][rc]['bindingRequirementSha256'] != sha:
        raise SystemExit(f'{rc} contract SHA mismatch')

runtime = RUNTIME.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
for token in ('PlanetDegreeRow', 'longitudeDegrees', 'degreeInSign', 'houseNumber', 'WesternDegreeTables.planets'):
    if token not in runtime and token not in test:
        raise SystemExit(f'RC-0052 evidence missing: {token}')
for token in ('HouseDegreeRow', 'List<HouseDegreeRow>.generate(12', 'houses.cusp(houseNumber)', 'WesternDegreeTables.houses'):
    if token not in runtime and token not in test:
        raise SystemExit(f'RC-0053 evidence missing: {token}')
for token in ('hasLength(2)', 'hasLength(12)', 'houseNumber, 12'):
    if token not in test:
        raise SystemExit(f'compiled degree-table regression missing: {token}')
print('RC-0052/RC-0053 degree-table contract: PASS')
