#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
rows = {r['rc_id']: r for r in csv.DictReader((ROOT/'requirements/requirement_state.csv').open(encoding='utf-8', newline=''))}
contract = json.loads((ROOT/'requirements/contracts/rc0054_rc0056_house_systems_contract.json').read_text(encoding='utf-8'))
expected = {
    'RC-0054':'54d660a13595894efee6af23b32cd3204468d9f847003362099ed037bdc3babc',
    'RC-0055':'d660492ca1c5b20d2658b6ded2a53a3e99a043603f3e33391a11f76ae4e243ef',
    'RC-0056':'d601b538d4c38b2d180c1026d0935d57433ab01830457a6428616a527be47b88',
}
if contract.get('promotionCeiling') != 'TESTED':
    raise SystemExit('promotion ceiling must remain TESTED')
for rc, sha in expected.items():
    if rows[rc]['source_text_sha256'] != sha or contract['requirements'][rc]['bindingRequirementSha256'] != sha:
        raise SystemExit(f'{rc} binding SHA mismatch')

placidus=(ROOT/'lib/src/calculation_core/western/placidus_houses.dart').read_text(encoding='utf-8')
equal=(ROOT/'lib/src/calculation_core/western/equal_house_systems.dart').read_text(encoding='utf-8')
pt=(ROOT/'test/calculation_core/western/placidus_houses_test.dart').read_text(encoding='utf-8')
et=(ROOT/'test/calculation_core/western/equal_house_systems_test.dart').read_text(encoding='utf-8')
for token in ('Placidus', 'HouseCusps'):
    if token.lower() not in placidus.lower():
        raise SystemExit(f'RC-0054 runtime evidence missing: {token}')
for token in ('wholeSign', 'firstCusp = (ascendantLongitude / 30.0).floor() * 30.0'):
    if token not in equal:
        raise SystemExit(f'RC-0055 runtime evidence missing: {token}')
for token in ('EqualHouseSystem.equal', 'firstCusp: ascendantLongitude'):
    if token not in equal:
        raise SystemExit(f'RC-0056 runtime evidence missing: {token}')
if 'test(' not in pt or 'test(' not in et:
    raise SystemExit('compiled house-system regressions missing')
print('RC-0054..RC-0056 house-system contract: PASS')
