#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
REPORT_SOURCE = ROOT / 'lib/src/pdf/pdf_report_contract.dart'
DATA_SOURCE = ROOT / 'lib/src/pdf/pdf_data_contract.dart'
RENDER_SOURCE = ROOT / 'lib/src/pdf/pdf_local_renderer.dart'
INSPECTOR_SOURCE = ROOT / 'lib/src/pdf/pdf_output_inspector.dart'
TABLE_SOURCE = ROOT / 'lib/src/pdf/pdf_table_layout.dart'
SERVICE_SOURCE = ROOT / 'lib/src/pdf/pdf_local_service.dart'
FONT_SOURCE = ROOT / 'lib/src/pdf/pdf_asset_font_provider.dart'
REPORT_TEST = ROOT / 'test/pdf/pdf_report_contract_test.dart'
DATA_TEST = ROOT / 'test/pdf/pdf_data_contract_test.dart'
RENDER_TEST = ROOT / 'test/pdf/pdf_local_renderer_contract_test.dart'
INSPECTOR_TEST = ROOT / 'test/pdf/pdf_output_inspector_test.dart'
TABLE_TEST = ROOT / 'test/pdf/pdf_table_layout_test.dart'
FONT_TEST = ROOT / 'test/pdf/pdf_asset_font_provider_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/report_planning_contract.json'
RENDER_EVIDENCE = ROOT / 'evidence/pdf/local_renderer_contract.json'
PUBSPEC = ROOT / 'pubspec.yaml'

