#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PROD = ROOT / 'lib/src/calculation_core/vedic/vedic_varga.dart'
TEST = ROOT / 'test/calculation_core/vedic/vedic_varga_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0102_rc0104_varga_d30_d60_extension_contract.json'

required = {
    SPEC: [
        '102. Trimsamsa D30 hesaplanabilecek.',
        '103. Shashtiamsa D60 profesyonel seviyede desteklenebilecek.',
        '104. Gerekli diğer Varga haritaları sistematik şekilde eklenebilecek.',
    ],
    PROD: [
        'trimshamsaD30',
        'shashtiamsaD60',
        'VedicShashtiamsaSignConvention',
        'buildSystematicEqualVarga',
        'VedicEqualVargaDefinition',
        'if(within<5){segment=0;start=0;width=5;target=0;}',
        'else if(within<18){segment=2;start=10;width=8;target=8;}',
        'else if(within<12){segment=1;start=5;width=7;target=5;}',
        "throw StateError('Varga chart requires explicit Vedic provenance.');",
    ],
    TEST: [
        'RC-0102 Trimshamsa D30 uses classical unequal odd-sign spans',
        'RC-0102 Trimshamsa D30 reverses ruler signs for even Rashi',
        'RC-0102 Trimshamsa D30 preserves unequal-segment position',
        'RC-0103 Shashtiamsa D60 advances every half degree from natal Rashi by default',
        'RC-0103 Shashtiamsa D60 exposes sign-independent classical-reading fork',
        'RC-0104 systematic equal Varga definition is validated and deterministic',
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
ids = ['RC-0102', 'RC-0103', 'RC-0104']
if contract.get('requirements') != ids:
    raise SystemExit('contract requirement IDs are not exact')
if set(contract.get('claims', {})) != set(ids):
    raise SystemExit('contract claims are incomplete')

print('RC-0102/RC-0104 Varga D30/D60/extension binding validation: PASS')
