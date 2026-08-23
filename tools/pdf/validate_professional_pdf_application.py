#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SERVICE = ROOT / 'lib/src/pdf/professional_pdf_application_service.dart'
PERSISTED_SOURCE = ROOT / 'lib/src/pdf/persisted_calculation_pdf_source.dart'
ROUTER = ROOT / 'lib/src/pdf/persisted_calculation_pdf_router.dart'
DELIVERY = ROOT / 'lib/src/pdf/professional_pdf_delivery_service.dart'
PLATFORM = ROOT / 'lib/src/pdf/pdf_platform_gateway.dart'
RUNTIME = ROOT / 'lib/src/app/app_runtime.dart'
MAIN = ROOT / 'lib/main.dart'
GUARD = ROOT / 'lib/src/pdf/guarded_pdf_service.dart'
UI_ACTIONS = ROOT / 'lib/src/ui/pdf/professional_pdf_ui_actions.dart'
UI_PAGE = ROOT / 'lib/src/ui/pdf/pdf_reports_pages.dart'
ACTION_IDS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'
RUNTIME_BINDINGS = ROOT / 'ui/runtime_action_bindings.csv'
TEST = ROOT / 'test/pdf/professional_pdf_application_service_test.dart'
SOURCE_TEST = ROOT / 'test/pdf/persisted_calculation_pdf_source_test.dart'
ROUTER_TEST = ROOT / 'test/pdf/persisted_calculation_pdf_router_test.dart'
DELIVERY_TEST = ROOT / 'test/pdf/professional_pdf_delivery_service_test.dart'
WIDGET_TEST = ROOT / 'test/ui/professional_pdf_builder_page_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/professional_application_service.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    required_paths = (
        SERVICE, PERSISTED_SOURCE, ROUTER, DELIVERY, PLATFORM, RUNTIME, MAIN,
        GUARD, UI_ACTIONS, UI_PAGE, ACTION_IDS, RUNTIME_BINDINGS, TEST,
        SOURCE_TEST, ROUTER_TEST, DELIVERY_TEST, WIDGET_TEST, EVIDENCE, MASTER,
    )
    for path in required_paths:
        require(path.exists(), f'missing required file: {path.relative_to(ROOT)}')

    service = SERVICE.read_text(encoding='utf-8')
    persisted = PERSISTED_SOURCE.read_text(encoding='utf-8')
    router = ROUTER.read_text(encoding='utf-8')
    delivery = DELIVERY.read_text(encoding='utf-8')
    platform = PLATFORM.read_text(encoding='utf-8')
    runtime = RUNTIME.read_text(encoding='utf-8')
    main_source = MAIN.read_text(encoding='utf-8')
    guard = GUARD.read_text(encoding='utf-8')
    ui_actions = UI_ACTIONS.read_text(encoding='utf-8')
    ui_page = UI_PAGE.read_text(encoding='utf-8')
    action_ids = ACTION_IDS.read_text(encoding='utf-8')
    runtime_bindings = RUNTIME_BINDINGS.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    source_test = SOURCE_TEST.read_text(encoding='utf-8')
    router_test = ROUTER_TEST.read_text(encoding='utf-8')
    delivery_test = DELIVERY_TEST.read_text(encoding='utf-8')
    widget_test = WIDGET_TEST.read_text(encoding='utf-8')
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    master = MASTER.read_text(encoding='utf-8')

    for marker in (
        'ProfessionalPdfSnapshotSource', 'ProfessionalPdfApplicationService',
        'GuardedProfessionalPdfService', 'outputInspector.requireUsable',
        "languageCode != 'tr' && languageCode != 'en'",
        'Duplicate PDF section ID', 'Calculation record not found',
    ):
        require(marker in service, f'missing professional PDF service marker: {marker}')

    for marker in (
        'LocalDatabaseProfessionalPdfSnapshotSource',
        "table: 'calculations'", "table: 'calculation_manifests'",
        'CoreModelCodecs.calculationManifestFromMap',
        'CalculationValidity.unavailable', 'CalculationValidity.error',
        'ProfessionalPdfRecordCatalog', 'listAvailableRecords',
    ):
        require(marker in persisted, f'missing persisted PDF source marker: {marker}')

    require(
        'LocalDatabaseProfessionalPdfSnapshotSource(database: database)' in runtime,
        'runtime must compose the production persisted PDF source',
    )
    require(
        'professionalPdfSnapshotSource' in runtime,
        'runtime must expose the persisted PDF source for application composition',
    )

    for marker in (
        'PersistedCalculationPdfRouter', 'supportedCalculationTypes',
        'No professional PDF handler is registered for calculation type',
        'Duplicate professional PDF handler',
    ):
        require(marker in router, f'missing persisted PDF router marker: {marker}')

    for marker in (
        'ProfessionalPdfDeliveryService', 'platformGateway.savePdf',
        'platformGateway.sharePdf', 'ProfessionalPdfDeliveryStatus.cancelled',
        'ProfessionalPdfDeliveryStatus.unavailable',
    ):
        require(marker in delivery, f'missing professional PDF delivery marker: {marker}')

    for marker in (
        'NativePdfPlatformGateway', 'FilePicker.saveFile',
        'SharePlus.instance.share', "kRuhCodePdfMimeType = 'application/pdf'",
        "trimmed.contains('/')", "trimmed.contains('\\\\')",
    ):
        require(marker in platform, f'missing native PDF platform marker: {marker}')
    require('http' not in platform.lower(), 'native PDF platform gateway must not contain HTTP/server delivery code')

    require('RuhFeatureIds.pdfProfessionalExport' in guard, 'professional PDF guard must use canonical feature ID')
    require('runService<List<int>>' in guard, 'professional PDF delegate must execute through service guard')

    for marker in (
        'ProfessionalPdfBuildActions', 'ProfessionalPdfApplicationActions',
        'ProfessionalPdfDeliveryActions', 'ProfessionalPdfDeliveryUiActions',
        'ProfessionalPdfRecordActions', 'ProfessionalPdfCatalogActions',
        'ProfessionalPdfUiRuntimeBindings', 'service.build(', 'service.share(',
        'ProfessionalPdfUiDeliveryOutcome.cancelled',
    ):
        require(marker in ui_actions, f'missing PDF UI action adapter marker: {marker}')

    require(
        'ProfessionalPdfUiRuntimeBindings.bindRecords' in main_source and
        'runtime.professionalPdfSnapshotSource' in main_source,
        'main must bind the production persisted PDF catalog to the UI boundary',
    )

    require("static const pdfPreflight = 'ACTION-PDF-BUILDER-PREVIEW';" in action_ids, 'canonical PDF preflight action ID is missing')
    require("static const pdfCreate = 'ACTION-PDF-BUILDER-CREATE';" in action_ids, 'canonical PDF builder create action ID is missing')
    require("static const pdfShare = 'ACTION-PDF-BUILDER-SHARE';" in action_ids, 'canonical PDF builder share action ID is missing')
    require('ValueKey(RuhActionIds.pdfPreflight)' in ui_page, 'professional builder preflight control must use canonical action ID')
    require('ValueKey(RuhActionIds.pdfCreate)' in ui_page, 'professional builder create control must use canonical action ID')
    require('ValueKey(RuhActionIds.pdfShare)' in ui_page, 'professional builder share control must use canonical action ID')
    require('ProfessionalPdfBuilderPage(' in ui_page and 'records: professionalRecords' in ui_page, 'PDF hub must pass explicit record actions when supplied')
    require('ProfessionalPdfUiRuntimeBindings.records' in ui_page, 'builder must fall back to the production runtime record catalog')
    require('ProfessionalPdfUiRuntimeBindings.build' in ui_page, 'builder must support trusted runtime build binding')
    require('ProfessionalPdfUiRuntimeBindings.delivery' in ui_page, 'builder must support trusted runtime delivery binding')
    require("ValueKey('professional-pdf-record-selector')" in ui_page, 'typed saved-calculation selector is missing')
    require('Kayıt kimliği' not in ui_page, 'raw record ID input must not return to professional PDF builder')
    require('PDF üretim kaynağı henüz production runtime’a bağlanmadı.' in ui_page, 'builder must fail honestly when production build actions are absent')
    require("ProfessionalPdfUiDeliveryOutcome.cancelled => 'Paylaşım iptal edildi.'" in ui_page, 'share dismissal must remain a normal UI cancellation state')

    for marker in (
        'ACTION-PDF-BUILDER-PREVIEW,pdfPreflight',
        'ACTION-PDF-BUILDER-CREATE,pdfCreate',
        'ACTION-PDF-BUILDER-SHARE,pdfShare',
    ):
        require(marker in runtime_bindings, f'missing canonical runtime PDF binding: {marker}')

    for marker in (
        'FREE user cannot execute professional PDF delegate',
        'PRO build loads exact record, preserves section order and inspects PDF',
        'expect(delegate.calls, 0)', 'result.inspection.structurallyUsable',
    ):
        require(marker in test, f'missing professional PDF regression marker: {marker}')

    for marker in (
        'loads calculation and manifest atomically', 'missing manifest fails closed',
        'unavailable calculation cannot become professional PDF input',
        'catalog is typed, deterministic and newest first',
    ):
        require(marker in source_test, f'missing persisted source regression marker: {marker}')

    for marker in (
        'routes exact calculation type to exactly one registered service',
        'unknown calculation type fails closed instead of reusing another handler',
        'duplicate handler registration is rejected',
        'empty handler registry is rejected',
    ):
        require(marker in router_test, f'missing persisted PDF router regression marker: {marker}')

    for marker in (
        'PDF platform policy rejects path injection and non-PDF bytes',
        'save cancellation remains a normal result after validated build',
        'dismissed share is cancellation, unavailable is explicit',
    ):
        require(marker in delivery_test, f'missing PDF delivery regression marker: {marker}')

    for marker in (
        'builder invokes application actions with typed selected record and section order',
        'verified PDF exposes canonical share action when delivery is bound',
        'dismissed PDF share is a normal cancellation state',
        'builder never fakes output when production build actions are absent',
        'builder does not expose raw record ID field',
        'professional-pdf-record-selector', 'RuhActionIds.pdfPreflight',
        'RuhActionIds.pdfCreate', 'RuhActionIds.pdfShare',
        "expect(find.text('PDF doğrulandı'), findsNothing)",
    ):
        require(marker in widget_test, f'missing professional PDF widget regression marker: {marker}')

    expected_rc = {
        'RC-0918', 'RC-0936', 'RC-0939', 'RC-0940',
        'RC-0950', 'RC-0951', 'RC-0953', 'RC-0964',
        'RC-1085', 'RC-1086', 'RC-1088', 'RC-1089',
    }
    actual_rc = set(evidence.get('requirement_ids', []))
    require(actual_rc == expected_rc, f'evidence RC ownership mismatch: {sorted(actual_rc)}')
    require(evidence.get('done') is False, 'source-level evidence must remain done=false until production/CI proof exists')

    not_yet = '\n'.join(evidence.get('not_yet_proven', []))
    require('RC-0952' in not_yet, 'RC-0952 full-parser/open proof must remain explicitly open')

    master_markers = {
        'RC-0918': '918. Profesyonel istediği rapor bölümlerini açıp kapatabilecek.',
        'RC-0936': '936. Kullanıcı paylaşım menüsünden PDF gönderebilecek.',
        'RC-0939': '939. PDF cihazın dosyalar alanına kaydedilebilecek.',
        'RC-0940': '940. Bu paylaşım işlemleri bizim sunucumuzdan geçmeyecek.',
        'RC-0950': '950. PDF üretimi tamamlanmadıysa yarım dosya başarılı rapor olarak gösterilmeyecek.',
        'RC-0951': '951. PDF doğrulama testi oluşturulacak.',
        'RC-0953': '953. Sayfa sayısının sıfır olmadığı kontrol edilecek.',
        'RC-0964': '964. Yanlış müşteri verisinin başka raporda çıkması kritik güvenlik hatası kabul edilecek.',
        'RC-1085': '1085. Ücretsiz ve PRO erişim matrisi merkezi bir entitlement sistemiyle yönetilecek.',
        'RC-1086': '1086. Her özellik kod seviyesinde tek bir Feature ID taşıyacak.',
        'RC-1088': '1088. UI kilidi Feature ID’ye bakacak.',
        'RC-1089': '1089. Hesaplama servisi Feature ID’ye bakabilecek.',
    }
    for rc, marker in master_markers.items():
        require(marker in master, f'{rc} semantic ownership marker missing from MASTER')

    print('professional PDF application contract: OK')


if __name__ == '__main__':
    main()
