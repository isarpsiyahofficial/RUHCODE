#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SERVICE = ROOT / 'lib/src/pdf/professional_pdf_application_service.dart'
GUARD = ROOT / 'lib/src/pdf/guarded_pdf_service.dart'
TEST = ROOT / 'test/pdf/professional_pdf_application_service_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/professional_application_service.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (SERVICE, GUARD, TEST, EVIDENCE, MASTER):
        require(path.exists(), f'missing required file: {path.relative_to(ROOT)}')

    service = SERVICE.read_text(encoding='utf-8')
    guard = GUARD.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    master = MASTER.read_text(encoding='utf-8')

    for marker in (
        'ProfessionalPdfSnapshotSource',
        'ProfessionalPdfApplicationService',
        'GuardedProfessionalPdfService',
        'outputInspector.requireUsable',
        "languageCode != 'tr' && languageCode != 'en'",
        'Duplicate PDF section ID',
        'Calculation record not found',
    ):
        require(marker in service, f'missing professional PDF service marker: {marker}')

    require('RuhFeatureIds.pdfProfessionalExport' in guard, 'professional PDF guard must use canonical feature ID')
    require('runService<List<int>>' in guard, 'professional PDF delegate must execute through service guard')

    for marker in (
        'FREE user cannot execute professional PDF delegate',
        'PRO build loads exact record, preserves section order and inspects PDF',
        'expect(delegate.calls, 0)',
        'result.inspection.structurallyUsable',
    ):
        require(marker in test, f'missing professional PDF regression marker: {marker}')

    expected_rc = {
        'RC-0918', 'RC-0950', 'RC-0951', 'RC-0952', 'RC-0953', 'RC-0964',
        'RC-1085', 'RC-1086', 'RC-1088', 'RC-1089',
    }
    actual_rc = set(evidence.get('requirement_ids', []))
    require(actual_rc == expected_rc, f'evidence RC ownership mismatch: {sorted(actual_rc)}')
    require(evidence.get('done') is False, 'source-level evidence must remain done=false until production/CI proof exists')

    master_markers = {
        'RC-0918': '918. Profesyonel istediği rapor bölümlerini açıp kapatabilecek.',
        'RC-0950': '950. PDF üretimi tamamlanmadıysa yarım dosya başarılı rapor olarak gösterilmeyecek.',
        'RC-0951': '951. PDF doğrulama testi oluşturulacak.',
        'RC-0952': '952. Oluşan PDF’nin gerçekten açılabildiği otomatik kontrol edilecek.',
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
