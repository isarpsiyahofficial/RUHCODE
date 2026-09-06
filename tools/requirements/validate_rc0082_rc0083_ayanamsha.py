#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0082_rc0083_ayanamsha_contract.json'
production = ROOT / 'lib/src/calculation_core/vedic/ayanamsha_catalog.dart'
test = ROOT / 'test/calculation_core/vedic/ayanamsha_catalog_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, production, test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0082', 'RC-0083']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
required_master = (
    '82. Vedik varsayılan ayanamsha Lahiri/Chitrapaksha olacak.',
    '83. Gerekirse ileride farklı ayanamsha seçenekleri profesyonel ayarlara eklenebilecek.',
)
for phrase in required_master:
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    "static const lahiriChitrapaksha = 'lahiri-chitrapaksha';",
    'String get defaultId => VedicAyanamshaIds.lahiriChitrapaksha;',
    'VedicAyanamshaProvider resolve([String? requestedId])',
    'VedicCalculationEngine.calculate(',
):
    if token not in source:
        raise SystemExit(f'production contract token missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('ayanamsha selection must not depend on Western calculation code')

text = test.read_text(encoding='utf-8')
for token in ('RC-0082', 'RC-0083', 'throwsStateError', 'throwsArgumentError'):
    if token not in text:
        raise SystemExit(f'compiled regression evidence missing: {token}')

print('RC-0082/RC-0083 ayanamsha selection contract: OK')
