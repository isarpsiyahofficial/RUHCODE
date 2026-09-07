#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT=Path(__file__).resolve().parents[2]
spec=(ROOT/'RUH_CODE_MASTER_SARTNAME.md').read_text(encoding='utf-8')
prod=(ROOT/'lib/src/application/professional/professional_mode_core.dart').read_text(encoding='utf-8')
test=(ROOT/'test/application/professional/professional_mode_core_test.dart').read_text(encoding='utf-8')
contract=json.loads((ROOT/'requirements/contracts/rc0248_rc0270_professional_mode_contract.json').read_text(encoding='utf-8'))

for n in range(248,271):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        sys.exit(f'RC0248_RC0270_FAIL: binding specification missing numbered entry {n}.')

required_prod=[
 'enum ExperienceMode { simple, professional }','enum ProfessionalRole { astrologer, numerologist }',
 'final class ProfessionalAccessPolicy','final class BirthProfile','final class ProfessionalClient',
 'final class ProfessionalCalculationSettings','final class ProfessionalWorkspace','synastryPair',
 'HouseSystem','NodeMethod','ProfessionalResultTables','professionalToolsVisible'
]
for token in required_prod:
    if token not in prod: sys.exit(f'RC0248_RC0270_FAIL: production evidence missing {token}')

required_tests=['simple mode remains simple','stores multiple profiles notes tags analyses and transit history','synastry requires two distinct stored profiles','invalid calculation settings','already-computed rows']
for token in required_tests:
    if token not in test: sys.exit(f'RC0248_RC0270_FAIL: regression evidence missing {token}')

if contract.get('requirement_range')!='RC-0248..RC-0270': sys.exit('RC0248_RC0270_FAIL: wrong contract range')
if len(contract.get('claims',[]))<8 or len(contract.get('blocked_until',[]))<5: sys.exit('RC0248_RC0270_FAIL: contract evidence/blockers incomplete')
print('RC0248_RC0270_OK')
