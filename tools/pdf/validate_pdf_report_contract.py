#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/pdf/pdf_report_contract.dart'
TEST = ROOT / 'test/pdf/pdf_report_contract_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/report_planning_contract.json'

required_source_tokens = [
    'static const a4 = PdfPageSpec(',
    'widthMm: 210',
    'heightMm: 297',
    'enum PdfDataOrigin',
    'enum PdfCoverStyle',
    "request.localeTag != 'tr' && request.localeTag != 'en'",
    'Sample PDF must use demo data only.',
    'Non-sample PDF must use user data origin.',
    'Duplicate requested PDF section id',
    'PDF report has no non-empty content section.',
    'selected.add(id)',
]

required_test_tokens = [
    'requested section order is preserved while empty sections are suppressed',
    'sample PDF cannot accidentally receive real user data origin',
    'real report cannot accidentally use demo data origin',
    'TR and EN are accepted but arbitrary fallback locale is rejected',
    'report with no non-empty content cannot be generated',
]

errors = []
for path, tokens in ((SOURCE, required_source_tokens), (TEST, required_test_tokens)):
    if not path.exists():
        errors.append(f'missing {path.relative_to(ROOT)}')
        continue
    text = path.read_text(encoding='utf-8')
    for token in tokens:
        if token not in text:
            errors.append(f'{path.relative_to(ROOT)} missing token: {token}')

if not EVIDENCE.exists():
    errors.append(f'missing {EVIDENCE.relative_to(ROOT)}')
else:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if evidence.get('contract') != 'professional-pdf-report-planning-v1':
        errors.append('unexpected PDF planning evidence contract id')
    if evidence.get('done') is not False:
        errors.append('PDF planning evidence must remain done=false until byte-render/visual proof exists')
    page = evidence.get('page', {})
    if page.get('format') != 'A4' or page.get('widthMm') != 210 or page.get('heightMm') != 297:
        errors.append('PDF planning evidence must pin A4 210x297mm')
    if page.get('localOnly') is not True:
        errors.append('PDF planning evidence must require local-only generation')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Professional PDF report planning contract OK (source-level, not DONE).')
