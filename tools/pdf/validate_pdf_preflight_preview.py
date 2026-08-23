from pathlib import Path
import csv
import json
import re

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/preflight_preview_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
SOURCE = ROOT / 'lib/src/pdf/pdf_preflight_preview.dart'
BUILDER = ROOT / 'lib/src/ui/pdf/pdf_reports_pages.dart'
ACTIONS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'
REGISTRY = ROOT / 'ui/action_registry_runtime_extensions.csv'
BINDINGS = ROOT / 'ui/runtime_action_bindings.csv'
TEST = ROOT / 'test/pdf/pdf_preflight_preview_test.dart'
WIDGET_TEST = ROOT / 'test/ui/professional_pdf_builder_page_test.dart'

for path in (EVIDENCE, MASTER, SOURCE, BUILDER, ACTIONS, REGISTRY, BINDINGS, TEST, WIDGET_TEST):
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
if data.get('requirement_ids') != ['RC-0929', 'RC-1440', 'RC-1441']:
    raise SystemExit('preflight preview evidence must own exactly RC-0929, RC-1440 and RC-1441')
if data.get('done') is not False:
    raise SystemExit('preflight preview evidence must remain not-DONE until exact CI and final UI proof exist')
master = MASTER.read_text(encoding='utf-8')
for number, token in ((929, 'önizleme'), (1440, 'dokunulabilir'), (1441, 'accessibility')):
    source_master = master
    if number > 1420:
        source_master = (ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md').read_text(encoding='utf-8')
    match = re.search(rf'^{number}\.\s+(.+)$', source_master, flags=re.MULTILINE)
    if not match or token not in match.group(1).lower():
        raise SystemExit(f'MASTER RC-{number:04d} semantic ownership drifted')

source = SOURCE.read_text(encoding='utf-8')
for token in ('PdfPreflightPreview', 'PdfPreflightPreviewBuilder', 'fromPlan', 'PdfReportPlan'):
    if token not in source:
        raise SystemExit(f'missing preview source token: {token}')

builder = BUILDER.read_text(encoding='utf-8')
for token in (
    'RuhActionIds.pdfPreflight',
    'PdfPreflightPreviewBuilder',
    'PdfReportPlanner',
    'PdfSectionIds.customNotes',
    "label: 'PDF Önizle'",
    'BoxConstraints(minHeight: 48)',
    'sameBuildInputAs',
    "_error = 'PDF oluşturmadan önce güncel rapor planını Önizle.'",
):
    if token not in builder:
        raise SystemExit(f'missing builder preflight/parity token: {token}')
if "'notes', 'Notlar'" in builder:
    raise SystemExit('professional PDF builder must not use the non-canonical notes section ID')

if "pdfPreflight = 'ACTION-PDF-BUILDER-PREVIEW'" not in ACTIONS.read_text(encoding='utf-8'):
    raise SystemExit('canonical professional PDF preflight action constant is missing')

with REGISTRY.open(newline='', encoding='utf-8') as handle:
    rows = {row['action_id']: row for row in csv.DictReader(handle)}
row = rows.get('ACTION-PDF-BUILDER-PREVIEW')
if row is None:
    raise SystemExit('ACTION-PDF-BUILDER-PREVIEW is missing from runtime extension registry')
if row['source_screen_id'] != 'SCR-PDF-BUILDER-001' or row['entitlement'] != 'PRO' or row['status'] != 'ACTIVE':
    raise SystemExit('professional PDF preflight registry row drifted')
if row['a11y_label_required'].lower() != 'true':
    raise SystemExit('professional PDF preflight action must require an accessibility label')

with BINDINGS.open(newline='', encoding='utf-8') as handle:
    rows = {row['action_id']: row for row in csv.DictReader(handle)}
row = rows.get('ACTION-PDF-BUILDER-PREVIEW')
if row is None or row['constant_name'] != 'pdfPreflight' or row['status'] != 'IMPLEMENTED':
    raise SystemExit('professional PDF preflight runtime binding is missing or stale')

test = TEST.read_text(encoding='utf-8')
for token in ('preserves exact planned section order', 'empty plan fails closed', 'duplicate sections fail closed'):
    if token not in test:
        raise SystemExit(f'missing preview regression assertion: {token}')
widget_test = WIDGET_TEST.read_text(encoding='utf-8')
for token in (
    'requires current preview before PDF generation',
    'preflight preview and build use the exact same canonical plan input',
    'changing a section invalidates preview and blocks stale-plan build',
    'RuhActionIds.pdfPreflight',
    'PdfSectionIds.customNotes',
):
    if token not in widget_test:
        raise SystemExit(f'missing builder preflight widget regression assertion: {token}')

print('PDF preflight preview contract: OK (RC-0929/1440/1441 source-level; exact CI still required)')
