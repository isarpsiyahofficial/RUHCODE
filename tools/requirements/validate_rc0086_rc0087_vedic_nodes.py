#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = ROOT / 'requirements/contracts/rc0086_rc0087_vedic_nodes_contract.json'
production = ROOT / 'lib/src/calculation_core/vedic/vedic_nodes.dart'
test = ROOT / 'test/calculation_core/vedic/vedic_nodes_test.dart'
master = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

for path in (contract, production, test, master):
    if not path.is_file():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

data = json.loads(contract.read_text(encoding='utf-8'))
if data.get('requirements') != ['RC-0086', 'RC-0087']:
    raise SystemExit('contract requirement ids are not exact')

master_text = master.read_text(encoding='utf-8')
for phrase in ('86. Rahu hesaplanacak.', '87. Ketu hesaplanacak.'):
    if phrase not in master_text:
        raise SystemExit(f'binding requirement missing: {phrase}')

source = production.read_text(encoding='utf-8')
for token in (
    'enum VedicNodeMode',
    'mean(AstroBody.meanNode)',
    'trueNode(AstroBody.trueNode)',
    'final class VedicRahuKetu',
    'static VedicRahuKetu fromSnapshot(',
    'node.siderealLongitudeDegrees + 180.0',
    'matches.length != 1',
):
    if token not in source:
        raise SystemExit(f'Vedic node production token missing: {token}')
if '/western/' in source or "../western" in source:
    raise SystemExit('Rahu/Ketu calculation must not import Western calculation code')

compiled = test.read_text(encoding='utf-8')
for token in (
    'RC-0086',
    'RC-0087',
    'VedicNodeMode.trueNode',
    'VedicNodeMode.mean',
    'throwsStateError',
):
    if token not in compiled:
        raise SystemExit(f'compiled Rahu/Ketu regression evidence missing: {token}')

print('RC-0086/RC-0087 Vedic Rahu/Ketu contract: OK')
