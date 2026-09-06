#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0092_rc0093_varga_d9_d2_contract.json'
production = ROOT / 'lib/src/calculation_core/vedic/vedic_varga.dart'
test = ROOT / 'test/calculation_core/vedic/vedic_varga_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, production, test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0092', 'RC-0093']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
for phrase in ('92. Navamsa D9 hesaplanacak.', '93. Hora D2 hesaplanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    'final class VedicVargaChart',
    'navamsaD9',
    'horaD2',
    'fixed signs from the ninth',
    'dual signs from the fifth',
    'Sun Hora is Leo',
    'Moon Hora is Cancer',
    'duplicate Graha placements',
):
    if token not in source:
        raise SystemExit(f'Varga production token missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('Varga calculation must not import Western calculation code')

compiled = test.read_text(encoding='utf-8')
for token in ('RC-0092', 'RC-0093', 'movable/fixed/dual', 'reverses Moon/Sun order', 'throwsStateError'):
    if token not in compiled:
        raise SystemExit(f'compiled Varga evidence missing: {token}')

print('RC-0092/RC-0093 Navamsa/Hora contract: OK')
