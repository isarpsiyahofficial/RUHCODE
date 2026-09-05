#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = json.loads((ROOT / 'requirements/contracts/rc0063_rc0067_transit_contract.json').read_text(encoding='utf-8'))
spec = (ROOT / 'RUH_CODE_MASTER_SARTNAME.md').read_text(encoding='utf-8')
runtime = (ROOT / contract['runtime']).read_text(encoding='utf-8')
test = (ROOT / contract['compiled_test']).read_text(encoding='utf-8')

for rc, text in contract['requirements'].items():
    number = int(rc.split('-')[1])
    needle = f'{number}. {text}'
    if needle not in spec:
        raise SystemExit(f'{rc}: binding requirement text mismatch')

required_runtime_tokens = [
    'final class WesternTransitChart',
    'static WesternTransitChart build',
    'final class NatalTransitComparison',
    'abstract final class WesternNatalTransit',
    'static NatalTransitComparison compare',
    'All transit ephemeris states must use the same TT instant.',
    'All transit ephemeris states must share source/version provenance.',
    'Natal/transit comparison requires matching ephemeris provenance.',
    'WesternNatalAspects.phaseFor',
]
for token in required_runtime_tokens:
    if token not in runtime:
        raise SystemExit(f'missing transit runtime invariant: {token}')

for forbidden in ('DateTime.now(', 'DateTime.now()', 'http://', 'https://'):
    if forbidden in runtime:
        raise SystemExit(f'transit core must remain deterministic/offline; forbidden token: {forbidden}')

required_test_tokens = [
    'RC-0063', 'RC-0064', 'RC-0065', 'RC-0066', 'RC-0067',
    'throwsStateError', '2400000.5', '2500000.5',
]
for token in required_test_tokens:
    if token not in test:
        raise SystemExit(f'missing compiled transit regression evidence: {token}')

print('RC-0063..RC-0067 transit contract: OK')
