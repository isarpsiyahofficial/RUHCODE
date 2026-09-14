#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PROD = ROOT / 'lib/src/calculation_core/vedic/vedic_varga.dart'
TEST = ROOT / 'test/calculation_core/vedic/vedic_varga_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0099_rc0101_varga_d16_d20_d24_contract.json'

required = {
    SPEC: [
        '99. Shodasamsa D16 hesaplanabilecek.',
        '100. Vimshamsa D20 hesaplanabilecek.',
        '101. Chaturvimshamsa D24 hesaplanabilecek.',
    ],
    PROD: [
        'shodasamsaD16',
        'vimshamsaD20',
        'chaturvimshamsaD24',
        'switch(r%3){0=>0,1=>4,_=>8}',
        'switch(r%3){0=>0,1=>8,_=>4}',
        'final start=r.isEven?4:3;',
        "throw StateError('Varga chart requires explicit Vedic provenance.');",
    ],
    TEST: [
        'RC-0099 Shodasamsa D16 uses movable Aries fixed Leo dual Sagittarius starts',
        'RC-0099 Shodasamsa D16 advances every 1.875 degrees',
        'RC-0100 Vimshamsa D20 uses movable Aries fixed Sagittarius dual Leo starts',
        'RC-0100 Vimshamsa D20 advances every 1.5 degrees',
        'RC-0101 Chaturvimshamsa D24 starts Leo for odd signs and Cancer for even signs',
        'RC-0101 Chaturvimshamsa D24 advances every 1.25 degrees',
        'RC-0092-RC-0104 fail closed on invalid provenance',
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
ids = ['RC-0099', 'RC-0100', 'RC-0101']
if contract.get('requirements') != ids:
    raise SystemExit('contract requirement IDs are not exact')
if set(contract.get('claims', {})) != set(ids):
    raise SystemExit('contract claims are incomplete')

print('RC-0099/RC-0101 Varga D16/D20/D24 binding validation: PASS')
