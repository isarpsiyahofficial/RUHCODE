#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'; CONTRACT=ROOT/'requirements/contracts/rc0306_rc0323_calculation_manifest_contract.json'; PROD=ROOT/'lib/src/calculation/calculation_manifest.dart'; TEST=ROOT/'test/calculation/calculation_manifest_rc0306_rc0323_test.dart'
for p in (SPEC,CONTRACT,PROD,TEST):
    if not p.exists(): raise SystemExit(f'RC0306_RC0323_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(306,324):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0306_RC0323_FAIL: missing binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0306..RC-0323': raise SystemExit('RC0306_RC0323_FAIL: range')
prod=PROD.read_text(encoding='utf-8'); test=TEST.read_text(encoding='utf-8')
for token in ['final class CalculationManifest','engineVersion','timeZoneDatabaseVersion','reproducibilityRecord','final class CalculationArtifact','final class InterpretationArtifact','Calculation QA must run before Interpretation QA','bool get fullyPassed']:
    if token not in prod: raise SystemExit(f'RC0306_RC0323_FAIL: production token {token!r}')
for token in ['manifest preserves engine/time/location/settings for reproducibility','calculation and interpretation artifacts remain separate','Calculation QA must precede Interpretation QA']:
    if token not in test: raise SystemExit(f'RC0306_RC0323_FAIL: test token {token!r}')
print('RC0306_RC0323_OK')
