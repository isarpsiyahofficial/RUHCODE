#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/numerology/ui_pdf_presentation_parity.json'
UI = ROOT / 'lib/src/ui/numerology/numerology_presentation.dart'
SCREEN = ROOT / 'lib/src/ui/numerology/numerology_screen.dart'
PDF_DATA = ROOT / 'lib/src/pdf/pdf_numerology_data.dart'
PDF_SECTION = ROOT / 'lib/src/pdf/pdf_numerology_section.dart'
UI_TEST = ROOT / 'test/ui/numerology/numerology_presentation_test.dart'
SCREEN_TEST = ROOT / 'test/ui/numerology/numerology_screen_test.dart'
PDF_TEST = ROOT / 'test/pdf/pdf_numerology_section_test.dart'

for path in (EVIDENCE, UI, SCREEN, PDF_DATA, PDF_SECTION, UI_TEST, SCREEN_TEST, PDF_TEST):
    if not path.is_file():
        raise SystemExit(f'missing required numerology parity artifact: {path.relative_to(ROOT)}')

evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
if evidence.get('status') != 'SOURCE_LEVEL_IMPLEMENTED' or evidence.get('done') is not False:
    raise SystemExit('numerology UI/PDF parity evidence must remain source-level and not DONE without runtime proof')

ui = UI.read_text(encoding='utf-8')
screen = SCREEN.read_text(encoding='utf-8')
pdf_data = PDF_DATA.read_text(encoding='utf-8')
pdf_section = PDF_SECTION.read_text(encoding='utf-8')
ui_test = UI_TEST.read_text(encoding='utf-8')
screen_test = SCREEN_TEST.read_text(encoding='utf-8')
pdf_test = PDF_TEST.read_text(encoding='utf-8')

required_ui_tokens = [
    'PythagoreanNumerologySnapshot',
    'PythagoreanSnapshotFingerprint.sha256Hex(snapshot)',
    "sectionId: 'core'",
    "sectionId: 'name_analysis'",
    "sectionId: 'periods'",
    "sectionId: 'personal_cycles'",
    "metricId: 'life_path'",
    "metricId: 'personal_day'",
]
for token in required_ui_tokens:
    if token not in ui:
        raise SystemExit(f'missing UI presentation contract token: {token}')

for token in (
    'class NumerologyScreen extends StatelessWidget',
    'final NumerologyPresentationModel? model;',
    'NumerologyScreenCopy.forLocale(locale)',
    "case 'tr':",
    "case 'en':",
    "throw UnsupportedError(",
    "throw StateError('Missing localized numerology metric: $metricId')",
    "key: Key('numerology-metric-${row.metricId}')",
):
    if token not in screen:
        raise SystemExit(f'missing functional numerology screen token: {token}')

for forbidden in (
    'PythagoreanNumerologySnapshotEngine.calculate',
    'PythagoreanProfileEngine.calculate',
    'PythagoreanPersonalCyclesEngine.calculate',
):
    if forbidden in ui or forbidden in screen or forbidden in pdf_section:
        raise SystemExit(f'presentation/PDF layers must not recalculate numerology: {forbidden}')

for token in ('PdfNumerologyPayload', 'PdfRenderSection', 'PdfSectionIds.numerology', 'snapshotDigest'):
    if token not in pdf_section:
        raise SystemExit(f'missing PDF section contract token: {token}')

if 'final digest = PythagoreanSnapshotFingerprint.sha256Hex(snapshot);' not in pdf_data:
    raise SystemExit('canonical PDF data adapter digest contract missing')
if 'expect(ui.snapshotDigest, pdf.snapshotDigest);' not in ui_test:
    raise SystemExit('UI/PDF snapshot digest parity regression missing')
if 'expect(uiRows, pdfRows);' not in ui_test:
    raise SystemExit('UI/PDF metric parity regression missing')
if 'blank localized metric label is rejected before render' not in pdf_test:
    raise SystemExit('localized PDF label fail-closed regression missing')

for token in (
    "home: NumerologyScreen(model: model, locale: Locale('tr'))",
    "home: NumerologyScreen(model: model, locale: Locale('en'))",
    "home: NumerologyScreen(model: null, locale: Locale('tr'))",
    "expect(find.text('life_path'), findsNothing);",
    "throwsUnsupportedError",
    "throwsStateError",
):
    if token not in screen_test:
        raise SystemExit(f'missing numerology screen regression token: {token}')

print('numerology UI/PDF presentation parity contract: OK')
