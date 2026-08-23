#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
ADDENDUM = ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md'
EVIDENCE = ROOT / 'evidence/backup/application_service_contract.json'

EXPECTED = {
    773, 795, 823, 832, 838, 839, 840, 841, 1296, 1297, 1298, 1299,
}
KEYWORDS = {
    773: 'dışa aktarma sistemi',
    795: 'tüm Ruh Code verilerini tek yedek paketi',
    823: 'bozuk backup',
    832: 'önizleme gösterilecek',
    838: 'Birleştir',
    839: 'Mevcut veriyi değiştir',
    840: 'güvenlik snapshot',
    841: 'rollback',
    1296: 'Cihazlar arası veri transferi CSV backup',
    1297: 'eski telefondan export',
    1298: 'Yeni telefonda import',
    1299: 'internet sunucumuza ihtiyaç duymayacak',
}
FORBIDDEN = {794, 936, 937, 938}


def master_items() -> dict[int, str]:
    text = MASTER.read_text(encoding='utf-8') + '\n' + ADDENDUM.read_text(encoding='utf-8')
    items = {
        int(number): body.strip()
        for number, body in re.findall(r'^(\d+)\.\s+(.+)$', text, re.MULTILINE)
    }
    if set(items) != set(range(1, 1443)):
        raise AssertionError('MASTER sequence is not exactly RC-0001..RC-1442')
    return items


def main() -> None:
    items = master_items()
    for rc, keyword in KEYWORDS.items():
        body = items[rc]
        if keyword.casefold() not in body.casefold():
            raise AssertionError(
                f'RC-{rc:04d} MASTER ownership drift; missing {keyword!r}: {body}'
            )

    payload = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    raw = payload.get('requirements')
    if not isinstance(raw, list) or not raw:
        raise AssertionError('backup application-service evidence needs non-empty requirements[]')
    parsed = set()
    for token in raw:
        if not isinstance(token, str) or re.fullmatch(r'RC-\d{4}', token) is None:
            raise AssertionError(f'invalid RC token in backup application evidence: {token!r}')
        parsed.add(int(token[3:]))

    if parsed != EXPECTED:
        raise AssertionError(
            'backup application-service RC ownership mismatch; '
            f'missing={sorted(EXPECTED - parsed)} extra={sorted(parsed - EXPECTED)}'
        )
    leaked = parsed & FORBIDDEN
    if leaked:
        raise AssertionError(
            f'backup application service must not claim single-table/PDF delivery RCs: {sorted(leaked)}'
        )

    notes = '\n'.join(str(v) for v in payload.get('ownershipNotes', [])).casefold()
    for phrase in ('rc-0794', 'rc-0936/0937/0938'):
        if phrase not in notes:
            raise AssertionError(f'backup application evidence must document exclusion {phrase}')

    print('OK: backup application-service evidence owns only full-backup/preview/restore/device-transfer RCs')


if __name__ == '__main__':
    main()
