from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0890_rc0894_pdf_metadata_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def fail(message: str) -> None:
    raise SystemExit(f'RC0890_RC0894_FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    master = MASTER.read_text(encoding='utf-8')
    requirements = contract.get('requirements', {})
    expected = {f'RC-{i:04d}' for i in range(890, 895)}
    if set(requirements) != expected:
        fail(f'contract ids mismatch: {sorted(set(requirements) ^ expected)}')
    for rc_id, text in requirements.items():
        number = int(rc_id.split('-')[1])
        if f'{number}. {text}' not in master:
            fail(f'{rc_id} text does not exactly match binding specification')
    for relative in contract.get('evidence', []):
        if not (ROOT / relative).exists():
            fail(f'missing evidence path: {relative}')

    service_contract = (ROOT / 'lib/src/pdf/pdf_service.dart').read_text(encoding='utf-8')
    local_service = (ROOT / 'lib/src/pdf/pdf_local_service.dart').read_text(encoding='utf-8')
    renderer = (ROOT / 'lib/src/pdf/pdf_local_renderer.dart').read_text(encoding='utf-8')

    for token in ('subjectName', 'professionalName', 'brandName', 'generatedAtUtc'):
        if token not in service_contract:
            fail(f'missing PDF option: {token}')
    for token in ('subjectName: options.subjectName', 'generatedAtUtc: options.generatedAtUtc'):
        if token not in local_service:
            fail(f'metadata not passed to renderer: {token}')
    for token in (
        "'${context.pageNumber} / ${context.pagesCount}'",
        '_generatedDateLabel(payload)',
        "payload.subjectName!.trim()",
        'payload.plan.branding.professionalName',
        'payload.plan.branding.brandName',
    ):
        if token not in renderer:
            fail(f'missing rendered PDF metadata token: {token}')

    print('RC0890_RC0894_OK')


if __name__ == '__main__':
    main()
