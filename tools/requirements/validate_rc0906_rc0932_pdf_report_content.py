from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0906_rc0932_pdf_report_content_contract.json'
PRODUCTION = ROOT / 'lib/src/pdf/pdf_report_content.dart'
REPORT = ROOT / 'lib/src/pdf/pdf_report_contract.dart'
TEST = ROOT / 'test/pdf/pdf_report_content_rc0906_rc0932_test.dart'

for path in (CONTRACT, PRODUCTION, REPORT, TEST):
    if not path.exists():
        raise SystemExit(f'RC0906_RC0932_FAIL: missing {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(906, 933)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0906_RC0932_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0906_RC0932_FAIL: status ceiling must remain IMPLEMENTED')

production = PRODUCTION.read_text(encoding='utf-8')
report = REPORT.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

required_production = [
    'PdfSubjectReportData',
    "'Bilinmiyor'",
    "'Unknown'",
    'coordinatesLabel',
    'timezoneLabel',
    'PdfCalculationManifestSummary',
    'houseSystem',
    'ayanamsha',
    'PdfSectionPreference',
    'PdfSectionCompositionPlanner',
    'previewSectionIds: immutable',
    'PDF report requires non-empty customer/account information',
    'technicalManifest',
]
for token in required_production:
    if token not in production:
        raise SystemExit(f'RC0906_RC0932_FAIL: missing production token {token!r}')

for token in ('transits', 'preparedInterpretations', 'placements', 'houses', 'aspects', 'numerology', 'customNotes'):
    if token not in report:
        raise SystemExit(f'RC0906_RC0932_FAIL: report contract missing {token!r}')

required_tests = [
    'subject exposes birth date, time, place and timezone without invention',
    'technical report exposes calculation system, house system and manifest summary',
    'technical mode fails closed without calculation manifest',
    'professional can toggle and reorder non-empty sections',
    'client-friendly report hides technical manifest',
    'empty report sections are not emitted and subject data cannot be omitted',
]
for token in required_tests:
    if token not in test:
        raise SystemExit(f'RC0906_RC0932_FAIL: regression token missing {token!r}')

print('RC0906_RC0932_OK')
