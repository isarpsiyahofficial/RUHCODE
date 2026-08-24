from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/persisted_combined_projection.json'
ACTIONS = ROOT / 'lib/src/ui/pdf/combined_professional_pdf_ui_actions.dart'
STATE = ROOT / 'lib/src/ui/pdf/combined_pdf_selection_state.dart'
RUNTIME = ROOT / 'lib/src/app/app_runtime.dart'
MAIN = ROOT / 'lib/main.dart'
TEST = ROOT / 'test/ui/pdf/combined_pdf_selection_state_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    actions = ACTIONS.read_text(encoding='utf-8')
    state = STATE.read_text(encoding='utf-8')
    runtime = RUNTIME.read_text(encoding='utf-8')
    main = MAIN.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')

    require(evidence.get('requirements') == ['RC-0903', 'RC-0904'],
            'Combined UI runtime evidence may own only RC-0903 and RC-0904.')
    require(evidence.get('done') is False,
            'Combined UI runtime evidence cannot be DONE before visible route/font/CI proof.')

    for token in [
        'CombinedProfessionalPdfUiActions',
        'CombinedProfessionalPdfApplicationActions',
        'listSubjects',
        'listCandidates',
        'preview',
        'build',
        'CombinedProfessionalPdfUiRuntimeBindings',
    ]:
        require(token in actions, f'Missing combined UI action token: {token}')

    for token in [
        'CombinedPdfSelectionState',
        '_preview = null',
        'toggleRecord',
        'setLocale',
        'setSections',
        'createPreview',
        'Create a current combined PDF preview before build.',
    ]:
        require(token in state, f'Missing combined selection-state token: {token}')

    for token in [
        'CombinedProfessionalPdfApplicationService',
        'PersistedCombinedPdfProjectionSource',
        'combinedProfessionalPdf',
        'UnavailablePdfService<PdfCombinedReportProjection>',
    ]:
        require(token in runtime, f'Missing combined runtime token: {token}')

    require('CombinedProfessionalPdfUiRuntimeBindings.bind' in main,
            'Combined UI runtime binding is not installed at startup.')
    require('runtime.combinedProfessionalPdf' in main,
            'Startup binding must use the production combined application service.')

    for token in [
        "test('exact preview input can build'",
        "test('record change invalidates preview before build'",
        "test('locale and section changes invalidate preview'",
        'records outside selected subject cannot be toggled',
    ]:
        require(token in test, f'Missing combined selection regression: {token}')

    for rel in evidence.get('sources', []) + evidence.get('tests', []) + evidence.get('validators', []):
        require((ROOT / rel).is_file(), f'Combined evidence path missing: {rel}')

    print('Combined PDF runtime/UI selection contract: OK')


if __name__ == '__main__':
    main()
