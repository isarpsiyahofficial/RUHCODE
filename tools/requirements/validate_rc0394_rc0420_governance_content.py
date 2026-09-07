import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0394_rc0420_governance_content_contract.json'
TR = ROOT / 'assets/i18n/system_tr.json'
EN = ROOT / 'assets/i18n/system_en.json'

required_files = [
    ROOT / 'lib/src/application/release_readiness_policy.dart',
    ROOT / 'lib/src/content/interpretation_catalog_policy.dart',
    ROOT / 'test/application/release_readiness_rc0394_rc0405_test.dart',
    ROOT / 'test/content/interpretation_catalog_rc0406_rc0420_test.dart',
    ROOT / '.github/workflows/rc0394-rc0420-governance-content.yml',
    CONTRACT,
    TR,
    EN,
]
for path in required_files:
    if not path.is_file():
        raise SystemExit(f'RC0394_RC0420_FAIL: missing {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
for number in range(394, 421):
    if not re.search(rf'(?m)^{number}\.\s+\S', spec):
        raise SystemExit(f'RC0394_RC0420_FAIL: binding entry {number}. missing')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = list(range(394, 421))
if contract.get('required_numbered_entries') != expected:
    raise SystemExit('RC0394_RC0420_FAIL: contract requirement sequence mismatch')
if contract.get('promotion_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0394_RC0420_FAIL: unsafe promotion ceiling')

tr = json.loads(TR.read_text(encoding='utf-8'))
en = json.loads(EN.read_text(encoding='utf-8'))
if set(tr) != set(en):
    missing_tr = sorted(set(en) - set(tr))
    missing_en = sorted(set(tr) - set(en))
    raise SystemExit(
        f'RC0394_RC0420_FAIL: TR/EN key mismatch missing_tr={missing_tr} missing_en={missing_en}'
    )
for key in sorted(tr):
    if not isinstance(tr[key], str) or not tr[key].strip():
        raise SystemExit(f'RC0394_RC0420_FAIL: empty TR text {key}')
    if not isinstance(en[key], str) or not en[key].strip():
        raise SystemExit(f'RC0394_RC0420_FAIL: empty EN text {key}')

release_source = required_files[0].read_text(encoding='utf-8')
for token in [
    'calculationCoreCi',
    'trEnKeyParity',
    'criticalAstronomyRegression',
    'akilesMigrationRegression',
    'referenceEngineComparison',
    'explainableCalculationDelta',
]:
    if token not in release_source:
        raise SystemExit(f'RC0394_RC0420_FAIL: release policy missing {token}')

content_source = required_files[1].read_text(encoding='utf-8')
for token in [
    'western', 'vedic', 'bazi', 'numerology', 'dailyMessage',
    'conditionId', 'professionalPreparedInterpretationEnabled', 'rawCalculation'
]:
    if token not in content_source:
        raise SystemExit(f'RC0394_RC0420_FAIL: content policy missing {token}')

print('RC0394_RC0420_OK')
