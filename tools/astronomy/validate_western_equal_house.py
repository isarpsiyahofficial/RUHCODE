#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest_path = ROOT / 'docs' / 'astronomy' / 'western_equal_house_runtime.json'
source_path = ROOT / 'lib' / 'src' / 'calculation_core' / 'western' / 'equal_house_systems.dart'
test_path = ROOT / 'test' / 'calculation_core' / 'western' / 'equal_house_systems_test.dart'

for path in (manifest_path, source_path, test_path):
    if not path.is_file():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

m = json.loads(manifest_path.read_text(encoding='utf-8'))
if m.get('contract') != 'western_equal_house_runtime':
    raise SystemExit('unexpected contract id')
if set(m.get('systems', [])) != {'wholeSign', 'equal'}:
    raise SystemExit('wholeSign and equal must both be declared')
if m.get('accuracy', {}).get('externalGoldenRequiredForAscendant') is not True:
    raise SystemExit('ASC external golden dependency must remain explicit')
if m.get('accuracy', {}).get('proven') is not False:
    raise SystemExit('contract must remain unproven until angle golden evidence exists')

source = source_path.read_text(encoding='utf-8')
for token in ('EqualHouseSystems', 'wholeSign', 'equal', 'houseForLongitude', 'Expected longitude in [0, 360)'):
    if token not in source:
        raise SystemExit(f'missing source contract token: {token}')

tests = test_path.read_text(encoding='utf-8')
for token in ('29.999999', '30.0', '359.999999', '350.0', '360.0', 'double.nan'):
    if token not in tests:
        raise SystemExit(f'missing boundary test token: {token}')

print('western equal-house structural contract: OK')
