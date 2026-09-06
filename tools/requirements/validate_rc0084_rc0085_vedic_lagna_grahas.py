#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0084_rc0085_vedic_lagna_graha_contract.json'
lagna = ROOT / 'lib/src/calculation_core/vedic/vedic_lagna.dart'
grahas = ROOT / 'lib/src/calculation_core/vedic/vedic_grahas.dart'
lagna_test = ROOT / 'test/calculation_core/vedic/vedic_lagna_test.dart'
graha_test = ROOT / 'test/calculation_core/vedic/vedic_grahas_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, lagna, grahas, lagna_test, graha_test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0084', 'RC-0085']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
for phrase in ('84. Vedik Lagna hesaplanacak.', '85. Graha konumları hesaplanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

lagna_text = lagna.read_text(encoding='utf-8')
for token in (
    'class VedicLagnaResult',
    'abstract final class VedicLagna',
    'SiderealTime.greenwichMeanHours(',
    'ayanamsha.degreesAt(julianDayTt)',
    'siderealLongitudeDegrees:',
):
    if token not in lagna_text:
        raise SystemExit(f'RC-0084 production token missing: {token}')
if '/western/' in lagna_text or "../western" in lagna_text:
    raise SystemExit('Vedic Lagna must not import Western calculation code')

graha_text = grahas.read_text(encoding='utf-8')
for token in (
    'canonicalClassicalGrahas',
    'AstroBody.sun',
    'AstroBody.moon',
    'AstroBody.saturn',
    'VedicGrahaSet.fromSnapshot',
):
    if token not in graha_text:
        raise SystemExit(f'RC-0085 production token missing: {token}')
if 'AstroBody.trueNode' in graha_text or 'AstroBody.meanNode' in graha_text:
    raise SystemExit('RC-0085 must not silently absorb Rahu/Ketu requirements')

for path, rc in ((lagna_test, 'RC-0084'), (graha_test, 'RC-0085')):
    text = path.read_text(encoding='utf-8')
    if rc not in text or 'throws' not in text:
        raise SystemExit(f'compiled regression evidence incomplete for {rc}')

print('RC-0084/RC-0085 Vedic Lagna/Graha contract: OK')
