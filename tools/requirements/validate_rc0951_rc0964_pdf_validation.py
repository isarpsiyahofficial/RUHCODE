from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0951_rc0964_pdf_validation_contract.json'
PRODUCTION = ROOT / 'lib/src/pdf/pdf_release_validation.dart'
INSPECTOR = ROOT / 'lib/src/pdf/pdf_output_inspector.dart'
TEST = ROOT / 'test/pdf/pdf_release_validation_rc0951_rc0964_test.dart'

for path in (CONTRACT, PRODUCTION, INSPECTOR, TEST):
    if not path.exists():
        raise SystemExit(f'RC0951_RC0964_FAIL: missing {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(951, 965)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0951_RC0964_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0951_RC0964_FAIL: status ceiling must remain IMPLEMENTED')

production = PRODUCTION.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
inspector = INSPECTOR.read_text(encoding='utf-8')

for token in (
    'PdfRenderedPageEvidence',
    'textOverflowPixels',
    'chartClipPixels',
    'brokenSymbolCount',
    'missingTurkishGlyphCount',
    'PdfVisualRegressionEvidence',
    'meanLayoutShiftRatio',
    'changedPixelRatio',
    'PdfExpectedReportIdentity',
    'subjectId',
    'requiredTextFragments',
    'requiresChart',
    'PdfParsedContentEvidence',
    'chartObjectCount',
    'PdfReleaseValidationPolicy',
):
    if token not in production:
        raise SystemExit(f'RC0951_RC0964_FAIL: missing production token {token!r}')

for token in (
    'missing required text is a hard failure',
    'required chart must be present in parsed PDF evidence',
    'page count must match actual rendered pages',
    'text overflow, chart clipping, broken symbol and Turkish glyph loss are hard failures',
    'different subject identity is a critical fail-closed condition',
    'large layout shifts fail but raw pixel difference alone does not',
):
    if token not in test:
        raise SystemExit(f'RC0951_RC0964_FAIL: missing regression token {token!r}')

for token in ('structurallyUsable', 'requireUsable', 'pageObjectCount'):
    if token not in inspector:
        raise SystemExit(f'RC0951_RC0964_FAIL: structural inspector missing token {token!r}')

print('RC0951_RC0964_OK')
