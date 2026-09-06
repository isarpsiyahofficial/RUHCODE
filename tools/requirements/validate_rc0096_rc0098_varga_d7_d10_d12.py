#!/usr/bin/env python3
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'; PROD=ROOT/'lib/src/calculation_core/vedic/vedic_varga.dart'; TEST=ROOT/'test/calculation_core/vedic/vedic_varga_test.dart'; CONTRACT=ROOT/'requirements/contracts/rc0096_rc0098_varga_d7_d10_d12_contract.json'
required={SPEC:['96. Saptamsa D7 hesaplanacak.','97. Dasamsa D10 hesaplanacak.','98. Dwadasamsa D12 hesaplanacak.'],PROD:['saptamsaD7','dasamsaD10','dwadasamsaD12','final start=r.isEven?r:(r+6)%12','final start=r.isEven?r:(r+8)%12','_dwadasamsaRashi'],TEST:['RC-0096 Saptamsa D7 odd starts same even starts seventh','RC-0097 Dasamsa D10 odd starts same even starts ninth','RC-0098 Dwadasamsa D12 starts from natal sign and advances']}
for path,needles in required.items():
    if not path.exists(): raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')
    text=path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text: raise SystemExit(f'missing binding evidence in {path.relative_to(ROOT)}: {needle}')
contract=json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirements')!=['RC-0096','RC-0097','RC-0098']: raise SystemExit('contract requirement IDs are not exact')
if set(contract.get('claims',{}))!={'RC-0096','RC-0097','RC-0098'}: raise SystemExit('contract claims are incomplete')
print('RC-0096/RC-0098 Varga D7/D10/D12 binding validation: PASS')
