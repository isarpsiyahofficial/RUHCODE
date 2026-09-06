#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0090_rc0091_rashi_whole_sign_contract.json'
production = ROOT / 'lib/src/calculation_core/vedic/vedic_rashi_chart.dart'
test = ROOT / 'test/calculation_core/vedic/vedic_rashi_chart_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, production, test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0090', 'RC-0091']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
for phrase in ('90. Rashi chart oluşturulacak.', '91. Vedik Whole Sign sistemi uygulanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    'final class VedicRashiChart',
    'final class VedicRashiPlacement',
    'lagna.rashiIndex',
    '((rashiIndex - lagna.rashiIndex + 12) % 12) + 1',
    'Rashi chart ayanamsha provenance mismatch',
    'duplicate Graha placements',
):
    if token not in source:
        raise SystemExit(f'Rashi/Whole Sign production token missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('Rashi/Whole Sign calculation must not import Western calculation code')

compiled = test.read_text(encoding='utf-8')
for token in ('RC-0090', 'RC-0091', 'wraps Whole Sign houses across Aries', 'throwsStateError'):
    if token not in compiled:
        raise SystemExit(f'compiled Rashi/Whole Sign evidence missing: {token}')

print('RC-0090/RC-0091 Vedic Rashi/Whole Sign contract: OK')
