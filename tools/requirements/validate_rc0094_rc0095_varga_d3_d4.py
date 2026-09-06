#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PROD = ROOT / 'lib/src/calculation_core/vedic/vedic_varga.dart'
TEST = ROOT / 'test/calculation_core/vedic/vedic_varga_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0094_rc0095_varga_d3_d4_contract.json'

required = {
    SPEC: [
        '94. Drekkana D3 hesaplanacak.',
        '95. Chaturthamsa D4 hesaplanacak.',
    ],
    PROD: [
        'drekkanaD3',
        'chaturthamsaD4',
        'const o=<int>[0,4,8];',
        'const o=<int>[0,3,6,9];',
        "throw StateError('Varga chart requires explicit Vedic provenance.');",
    ],
    TEST: [
        'RC-0094 Drekkana D3 maps thirds to 1st 5th 9th signs',
        'RC-0095 Chaturthamsa D4 maps quarters to 1st 4th 7th 10th signs',
        'RC-0092-RC-0098 fail closed on invalid provenance',
    ],
}

for path, needles in required.items():
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'missing binding evidence in {path.relative_to(ROOT)}: {needle}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirements') != ['RC-0094', 'RC-0095']:
    raise SystemExit('contract requirement IDs are not exact')
if set(contract.get('claims', {})) != {'RC-0094', 'RC-0095'}:
    raise SystemExit('contract claims are incomplete')

print('RC-0094/RC-0095 Varga D3/D4 binding validation: PASS')
