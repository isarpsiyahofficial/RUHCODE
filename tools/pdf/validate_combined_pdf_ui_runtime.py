from pathlib import Path
import csv
import json

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/persisted_combined_projection.json'
ACTIONS = ROOT / 'lib/src/ui/pdf/combined_professional_pdf_ui_actions.dart'
STATE = ROOT / 'lib/src/ui/pdf/combined_pdf_selection_state.dart'
PAGE = ROOT / 'lib/src/ui/pdf/combined_pdf_builder_page.dart'
DELIVERY = ROOT / 'lib/src/pdf/combined_professional_pdf_delivery_service.dart'
RUNTIME = ROOT / 'lib/src/app/app_runtime.dart'
APP = ROOT / 'lib/src/app/ruh_code_app.dart'
NAVIGATION = ROOT / 'lib/src/ui/navigation/main_navigation_shell.dart'
ACTION_IDS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'
ACTION_EXTENSIONS = ROOT / 'ui/action_registry_runtime_extensions.csv'
RUNTIME_BINDINGS = ROOT / 'ui/runtime_action_bindings.csv'
MAIN = ROOT / 'lib/main.dart'
STATE_TEST = ROOT / 'test/ui/pdf/combined_pdf_selection_state_test.dart'
WIDGET_TEST = ROOT / 'test/ui/pdf/combined_pdf_builder_page_test.dart'
ROUTE_TEST = ROOT / 'test/ui/pdf/combined_pdf_route_entitlement_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def csv_ids(path: Path) -> set[str]:
    with path.open(encoding='utf-8', newline='') as handle:
        return {row['action_id'] for row in csv.DictReader(handle)}


