#!/usr/bin/env python3
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0271_rc0305_report_entitlement_contract.json'
PROD = ROOT / 'lib/src/application/product/report_entitlement_core.dart'
TEST = ROOT / 'test/application/product/report_entitlement_core_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'RC0271_RC0305_FAIL: missing {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
for number in range(271, 306):
    if not re.search(rf'(?m)^{number}\.\s+\S', spec):
        raise SystemExit(f'RC0271_RC0305_FAIL: binding specification missing numbered requirement {number}.')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirement_range') != 'RC-0271..RC-0305':
    raise SystemExit('RC0271_RC0305_FAIL: incorrect contract requirement range')
if not contract.get('claims') or not contract.get('blocked_until'):
    raise SystemExit('RC0271_RC0305_FAIL: contract claims/blockers must be explicit')

prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
required_prod_tokens = [
    'enum AppTier { free, pro }',
    'enum ReportLocale { tr, en }',
    'final class CalculationResultRef',
    'final class ProfessionalReportSection',
    'final class ProfessionalReportDocument',
    'final class RewardedUnlock',
    'final class ProductEntitlementPolicy',
    'final class ProfessionalReportService',
    'ProductFeature.professionalPdf',
    'ProductFeature.offlineCalculation',
    'preserveCalculationTruth',
]
for token in required_prod_tokens:
    if token not in prod:
        raise SystemExit(f'RC0271_RC0305_FAIL: production evidence missing {token!r}')

# Fail closed against introducing a report-specific recalculation callback/engine.
for forbidden in ('recalculate(', 'reportCalculationEngine', 'calculateForPdf('):
    if forbidden in prod:
        raise SystemExit(f'RC0271_RC0305_FAIL: forbidden report recomputation surface {forbidden!r}')

required_test_tokens = [
    'TR and EN reports bind sections to existing manifests without recalculation',
    'Free exposes real basic value while advanced tools stay PRO',
    'rewarded unlock is temporary',
    'tier never mutates calculation truth',
]
for token in required_test_tokens:
    if token not in test:
        raise SystemExit(f'RC0271_RC0305_FAIL: regression evidence missing {token!r}')

print('RC0271_RC0305_OK')
