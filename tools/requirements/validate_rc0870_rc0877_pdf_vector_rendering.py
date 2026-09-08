from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0870_rc0877_pdf_vector_rendering_contract.json'
VECTOR = ROOT / 'lib/src/pdf/pdf_vector_rendering.dart'
WIDGET = ROOT / 'lib/src/pdf/pdf_vector_widget.dart'
RENDERER = ROOT / 'lib/src/pdf/pdf_local_renderer.dart'
TABLE = ROOT / 'lib/src/pdf/pdf_table_layout.dart'
TEST = ROOT / 'test/pdf/pdf_vector_rendering_rc0870_rc0877_test.dart'

for path in (CONTRACT, VECTOR, WIDGET, RENDERER, TABLE, TEST):
    if not path.exists():
        raise SystemExit(f'RC0870_RC0877_FAIL: missing {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(870, 878)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0870_RC0877_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0870_RC0877_FAIL: status ceiling must remain IMPLEMENTED')

vector = VECTOR.read_text(encoding='utf-8')
widget = WIDGET.read_text(encoding='utf-8')
renderer = RENDERER.read_text(encoding='utf-8')
table = TABLE.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

required_vector_tokens = [
    'PdfVectorGraphic',
    'PdfWesternChartVectorBuilder',
    'PdfVedicChartVectorBuilder',
    'PdfAspectVector',
    'PdfStructuredTableRules',
    "normalized.contains('<image')",
    "normalized.contains('data:image')",
    "semanticKind: 'western_astrology_chart'",
    "semanticKind: 'vedic_chart'",
    'preserveAspectRatio="xMidYMid meet"',
]
for token in required_vector_tokens:
    if token not in vector:
        raise SystemExit(f'RC0870_RC0877_FAIL: missing vector token {token!r}')

if 'pw.SvgImage(svg: graphic.svg)' not in widget:
    raise SystemExit('RC0870_RC0877_FAIL: SVG primitive is not bound to package:pdf SvgImage')
if 'pw.TableHelper.fromTextArray' not in renderer:
    raise SystemExit('RC0870_RC0877_FAIL: renderer no longer uses real PDF table widgets')
if 'PDF table row' not in table:
    raise SystemExit('RC0870_RC0877_FAIL: rectangular table alignment guard missing')

required_tests = [
    'western chart is SVG vector-only',
    'vedic chart is square vector geometry',
    'raster payloads fail closed',
    'Numerology',
    'BaZi',
    'document.save()',
]
for token in required_tests:
    if token not in test:
        raise SystemExit(f'RC0870_RC0877_FAIL: regression token missing {token!r}')

print('RC0870_RC0877_OK')
