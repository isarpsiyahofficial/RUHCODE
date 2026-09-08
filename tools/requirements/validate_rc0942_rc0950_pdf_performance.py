from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0942_rc0950_pdf_performance_contract.json'
PRODUCTION = ROOT / 'lib/src/pdf/pdf_generation_performance.dart'
TEST = ROOT / 'test/pdf/pdf_generation_performance_rc0942_rc0950_test.dart'
INSPECTOR = ROOT / 'lib/src/pdf/pdf_output_inspector.dart'

for path in (CONTRACT, PRODUCTION, TEST, INSPECTOR):
    if not path.exists():
        raise SystemExit(f'RC0942_RC0950_FAIL: missing {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(942, 951)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0942_RC0950_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0942_RC0950_FAIL: status ceiling must remain IMPLEMENTED')

production = PRODUCTION.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
inspector = INSPECTOR.read_text(encoding='utf-8')

for token in (
    'PdfPerformanceWorkload',
    'fivePages',
    'twentyFivePages',
    'fiftyPlusPages',
    'hundredsOfTableRows',
    'PdfPerformanceObservation',
    'peakResidentBytes',
    'uiHeartbeatCount',
    'deviceClass',
    'PdfPerformanceBudget',
    'PdfAtomicCompletionGate',
    'AtomicPdfPublicationTarget',
    'commitCompletePdf',
):
    if token not in production:
        raise SystemExit(f'RC0942_RC0950_FAIL: missing production token {token!r}')

for token in (
    '5 page professional report fixture is structurally complete',
    '25 page professional report fixture is structurally complete',
    '50+ page professional report fixture is structurally complete',
    'hundreds of true table rows can be serialized into a usable PDF',
    'performance budget requires measured memory, device and UI heartbeat evidence',
    'unfinished PDF bytes are never committed as a successful report',
    'generation exception leaves existing publication untouched',
):
    if token not in test:
        raise SystemExit(f'RC0942_RC0950_FAIL: missing regression token {token!r}')

for token in ('requireUsable', 'requirePageCount', 'hasEofMarker', 'startXrefTargetRecognized'):
    if token not in inspector:
        raise SystemExit(f'RC0942_RC0950_FAIL: structural inspector missing token {token!r}')

print('RC0942_RC0950_OK')
