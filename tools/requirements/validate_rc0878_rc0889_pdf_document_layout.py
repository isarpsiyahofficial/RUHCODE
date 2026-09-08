from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0878_rc0889_pdf_document_layout_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def fail(message: str) -> None:
    raise SystemExit(f'RC0878_RC0889_FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    master = MASTER.read_text(encoding='utf-8')
    requirements = contract.get('requirements', {})
    expected = {f'RC-{i:04d}' for i in range(878, 890)}
    if set(requirements) != expected:
        fail(f'contract ids mismatch: {sorted(set(requirements) ^ expected)}')
    for rc_id, text in requirements.items():
        number = int(rc_id.split('-')[1])
        if f'{number}. {text}' not in master:
            fail(f'{rc_id} text does not exactly match binding specification')
    for relative in contract.get('evidence', []):
        if not (ROOT / relative).exists():
            fail(f'missing evidence path: {relative}')

    safety = (ROOT / 'lib/src/pdf/pdf_document_layout_safety.dart').read_text(encoding='utf-8')
    renderer = (ROOT / 'lib/src/pdf/pdf_local_renderer.dart').read_text(encoding='utf-8')
    table = (ROOT / 'lib/src/pdf/pdf_table_layout.dart').read_text(encoding='utf-8')
    service = (ROOT / 'lib/src/pdf/pdf_local_service.dart').read_text(encoding='utf-8')

    for token in (
        'minimumSafeMarginMm = 12',
        'PdfPageSpec.a4.widthMm',
        'PdfPageSpec.a4.heightMm',
        'preserveWrappingText',
    ):
        if token not in safety:
            fail(f'missing layout safety token: {token}')
    if 'layoutSafety.validate(plan);' not in service:
        fail('local PDF service does not enforce document layout safety')
    if 'pw.Inseparable(' not in renderer:
        fail('heading/first-paragraph keep-together protection is missing')
    if 'pw.NewPage(freeSpace: sectionKeepTogetherFreeSpacePt)' not in renderer:
        fail('controlled section pagination is missing')
    if 'maxBodyRowsPerChunk = 24' not in table or 'List<PdfTableChunk>' not in table:
        fail('bounded table pagination/chunking is missing')

    print('RC0878_RC0889_OK')


if __name__ == '__main__':
    main()
