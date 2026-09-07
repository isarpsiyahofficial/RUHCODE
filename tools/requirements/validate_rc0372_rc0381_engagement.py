#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'; CONTRACT=ROOT/'requirements/contracts/rc0372_rc0381_engagement_contract.json'; PROD=ROOT/'lib/src/application/engagement_policy.dart'; TEST=ROOT/'test/application/engagement_policy_rc0372_rc0381_test.dart'
for p in (SPEC,CONTRACT,PROD,TEST):
    if not p.exists(): raise SystemExit(f'RC0372_RC0381_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(372,382):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0372_RC0381_FAIL: binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0372..RC-0381': raise SystemExit('RC0372_RC0381_FAIL: range')
prod=PROD.read_text(encoding='utf-8'); test=TEST.read_text(encoding='utf-8')
for token in ['MonetizationSurface.calculationInput => AdPresentation.prohibited','MonetizationSurface.calculationResult => AdPresentation.prohibited','dailyMessageCard => AdPresentation.userInitiatedRewarded','enum NotificationCategory','dailyMessage','planetaryHour','importantTransit','retrogradeBoundary','moonPhase','permissionGranted','minimumGap']:
    if token not in prod: raise SystemExit(f'RC0372_RC0381_FAIL: production token {token!r}')
for token in ['ads cannot interrupt calculation input or result surfaces','all notification categories default off and require platform permission','spam guard suppresses opted-in notifications']:
    if token not in test: raise SystemExit(f'RC0372_RC0381_FAIL: test token {token!r}')
blocked=c.get('blocked_until') or []
if not any('ad SDK' in x for x in blocked): raise SystemExit('RC0372_RC0381_FAIL: ad audit blocker missing')
if not any('device-tested' in x for x in blocked): raise SystemExit('RC0372_RC0381_FAIL: device blocker missing')
print('RC0372_RC0381_OK')
