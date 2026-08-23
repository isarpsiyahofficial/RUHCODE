from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/preflight_preview_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
SOURCE = ROOT / 'lib/src/pdf/pdf_preflight_preview.dart'
TEST = ROOT / 'test/pdf/pdf_preflight_preview_test.dart'

for path in (EVIDENCE, MASTER, SOURCE, TEST):
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
if data.get('requirement_ids') != ['RC-0929']:
    raise SystemExit('preflight preview evidence must own exactly RC-0929')
if data.get('done') is not False:
    raise SystemExit('RC-0929 must remain not-DONE until builder wiring and exact CI proof exist')
master = MASTER.read_text(encoding='utf-8')
match = re.search(r'^929\.\s+(.+)$', master, flags=re.MULTILINE)
if not match or 'önizleme' not in match.group(1).lower():
    raise SystemExit('MASTER RC-0929 semantic ownership drifted')
source = SOURCE.read_text(encoding='utf-8')
for token in ('PdfPreflightPreview', 'PdfPreflightPreviewBuilder', 'fromPlan', 'PdfReportPlan'):
    if token not in source:
        raise SystemExit(f'missing preview source token: {token}')
test = TEST.read_text(encoding='utf-8')
for token in ('preserves exact planned section order', 'empty plan fails closed', 'duplicate sections fail closed'):
    if token not in test:
        raise SystemExit(f'missing preview regression assertion: {token}')
print('PDF preflight preview contract: OK (RC-0929 source-level only)')
