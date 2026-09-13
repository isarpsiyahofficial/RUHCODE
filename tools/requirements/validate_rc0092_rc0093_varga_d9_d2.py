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

claims = data.get('claims', {})
if set(claims) != {'RC-0092', 'RC-0093'}:
    raise SystemExit('contract claims must cover RC-0092 and RC-0093 exactly')
for token in ('movable/fixed/dual', 'Sun/Moon order reversal'):
    if not any(token in claim for claim in claims.values()):
        raise SystemExit(f'contract calculation claim missing: {token}')

master_text = master.read_text(encoding='utf-8')
for phrase in ('92. Navamsa D9 hesaplanacak.', '93. Hora D2 hesaplanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    'final class VedicVargaChart',
    'static VedicVargaChart navamsaD9(VedicCalculationSnapshot s)=>_build(snapshot:s,division:9,mapper:_navamsaRashi);',
    'static VedicVargaChart horaD2(VedicCalculationSnapshot s)=>_build(snapshot:s,division:2,mapper:_horaRashi);',
    'static int _navamsaRashi(int r,int p){final start=switch(r%3){0=>r,1=>(r+8)%12,_=>(r+4)%12}; return (start+p)%12;}',
    'static int _horaRashi(int r,int p){final odd=r.isEven; final sun=odd?p==0:p==1; return sun?4:3;}',
    "throw StateError('Varga chart contains duplicate Graha placements.')",
    "throw StateError('Varga chart requires normalized sidereal longitudes.')",
    "throw StateError('Varga chart requires explicit Vedic provenance.')",
):
    if token not in source:
        raise SystemExit(f'Varga production invariant missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('Varga calculation must not import Western calculation code')

compiled = test.read_text(encoding='utf-8')
for token in (
    'RC-0092 Navamsa D9 uses movable/fixed/dual start rules',
    'VedicVargaBuilder.navamsaD9(_snapshot(1)).placements.single.vargaRashiIndex,0',
    'VedicVargaBuilder.navamsaD9(_snapshot(31)).placements.single.vargaRashiIndex,9',
    'VedicVargaBuilder.navamsaD9(_snapshot(61)).placements.single.vargaRashiIndex,6',
    'RC-0093 Hora D2 odd/even order',
    'VedicVargaBuilder.horaD2(_snapshot(5)).placements.single.vargaRashiIndex,4',
    'VedicVargaBuilder.horaD2(_snapshot(20)).placements.single.vargaRashiIndex,3',
    'VedicVargaBuilder.horaD2(_snapshot(35)).placements.single.vargaRashiIndex,3',
    'VedicVargaBuilder.horaD2(_snapshot(50)).placements.single.vargaRashiIndex,4',
    'RC-0092-RC-0104 fail closed on invalid provenance',
    'throwsStateError',
):
    if token not in compiled:
        raise SystemExit(f'compiled Varga evidence missing: {token}')

print('RC-0092/RC-0093 Navamsa/Hora contract: OK')