contracts = (
    (REPORT_SOURCE, [
        'static const a4 = PdfPageSpec(', 'widthMm: 210', 'heightMm: 297',
        'enum PdfDataOrigin', 'enum PdfCoverStyle',
        "request.localeTag != 'tr' && request.localeTag != 'en'",
        'Sample PDF must use demo data only.', 'Non-sample PDF must use user data origin.',
        'Duplicate requested PDF section id', 'PDF report has no non-empty content section.', 'selected.add(id)',
    ]),
    (DATA_SOURCE, [
        'final class PdfSnapshotIdentity', "RegExp(r'^[a-f0-9]{64}$')",
        'Demo PDF origin requires a demo subject identity.', 'User PDF origin cannot use a demo subject identity.',
        'does not belong to the report snapshot.', 'UI and PDF calculation snapshots do not match.',
    ]),
    (RENDER_SOURCE, [
        'final class PdfFontBundle', 'sha256.convert(regularBytes)', 'sha256.convert(boldBytes)',
        'final class PdfLocalRenderer', 'static const int maxReportPages = 200',
        'static const double sectionKeepTogetherFreeSpacePt = 72', 'pw.Document(', 'pw.MultiPage(',
        'maxPages: maxReportPages', 'pw.NewPage(freeSpace: sectionKeepTogetherFreeSpacePt)', 'pw.Inseparable(',
        'PdfPageFormat.mm', 'outputInspector.requireUsable(bytes)', 'tableLayout.chunk(section.rows)',
        'Render section ${section.sectionId} belongs to another snapshot.',
        'Selected PDF section $id has no render payload.',
    ]),
    (INSPECTOR_SOURCE, [
        'final class PdfOutputInspector', "text.contains('%%EOF')", "RegExp(r'/Type\\s*/Catalog\\b')",
        "RegExp(r'/Type\\s*/Pages\\b')", "RegExp(r'/Type\\s*/Page(?!s)\\b')", 'structurallyUsable',
        'final int? declaredPageCount', 'bool get pageTreeCountConsistent',
        "r'/Type\\s*/Pages\\b(?:(?!endobj).)*?/Count\\s+(\\d+)'",
        'pageTreeCountConsistent;', 'declaredPages=${inspection.declaredPageCount}',
        'PdfOutputInspection requirePageCount(', 'exact page count cannot be combined with min/max.',
        'Generated PDF page count mismatch:', 'Generated PDF has too few pages:',
        'Generated PDF has too many pages:',
    ]),
    (TABLE_SOURCE, [
        'final class PdfTableLayout', 'maxBodyRowsPerChunk = 24',
        'PDF table row $index has ${input[index].length} columns; expected $width.',
        'List<PdfTableChunk>.unmodifiable(chunks)',
    ]),
    (SERVICE_SOURCE, [
        'abstract interface class PdfReportContentAdapter', 'abstract interface class PdfFontBundleProvider',
        'final class PdfLocalReportService', 'implements PdfService<TSnapshot>',
        'dataValidator.validateAndProject(dataset)', 'planner.build(',
        'fontProvider.loadForLocale(options.localeTag)', 'renderer.render(',
    ]),
    (FONT_SOURCE, [
        'final class PdfFontAssetSpec', "localeTag != 'tr' && localeTag != 'en'",
        'familyName.trim().isEmpty || licenseId.trim().isEmpty', "RegExp(r'^[a-f0-9]{64}$')",
        'final class PdfAssetFontBundleProvider', "for (final locale in const <String>{'tr', 'en'})",
        'bundle.load(spec.regularAssetPath)', 'result.validate();',
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
    (RENDER_TEST, [
        'font bundle rejects a mismatched SHA-256 digest before rendering',
        'renderer rejects cross-snapshot render section before parsing fonts',
        'renderer rejects a selected section without render payload',
    ]),
    (INSPECTOR_TEST, [
        'accepts a minimal structurally usable PDF shape',
        'rejects truncated output without EOF',
        'does not count /Pages tree as a page object',
        'rejects pages tree count that disagrees with actual page objects',
        'rejects a pages tree that omits mandatory Count',
        'page-count gate verifies 5 page regression fixture',
        'page-count gate verifies 25 page regression fixture',
        'page-count gate verifies 50+ page regression fixture',
        'page-count gate rejects silently dropped pages',
    ]),
    (TABLE_TEST, [
        'splits long tables and repeats the header deterministically',
        'large table chunks preserve every body row exactly once and in order',
        'chunk snapshots do not alias later input row mutations',
        'rejects inconsistent column widths before rendering',
        'single row remains a single chunk',
    ]),
    (FONT_TEST, [
        'provider requires an explicit TR and EN font specification', 'provider rejects duplicate locale specifications',
        'loaded font bytes must match the immutable declared SHA-256',
        'verified locale font bundle loads without changing declared provenance',
    ]),
    (PUBSPEC, ['pdf: ^3.13.0']),
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
    if evidence.get('contract') != 'professional-pdf-report-planning-v1': errors.append('unexpected PDF planning evidence contract id')
    if evidence.get('done') is not False: errors.append('PDF planning evidence must remain done=false until byte-render/visual proof exists')
    page = evidence.get('page', {})
    if page.get('format') != 'A4' or page.get('widthMm') != 210 or page.get('heightMm') != 297: errors.append('PDF planning evidence must pin A4 210x297mm')
    if page.get('localOnly') is not True: errors.append('PDF planning evidence must require local-only generation')
    features = set(evidence.get('contractFeatures', []))
    for feature in {
        'every section bound to one SHA-256 calculation snapshot identity',
        'cross-snapshot section mixing rejected before rendering',
        'UI and PDF snapshot parity can be required explicitly',
        'long table chunking repeats headers without losing duplicating or reordering body rows',
        'table chunks copy source rows so later input mutation cannot alter the render plan',
    }:
        if feature not in features: errors.append(f'PDF evidence missing feature: {feature}')
    for key in ('sources', 'tests'):
        values = evidence.get(key)
        if not isinstance(values, list) or not values:
            errors.append(f'PDF planning evidence must contain non-empty {key}[]')
            continue
        if len(values) != len(set(values)):
            errors.append(f'PDF planning evidence contains duplicate {key} entries')
        for relative in values:
            path = ROOT / relative
            if not path.is_file():
                errors.append(f'PDF planning evidence {key} path does not exist: {relative}')

if not RENDER_EVIDENCE.exists():
    errors.append(f'missing {RENDER_EVIDENCE.relative_to(ROOT)}')
else:
    render_evidence = json.loads(RENDER_EVIDENCE.read_text(encoding='utf-8'))
    if render_evidence.get('contract') != 'professional-pdf-local-renderer-v1': errors.append('unexpected local PDF renderer evidence contract id')
    if render_evidence.get('done') is not False: errors.append('local renderer evidence must remain done=false until approved fonts and render regression pass')
    if render_evidence.get('localOnly') is not True: errors.append('local PDF renderer must be local-only')
    required = set(render_evidence.get('requiredProperties', []))
    for item in {
        'all selected sections belong to one exact SHA-256 calculation snapshot',
        'regular and bold font bytes are verified against declared SHA-256 digests',
        'font family and license identifiers are mandatory',
        'renderer explicitly supports reports longer than 50 pages with a bounded 200-page safety ceiling',
        'section headings are protected against orphaning by a minimum remaining-space break and inseparable heading plus first paragraph',
        'generated bytes must pass PDF header EOF catalog pages-tree and page-object structural inspection before return',
        'the Pages-tree declared Count is mandatory and must exactly match the actual Page-object count',
        'page-count verification can enforce exact or bounded page counts after structural validation',
        '5-page 25-page and 50-plus regression fixtures are covered at the structural page-count gate',
        'long tables are split into deterministic bounded chunks with repeated logical headers',
        'inconsistent table column widths are rejected before rendering',
    }:
        if item not in required: errors.append(f'local PDF renderer evidence missing property: {item}')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Professional PDF planning/data/local-renderer/output/page-count/table/font-provider contract OK (source-level, not DONE).')