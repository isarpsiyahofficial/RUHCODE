from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0895_rc0905_pdf_cover_composition_contract.json'
PRODUCTION = ROOT / 'lib/src/pdf/pdf_cover_composition.dart'
REPORT = ROOT / 'lib/src/pdf/pdf_report_contract.dart'
TEST = ROOT / 'test/pdf/pdf_cover_composition_rc0895_rc0905_test.dart'

for path in (CONTRACT, PRODUCTION, REPORT, TEST):
    if not path.exists():
        raise SystemExit(f'RC0895_RC0905_FAIL: missing {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(895, 906)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0895_RC0905_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0895_RC0905_FAIL: status ceiling must remain IMPLEMENTED')

production = PRODUCTION.read_text(encoding='utf-8')
report = REPORT.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

required = [
    'PdfResolvedLogo',
    'PdfCoverCompositionPlanner',
    'reserveLogoSpace: showLogo',
    'PdfCoverWidget',
    'pw.SvgImage(svg: logo!.svg)',
    'PdfSystemVisualIdentity',
    'PdfCombinedSystemSection',
    'PdfCombinedSystemGuard',
    'Duplicate combined PDF system section',
]
for token in required:
    if token not in production:
        raise SystemExit(f'RC0895_RC0905_FAIL: missing production token {token!r}')

for token in ('PdfCoverStyle', 'western', 'vedic', 'numerology', 'combined'):
    if token not in report:
        raise SystemExit(f'RC0895_RC0905_FAIL: report contract missing {token!r}')

required_tests = [
    'logo-free cover reserves no logo area',
    'requested local vector logo renders only when resolved id matches',
    'report kind and selected cover style remain explicit',
    'combined reports require clearly separated unique systems',
    'document.save()',
]
for token in required_tests:
    if token not in test:
        raise SystemExit(f'RC0895_RC0905_FAIL: regression token missing {token!r}')

print('RC0895_RC0905_OK')
