#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC = 'RC-0036'
EXPECTED_SHA = '973124a37fcc5f233f677f9f9e3423ed38447e67f4d88b4dbaafae829d7e8753'


def require(condition, message):
    if not condition:
        raise SystemExit(f'{RC}: {message}')


contract = json.loads((ROOT / 'requirements/contracts/rc0036_house_cusp_degrees_contract.json').read_text(encoding='utf-8'))
rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
row = next(r for r in rows if r['rc_id'] == RC)
require(contract['rcId'] == RC, 'contract id mismatch')
require(contract['bindingRequirementSha256'] == row['source_text_sha256'] == EXPECTED_SHA, 'binding SHA mismatch')
require(contract['promotionCeiling'] == 'TESTED', 'promotion ceiling weakened')

source = (ROOT / 'lib/src/calculation_core/western/equal_house_systems.dart').read_text(encoding='utf-8')
test = (ROOT / 'test/calculation_core/western/equal_house_systems_test.dart').read_text(encoding='utf-8')
for token in [
    'if (cusps.length != 12)',
    'double cusp(int houseNumber)',
    'RangeError.range(houseNumber, 1, 12',
    'double get ascendantLongitude => cusp(1)',
    'double get midheavenLongitude => cusp(10)',
    'value < 0 || value >= 360',
]:
    require(token in source, f'missing house-cusp runtime token: {token}')
for token in ['houses.cusp(1)', 'houses.cusp(2)', 'houses.cusp(12)', 'closeTo(40, 1e-12)', 'closeTo(10, 1e-12)']:
    require(token in test, f'missing compiled cusp-degree regression token: {token}')
print(f'{RC}: PASS')
