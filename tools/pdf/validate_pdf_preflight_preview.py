from pathlib import Path
import csv
import json
import re

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/preflight_preview_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
ADDENDUM = ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md'
SOURCE = ROOT / 'lib/src/pdf/pdf_preflight_preview.dart'
BUILDER = ROOT / 'lib/src/ui/pdf/pdf_reports_pages.dart'
UI_ACTIONS = ROOT / 'lib/src/ui/pdf/professional_pdf_ui_actions.dart'
ACTIONS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'
REGISTRY = ROOT / 'ui/action_registry_runtime_extensions.csv'
BINDINGS = ROOT / 'ui/runtime_action_bindings.csv'
NUMEROLOGY_HANDLER = ROOT / 'lib/src/pdf/persisted_pythagorean_numerology_pdf.dart'
WESTERN_HANDLER = ROOT / 'lib/src/pdf/persisted_western_natal_pdf_service.dart'
RENDERER = ROOT / 'lib/src/pdf/pdf_local_renderer.dart'
TEST = ROOT / 'test/pdf/pdf_preflight_preview_test.dart'
WIDGET_TEST = ROOT / 'test/ui/professional_pdf_builder_page_test.dart'
RENDER_CONTRACT_TEST = ROOT / 'test/pdf/pdf_render_contract_validator_test.dart'

for path in (
    EVIDENCE, MASTER, ADDENDUM, SOURCE, BUILDER, UI_ACTIONS, ACTIONS, REGISTRY,
    BINDINGS, NUMEROLOGY_HANDLER, WESTERN_HANDLER, RENDERER, TEST, WIDGET_TEST,
    RENDER_CONTRACT_TEST,
):
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
if data.get('requirement_ids') != ['RC-0929', 'RC-1440', 'RC-1441']:
    raise SystemExit('preflight preview evidence must own exactly RC-0929, RC-1440 and RC-1441')
if data.get('done') is not False:
    raise SystemExit('preflight preview evidence must remain not-DONE until exact CI and final UI proof exist')

master = MASTER.read_text(encoding='utf-8')
addendum = ADDENDUM.read_text(encoding='utf-8')
for number, token in ((929, 'önizleme'), (1440, 'dokunulabilir'), (1441, 'accessibility')):
    source_master = master if number <= 1420 else addendum
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
    'ProfessionalPdfSectionCatalog.optionsFor',
    "label: 'PDF Önizle'",
    'BoxConstraints(minHeight: 48)',
    'sameBuildInputAs',
    "_error = 'PDF oluşturmadan önce güncel rapor planını Önizle.'",
):
    if token not in builder:
        raise SystemExit(f'missing builder preflight/parity token: {token}')
if "'notes', 'Notlar'" in builder:
    raise SystemExit('professional PDF builder must not use the non-canonical notes section ID')

ui_actions = UI_ACTIONS.read_text(encoding='utf-8')
for token in (
    "pythagorean = 'numerology.pythagorean'",
    "westernNatal = 'western.natal'",
    'PdfSectionIds.numerology',
    'PdfSectionIds.technicalManifest',
    'PdfSectionIds.placements',
    'PdfSectionIds.houses',
    'PdfSectionIds.aspects',
    'static bool supports',
):
    if token not in ui_actions:
        raise SystemExit(f'missing calculation-aware PDF section catalog token: {token}')
for forbidden in ('PdfSectionIds.chart', 'PdfSectionIds.interpretation', 'PdfSectionIds.customNotes'):
    if forbidden in ui_actions:
        raise SystemExit(f'UI section catalog advertises unsupported production section: {forbidden}')

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

numerology = NUMEROLOGY_HANDLER.read_text(encoding='utf-8')
for token in (
    'PdfCoverSectionAdapter.dataRef',
    'PdfSectionIds.numerology',
    'PdfSectionIds.technicalManifest',
    'PdfCoverSectionAdapter.build',
    'PersistedManifestSectionAdapter.build',
):
    if token not in numerology:
        raise SystemExit(f'persisted numerology PDF handler missing planned/rendered section token: {token}')

western = WESTERN_HANDLER.read_text(encoding='utf-8')
for token in (
    'PdfCoverSectionAdapter.dataRef',
    'PdfSectionIds.placements',
    'PdfSectionIds.houses',
    'PdfSectionIds.aspects',
    'PdfSectionIds.technicalManifest',
    'PdfCoverSectionAdapter.build',
    'PersistedManifestSectionAdapter.build',
):
    if token not in western:
        raise SystemExit(f'persisted Western PDF handler missing planned/rendered section token: {token}')

renderer = RENDERER.read_text(encoding='utf-8')
for token in (
    'PdfRenderContractValidator',
    'is not declared by the verified dataset',
    'Selected PDF section $id has no render payload',
):
    if token not in renderer:
        raise SystemExit(f'missing strict selectable-render contract token: {token}')
if 'is not selected by the report plan' in renderer:
    raise SystemExit('renderer still rejects verified unselected payloads and therefore breaks section toggles')

test = TEST.read_text(encoding='utf-8')
for token in ('preserves exact planned section order', 'empty plan fails closed', 'duplicate sections fail closed'):
    if token not in test:
        raise SystemExit(f'missing preview regression assertion: {token}')

widget_test = WIDGET_TEST.read_text(encoding='utf-8')
for token in (
    'requires current preview before PDF generation',
    'numerology preview and build use handler-supported canonical sections only',
    'western record exposes only persisted western handler sections',
    'changing a section invalidates preview and blocks stale-plan build',
    'unsupported calculation records are not advertised as buildable',
    'RuhActionIds.pdfPreflight',
    'PdfSectionIds.technicalManifest',
):
    if token not in widget_test:
        raise SystemExit(f'missing builder preflight widget regression assertion: {token}')

render_test = RENDER_CONTRACT_TEST.read_text(encoding='utf-8')
for token in (
    'verified unselected render payload is allowed but selected subset stays strict',
    'selected section without render payload fails closed',
    'render payload not declared by verified dataset fails closed',
    'unselected payload from another snapshot still fails closed',
):
    if token not in render_test:
        raise SystemExit(f'missing selectable renderer regression assertion: {token}')

print('PDF preflight preview contract: OK (RC-0929/1440/1441 source-level; exact CI still required)')
