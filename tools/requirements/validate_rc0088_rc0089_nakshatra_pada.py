#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0088_rc0089_nakshatra_pada_contract.json'
production = ROOT / 'lib/src/calculation_core/vedic/vedic_nakshatra.dart'
test = ROOT / 'test/calculation_core/vedic/vedic_nakshatra_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, production, test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0088', 'RC-0089']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
for phrase in ('88. Nakshatra hesaplanacak.', '89. Pada hesaplanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    'canonicalNakshatraIds',
    'static const int nakshatraCount = 27',
    'static const int padaCountPerNakshatra = 4',
    'AstroBody.moon',
    'nakshatraSpanDegrees = 360.0 / nakshatraCount',
    'padaSpanDegrees',
    'moons.length != 1',
):
    if token not in source:
        raise SystemExit(f'Nakshatra/Pada production token missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('Nakshatra/Pada calculation must not import Western calculation code')

compiled = test.read_text(encoding='utf-8')
for token in ('RC-0088', 'RC-0089', '359.999999', 'throwsStateError'):
    if token not in compiled:
        raise SystemExit(f'compiled Nakshatra/Pada evidence missing: {token}')

print('RC-0088/RC-0089 Vedic Nakshatra/Pada contract: OK')
