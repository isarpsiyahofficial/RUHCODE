#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
ADDENDUM = ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md'
EVIDENCE = ROOT / 'evidence/backup/native_share_transport_contract.json'


def master_items() -> dict[int, str]:
    text = MASTER.read_text(encoding='utf-8') + '\n' + ADDENDUM.read_text(encoding='utf-8')
    return {int(number): body.strip() for number, body in re.findall(r'^(\d+)\.\s+(.+)$', text, re.MULTILINE)}


items = master_items()
expected_keywords = {
    1300: ('backup dosyasını', 'Google Drive/iCloud/USB/e-posta'),
    1301: ('dış depolama servislerini', 'yönetmek zorunda olmayacak'),
}
for rc, keywords in expected_keywords.items():
    body = items.get(rc)
    if body is None:
        raise AssertionError(f'RC-{rc:04d} missing from MASTER')
    for keyword in keywords:
        if keyword.casefold() not in body.casefold():
            raise AssertionError(
                f'RC-{rc:04d} MASTER ownership drift: missing {keyword!r}: {body}'
            )

payload = json.loads(EVIDENCE.read_text(encoding='utf-8'))
actual = set(payload.get('requirements', []))
expected = {'RC-1300', 'RC-1301'}
if actual != expected:
    raise AssertionError(
        f'{EVIDENCE.relative_to(ROOT)} must own exact {sorted(expected)}; got {sorted(actual)}'
    )

print('OK: native backup transport evidence retains exact MASTER RC-1300/RC-1301 ownership')
