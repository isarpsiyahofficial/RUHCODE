#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1040_rc1058_runtime_invariance_contract.json'
PROD = ROOT / 'lib/src/calculation_core/runtime_invariance.dart'
TEST = ROOT / 'test/calculation_core/runtime_invariance_rc1040_rc1058_test.dart'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def fail(msg: str) -> None:
    raise SystemExit(f'RC1040_RC1058_FAIL: {msg}')


for path in (CONTRACT, PROD, TEST, MASTER):
    if not path.exists():
        fail(f'missing evidence file: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(1040, 1059)]
if list(contract.get('requirements', {}).keys()) != expected:
    fail('contract must preserve exact RC-1040..RC-1058 order with no omissions')

master = MASTER.read_text(encoding='utf-8')
for n in range(1040, 1059):
    if f'{n}.' not in master:
        fail(f'binding master requirement {n} not found')

prod = PROD.read_text(encoding='utf-8')
required_prod_tokens = [
    'StoredCalculationContext',
    'CurrentCalculationContext',
    'CanonicalDecimal',
    'RuntimeInvariantCalculationKey',
    'LocalizationCatalogPair',
    'UserDataLocalizationBoundary',
    'timezoneId',
    'utcInstant',
]
for token in required_prod_tokens:
    if token not in prod:
        fail(f'production boundary token missing: {token}')

for forbidden in ('Platform.', 'defaultTargetPlatform', 'DateTime.now()', 'double.parse(text.replaceAll'):
    if forbidden in prod:
        fail(f'ambient/locale-dependent calculation dependency forbidden: {forbidden}')

test = TEST.read_text(encoding='utf-8')
required_test_tokens = [
    "languageCode: 'tr'",
    "languageCode: 'en'",
    "systemTimezoneId: 'America/New_York'",
    "CanonicalDecimal.parse('12,50')",
    'throwsFormatException',
    'throwsStateError',
    'preserveNote',
    'preserveName',
]
for token in required_test_tokens:
    if token not in test:
        fail(f'regression evidence missing: {token}')

print('RC1040_RC1058_OK')
