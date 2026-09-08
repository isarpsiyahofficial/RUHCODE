#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1059_rc1084_interpretation_safety_contract.json'
PROD = ROOT / 'lib/src/interpretation/terminology_and_safety.dart'
TEST = ROOT / 'test/interpretation/terminology_and_safety_rc1059_rc1084_test.dart'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def fail(msg: str) -> None:
    raise SystemExit(f'RC1059_RC1084_FAIL: {msg}')


for path in (CONTRACT, PROD, TEST, MASTER):
    if not path.exists():
        fail(f'missing evidence file: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(1059, 1085)]
if list(contract.get('requirements', {}).keys()) != expected:
    fail('contract must preserve exact RC-1059..RC-1084 order with no omissions')

master = MASTER.read_text(encoding='utf-8')
for n in range(1059, 1085):
    if f'{n}.' not in master:
        fail(f'binding master requirement {n} not found')

prod = PROD.read_text(encoding='utf-8')
for token in (
    'TerminologyGlossary', 'Ascendant', 'Yükselen', 'House', 'Ev',
    'interpretationVersion', 'InterpretationRuleMatcher', 'allowedPlaceholders',
    'InterpretationComposer', 'medicalDiagnosis', 'legalCertainty',
    'financialGuarantee', 'deathPrediction', 'Traditional interpretation'
):
    if token not in prod:
        fail(f'production token missing: {token}')

test = TEST.read_text(encoding='utf-8')
for token in (
    'Sun in Aries rule cannot match Moon in Aries',
    'unfilled placeholder never reaches rendered interpretation',
    'removes repetition',
    'medical legal financial and death certainty categories fail closed',
):
    if token not in test:
        fail(f'regression evidence missing: {token}')

print('RC1059_RC1084_OK')
