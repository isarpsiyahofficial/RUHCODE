#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT=ROOT/'requirements/contracts/rc0324_rc0341_reference_qa_contract.json'
PROD=ROOT/'lib/src/calculation/reference_qa.dart'
TEST=ROOT/'test/calculation/reference_qa_rc0324_rc0341_test.dart'
for p in (SPEC,CONTRACT,PROD,TEST):
    if not p.exists(): raise SystemExit(f'RC0324_RC0341_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(324,342):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec):
        raise SystemExit(f'RC0324_RC0341_FAIL: missing binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0324..RC-0341':
    raise SystemExit('RC0324_RC0341_FAIL: range')
prod=PROD.read_text(encoding='utf-8')
test=TEST.read_text(encoding='utf-8')
for token in [
    'enum ReferenceEngine',
    'enum ReferenceSourceKind',
    'enum BoundaryTag',
    'final class ReferenceCase',
    'final class ReferenceSuite',
    'final class ReferenceQaCatalog',
    'final class ReferenceReleasePolicy',
    'minimumWesternCases = 1000',
    'minimumVedicCases = 1000',
    'hasMultiSourceEvidence',
    'everyCaseHasIndependentEvidence',
    'BoundaryTag.dstTransition',
    'BoundaryTag.chineseNewYear',
    'BoundaryTag.baziSolarTerm',
    'BoundaryTag.highLatitude',
]:
    if token not in prod:
        raise SystemExit(f'RC0324_RC0341_FAIL: production token {token!r}')
for token in [
    'catalog requires one unambiguous suite per registered engine',
    'single-source evidence can never satisfy release policy',
    'all mandated boundary classes are machine-readable and coverable',
    'cannot fake thousand-case release evidence',
    'planetary-hour global coverage is based on distinct coordinates and timezones',
]:
    if token not in test:
        raise SystemExit(f'RC0324_RC0341_FAIL: test token {token!r}')
blocked=c.get('blocked_until') or []
if not any('>=1000' in item for item in blocked):
    raise SystemExit('RC0324_RC0341_FAIL: thousand-case blocker missing')
if not any('golden' in item.lower() for item in blocked):
    raise SystemExit('RC0324_RC0341_FAIL: golden blocker missing')
print('RC0324_RC0341_OK')
