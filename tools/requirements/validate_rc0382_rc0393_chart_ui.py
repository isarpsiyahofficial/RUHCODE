#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'; CONTRACT=ROOT/'requirements/contracts/rc0382_rc0393_chart_ui_contract.json'; PROD=ROOT/'lib/src/ui/chart/chart_readability_policy.dart'; TEST=ROOT/'test/ui/chart_readability_rc0382_rc0393_test.dart'
for p in (SPEC,CONTRACT,PROD,TEST):
    if not p.exists(): raise SystemExit(f'RC0382_RC0393_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(382,394):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0382_RC0393_FAIL: binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0382..RC-0393': raise SystemExit('RC0382_RC0393_FAIL: range')
prod=PROD.read_text(encoding='utf-8'); test=TEST.read_text(encoding='utf-8')
for token in ['ProductVisualTone.professionalModern','computationScreensPrioritizeReadability = true','minimumPhoneDegreeFontSize = 12.0','minimumPlanetGlyphSize = 18.0','CircularLabelLayout','originalLongitude','maximumAspectLinesPhone','clampZoom','platformNeutralDomainLayer = true']:
    if token not in prod: raise SystemExit(f'RC0382_RC0393_FAIL: production token {token!r}')
for token in ['nearby planet labels are visually separated without changing source longitude','aspect-line density is capped on phones','zoom stays available inside a bounded professional chart range']:
    if token not in test: raise SystemExit(f'RC0382_RC0393_FAIL: test token {token!r}')
blocked=c.get('blocked_until') or []
if not any('production chart renderer' in x for x in blocked): raise SystemExit('RC0382_RC0393_FAIL: renderer blocker missing')
if not any('phones and tablets' in x for x in blocked): raise SystemExit('RC0382_RC0393_FAIL: device blocker missing')
print('RC0382_RC0393_OK')