def main() -> None:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    actions = ACTIONS.read_text(encoding='utf-8')
    state = STATE.read_text(encoding='utf-8')
    page = PAGE.read_text(encoding='utf-8')
    delivery = DELIVERY.read_text(encoding='utf-8')
    runtime = RUNTIME.read_text(encoding='utf-8')
    app = APP.read_text(encoding='utf-8')
    navigation = NAVIGATION.read_text(encoding='utf-8')
    action_ids = ACTION_IDS.read_text(encoding='utf-8')
    main_source = MAIN.read_text(encoding='utf-8')
    state_test = STATE_TEST.read_text(encoding='utf-8')
    widget_test = WIDGET_TEST.read_text(encoding='utf-8')
    route_test = ROUTE_TEST.read_text(encoding='utf-8')

    require(evidence.get('requirements') == ['RC-0903', 'RC-0904'],
            'Combined UI runtime evidence may own only RC-0903 and RC-0904.')
    require(evidence.get('done') is False,
            'Combined UI runtime evidence cannot be DONE before approved-font/CI proof.')

    for token in [
        'CombinedProfessionalPdfUiActions',
        'CombinedProfessionalPdfApplicationActions',
        'listSubjects',
        'listCandidates',
        'preview',
        'build',
        'systems.length < 2',
        'CombinedProfessionalPdfDeliveryActions',
        'CombinedProfessionalPdfDeliveryApplicationActions',
        'CombinedProfessionalPdfUiRuntimeBindings',
        'bindDelivery',
    ]:
        require(token in actions, f'Missing combined UI action token: {token}')

    for token in [
        'CombinedPdfSelectionState',
        '_preview = null',
        'toggleRecord',
        'setLocale',
        'setSections',
        'selectedSystems.length < 2',
        'createPreview',
        'sealedPreviewForDelivery',
        'Create a current combined PDF preview before build.',
    ]:
        require(token in state, f'Missing combined selection-state token: {token}')

    for token in [
        'CombinedProfessionalPdfBuilderPage',
        "ValueKey(RuhActionIds.pdfCombinedPreview)",
        "ValueKey(RuhActionIds.pdfCombinedCreate)",
        "ValueKey(RuhActionIds.pdfCombinedSave)",
        "ValueKey(RuhActionIds.pdfCombinedShare)",
        'BoxConstraints(minHeight: 48)',
        'Semantics(',
        'sealedPreviewForDelivery',
        'combined-pdf-subject-selector',
        'combined-pdf-preview-card',
    ]:
        require(token in page, f'Missing visible combined builder token: {token}')

    for token in [
        'CombinedProfessionalPdfDeliveryService',
        'application.buildFromPreview',
        'platform.savePdf',
        'platform.sharePdf',
        'CombinedPdfDeliveryStatus.cancelled',
        'CombinedPdfDeliveryStatus.unavailable',
    ]:
        require(token in delivery, f'Missing combined native-delivery token: {token}')

    for token in [
        'CombinedProfessionalPdfApplicationService',
        'PersistedCombinedPdfProjectionSource',
        'combinedProfessionalPdf',
        'combinedProfessionalPdfDelivery',
        'CombinedProfessionalPdfDeliveryService',
        'NativePdfPlatformGateway',
        'UnavailablePdfService<PdfCombinedReportProjection>',
    ]:
        require(token in runtime, f'Missing combined runtime token: {token}')

    require("combinedPdfRoute = '/pdf/combined'" in app,
            'Combined PDF named route is missing from RuhCodeApp.')
    require('CombinedProfessionalPdfBuilderPage' in app,
            'Combined PDF named route does not render the visible builder page.')
    require('RuhActionIds.pdfCombined' in navigation,
            'Settings does not expose the combined PDF route action.')
    require("pushNamed<void>('/pdf/combined')" in navigation,
            'Settings combined PDF action is not connected to the named route.')
    require('RuhFeatureIds.pdfProfessionalExport' in navigation,
            'Combined PDF route must use the canonical professional PDF PRO guard.')

    require('CombinedProfessionalPdfUiRuntimeBindings.bind' in main_source,
            'Combined UI runtime binding is not installed at startup.')
    require('CombinedProfessionalPdfUiRuntimeBindings.bindDelivery' in main_source,
            'Combined native-delivery UI binding is not installed at startup.')
    require('runtime.combinedProfessionalPdf' in main_source,
            'Startup binding must use the production combined application service.')
    require('runtime.combinedProfessionalPdfDelivery' in main_source,
            'Startup delivery binding must use the production combined delivery service.')

    required_action_constants = {
        'ACTION-PDF-COMBINED',
        'ACTION-PDF-COMBINED-PREVIEW',
        'ACTION-PDF-COMBINED-CREATE',
        'ACTION-PDF-COMBINED-SAVE',
        'ACTION-PDF-COMBINED-SHARE',
    }
    for action_id in required_action_constants:
        require(action_id in action_ids, f'Missing RuhActionIds value: {action_id}')
    require(required_action_constants.issubset(csv_ids(ACTION_EXTENSIONS)),
            'Combined PDF actions are missing from runtime action registry extensions.')
    require(required_action_constants.issubset(csv_ids(RUNTIME_BINDINGS)),
            'Combined PDF actions are missing from runtime action bindings.')

    for token in [
        "test('exact preview input can build and can be sealed for delivery'",
        "test('record change invalidates preview before build or delivery'",
        "test('locale and section changes invalidate preview'",
        'records outside selected subject cannot be toggled',
        'two records from the same calculation system cannot preview',
    ]:
        require(token in state_test, f'Missing combined selection regression: {token}')

    for token in [
        'multi-record preview uses accessible 48dp actions and sealed delivery token',
        'critical combined PDF controls survive 2.0x text scale',
        'RuhActionIds.pdfCombinedPreview',
        'RuhActionIds.pdfCombinedCreate',
        'RuhActionIds.pdfCombinedSave',
        'RuhActionIds.pdfCombinedShare',
        'same(preview)',
    ]:
        require(token in widget_test, f'Missing combined builder widget regression: {token}')

    for token in [
        'Free user cannot enter combined professional PDF route',
        'PRO user can enter combined professional PDF route',
        'Kombine PDF raporu PRO kullanıcılar içindir.',
        "'/pdf/combined'",
    ]:
        require(token in route_test, f'Missing combined route entitlement regression: {token}')

    for rel in evidence.get('sources', []) + evidence.get('tests', []) + evidence.get('validators', []):
        require((ROOT / rel).is_file(), f'Combined evidence path missing: {rel}')

    print('Combined PDF visible-route/UI selection/native-delivery contract: OK')


if __name__ == '__main__':
    main()
