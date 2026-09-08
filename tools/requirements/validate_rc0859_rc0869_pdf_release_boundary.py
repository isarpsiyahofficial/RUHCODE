from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0859_rc0869_pdf_release_boundary_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PDF_DIR = ROOT / 'lib/src/pdf'


def fail(message: str) -> None:
    raise SystemExit(f'RC0859_RC0869_FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    master = MASTER.read_text(encoding='utf-8')

    requirements = contract.get('requirements', {})
    expected = {f'RC-{i:04d}' for i in range(859, 870)}
    if set(requirements) != expected:
        fail(f'contract ids mismatch: {sorted(set(requirements) ^ expected)}')
    for rc_id, text in requirements.items():
        number = int(rc_id.split('-')[1])
        if f'{number}. {text}' not in master:
            fail(f'{rc_id} text does not exactly match binding specification')

    for relative in contract.get('evidence', []):
        if not (ROOT / relative).exists():
            fail(f'missing evidence path: {relative}')

    boundary = (PDF_DIR / 'pdf_release_boundary.dart').read_text(encoding='utf-8')
    service = (PDF_DIR / 'pdf_local_service.dart').read_text(encoding='utf-8')
    renderer = (PDF_DIR / 'pdf_local_renderer.dart').read_text(encoding='utf-8')
    fonts = (PDF_DIR / 'pdf_asset_font_provider.dart').read_text(encoding='utf-8')

    required_boundary_tokens = [
        'onDeviceOnly = true',
        'sendsPersonalDataOffDevice = false',
        'recomputesCalculations = false',
        'capturesApplicationScreens = false',
        'usesLowResolutionChartJpeg = false',
        'Professional PDF v1 must use real A4 document geometry.',
    ]
    for token in required_boundary_tokens:
        if token not in boundary:
            fail(f'missing release-boundary token: {token}')

    if 'releaseBoundary.validate(plan: plan);' not in service:
        fail('PdfLocalReportService does not enforce PdfReleaseBoundary')
    if "import 'package:pdf/widgets.dart' as pw;" not in renderer:
        fail('dedicated PDF layout renderer is missing')
    if 'pw.MultiPage(' not in renderer or 'PdfPageFormat(' not in renderer:
        fail('real document layout/pagination is not wired')
    if 'pw.Font.ttf' not in renderer:
        fail('embedded TrueType font rendering is not wired')
    if "const <String>{'tr', 'en'}" not in fonts:
        fail('TR/EN font bundle coverage is not enforced')

    forbidden_import_tokens = (
        "package:http/",
        "package:dio/",
        "package:firebase_",
        "package:supabase",
        "package:screenshot/",
    )
    for path in PDF_DIR.rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        for token in forbidden_import_tokens:
            if token in text:
                fail(f'forbidden PDF dependency {token} in {path.relative_to(ROOT)}')

    if 'screenshot' in renderer.lower() or '.jpg' in renderer.lower() or '.jpeg' in renderer.lower():
        fail('renderer contains screenshot/JPEG report rendering path')

    print('RC0859_RC0869_OK')


if __name__ == '__main__':
    main()
