#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
REPORT_SOURCE = ROOT / 'lib/src/pdf/pdf_report_contract.dart'
DATA_SOURCE = ROOT / 'lib/src/pdf/pdf_data_contract.dart'
REPORT_TEST = ROOT / 'test/pdf/pdf_report_contract_test.dart'
DATA_TEST = ROOT / 'test/pdf/pdf_data_contract_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/report_planning_contract.json'

contracts = (
    (REPORT_SOURCE, [
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
    ]),
    (DATA_SOURCE, [
        'final class PdfSnapshotIdentity',
        "RegExp(r'^[a-f0-9]{64}$')",
        'Demo PDF origin requires a demo subject identity.',
        'User PDF origin cannot use a demo subject identity.',
        'does not belong to the report snapshot.',
        'UI and PDF calculation snapshots do not match.',
    ]),
    (REPORT_TEST, [
        'requested section order is preserved while empty sections are suppressed',
        'sample PDF cannot accidentally receive real user data origin',
        'real report cannot accidentally use demo data origin',
        'TR and EN are accepted but arbitrary fallback locale is rejected',
        'report with no non-empty content cannot be generated',
    ]),
    (DATA_TEST, [
        'all report sections must belong to the same exact snapshot',
        'section from another snapshot is rejected before rendering',
        'demo origin cannot be mislabeled as a real client and vice versa',
        'UI and PDF must use the exact same calculation snapshot digest',
    ]),
)

errors = []
for path, tokens in contracts:
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
    features = set(evidence.get('contractFeatures', []))
    for feature in {
        'every section bound to one SHA-256 calculation snapshot identity',
        'cross-snapshot section mixing rejected before rendering',
        'UI and PDF snapshot parity can be required explicitly',
    }:
        if feature not in features:
            errors.append(f'PDF evidence missing feature: {feature}')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Professional PDF report planning/data contract OK (source-level, not DONE).')
