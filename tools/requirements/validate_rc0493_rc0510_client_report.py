import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0493_rc0510_client_report_contract.json'
SOURCE = ROOT / 'lib/src/professional/client_report_workspace.dart'
TEST = ROOT / 'test/professional/client_report_workspace_rc0493_rc0510_test.dart'
WORKFLOW = ROOT / '.github/workflows/rc0493-rc0510-client-report.yml'
for path in [SPEC, CONTRACT, SOURCE, TEST, WORKFLOW]:
    if not path.is_file():
        raise SystemExit(f'RC0493_RC0510_FAIL: missing {path.relative_to(ROOT)}')
spec = SPEC.read_text(encoding='utf-8')
for number in range(493, 511):
    if not re.search(rf'(?m)^{number}\.\s+\S', spec):
        raise SystemExit(f'RC0493_RC0510_FAIL: binding {number}. missing')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('required_numbered_entries') != list(range(493, 511)):
    raise SystemExit('RC0493_RC0510_FAIL: contract sequence mismatch')
if contract.get('promotion_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0493_RC0510_FAIL: unsafe promotion ceiling')
source = SOURCE.read_text(encoding='utf-8')
for token in [
    'ConsultationLayoutPolicy', 'ConsultationDeviceClass.tablet', 'ConsultationOrientation.landscape',
    'ClientReportDraft', 'ClientReportSectionType', 'ClientReportPreview', 'ProfessionalIdentity',
    'ProfessionalReportBrandingPolicy', 'requiresRuhCodeAdvertising', 'maxDetailedPageTarget'
]:
    if token not in source:
        raise SystemExit(f'RC0493_RC0510_FAIL: missing production token {token}')
print('RC0493_RC0510_OK')
