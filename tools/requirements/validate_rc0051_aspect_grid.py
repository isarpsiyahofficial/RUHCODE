#!/usr/bin/env python3
from __future__ import annotations
import json,re
from pathlib import Path
ROOT=Path('.')

def fail(msg):
    raise SystemExit(msg)

contract=json.loads((ROOT/'requirements/contracts/rc0051_aspect_grid_contract.json').read_text(encoding='utf-8'))
spec=(ROOT/'RUH_CODE_MASTER_SARTNAME.md').read_text(encoding='utf-8')
m=re.search(r'^51\.\s+(.*)$',spec,re.M)
if not m or m.group(1).strip()!=contract['binding_text']:
    fail('RC-0051 binding text drift')
code=(ROOT/contract['runtime']).read_text(encoding='utf-8')
for token in ['final class NatalAspectGrid','AspectGridCell','rows.length != this.bodies.length','cell(AstroBody rowBody, AstroBody columnBody)','Aspect grid inputs must share exact provenance','Aspect grid cannot contain duplicate bodies','Aspect references a body absent from placements','rowBody == columnBody','_pairKey']:
    if token not in code:
        fail(f'RC-0051 runtime contract missing: {token}')
if not (ROOT/contract['compiled_test']).exists():
    fail('RC-0051 compiled test missing')
print('RC-0051 aspect-grid binding validator passed.')
