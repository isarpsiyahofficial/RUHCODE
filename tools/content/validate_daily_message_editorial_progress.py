#!/usr/bin/env python3
from __future__ import annotations

from datetime import date, timedelta
from pathlib import Path
import csv
import json

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'requirements/content_manifests/daily_messages.json'
EVIDENCE = ROOT / 'evidence/content/daily_messages_editorial_progress.json'
SHARDS = ROOT / 'assets/content/daily_messages'
FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def parse_iso(raw: str) -> date:
    try:
        return date.fromisoformat(raw)
    except ValueError as exc:
        raise SystemExit(f'invalid ISO date {raw!r}: {exc}') from exc


def read_locale_rows(locale: str) -> list[dict[str, str]]:
    folder = SHARDS / locale
    require(folder.is_dir(), f'missing daily-message locale directory: {folder.relative_to(ROOT)}')
    rows: list[dict[str, str]] = []
    seen: set[str] = set()
    for path in sorted(folder.glob('*.csv')):
        with path.open(encoding='utf-8', newline='') as handle:
            reader = csv.DictReader(handle)
            require(reader.fieldnames == FIELDS,
                    f'{path.relative_to(ROOT)} must use exact columns {FIELDS}, got {reader.fieldnames}')
            for line, row in enumerate(reader, start=2):
                require(row['locale'].strip() == locale,
                        f'{path.relative_to(ROOT)}:{line} locale mismatch: {row["locale"]!r}')
                key = row['date'].strip()
                require(key not in seen, f'duplicate {locale} editorial date: {key}')
                seen.add(key)
                parsed = parse_iso(key)
                require(path.stem == f'{parsed.year:04d}',
                        f'{path.relative_to(ROOT)}:{line} date/year shard mismatch: {key}')
                for field in FIELDS[2:]:
                    require(row[field].strip(),
                            f'{path.relative_to(ROOT)}:{line} blank {field} for {key}|{locale}')
                rows.append(row)
    rows.sort(key=lambda item: item['date'])
    return rows


def expected_contiguous(start: date, end: date) -> list[str]:
    values: list[str] = []
    current = start
    while current <= end:
        values.append(current.isoformat())
        current += timedelta(days=1)
    return values


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))

    require(evidence.get('status') == 'EDITORIAL_IN_PROGRESS',
            'daily-message progress evidence must remain EDITORIAL_IN_PROGRESS before complete release audit')
    require(evidence.get('done') is False,
            'daily-message editorial progress evidence cannot be DONE before all 8,036 records pass strict release audit')
    require(manifest.get('status') == 'EDITORIAL_CONTENT_IN_PROGRESS',
            'manifest must remain EDITORIAL_CONTENT_IN_PROGRESS while editorial ledger is partial')
    require(manifest.get('locales') == ['tr', 'en'], 'daily-message locale contract drifted')

    start = parse_iso(manifest['initial_coverage_start'])
    final_end = parse_iso(manifest['initial_coverage_end'])
    reviewed = evidence['currentReviewedCoverage']
    total = 0

    for locale in manifest['locales']:
        rows = read_locale_rows(locale)
        ledger = reviewed[locale]
        ledger_start = parse_iso(ledger['start'])
        ledger_end = parse_iso(ledger['end'])
        ledger_count = int(ledger['records'])

        require(ledger_start == start,
                f'{locale} editorial ledger must begin at manifest start {start.isoformat()}')
        require(start <= ledger_end <= final_end,
                f'{locale} editorial ledger end is outside manifest range: {ledger_end}')
        require(len(rows) == ledger_count,
                f'{locale} evidence count {ledger_count} does not match shard rows {len(rows)}')
        require(rows, f'{locale} editorial shard set is unexpectedly empty')
        require(rows[0]['date'] == ledger_start.isoformat(),
                f'{locale} first shard date does not match evidence start')
        require(rows[-1]['date'] == ledger_end.isoformat(),
                f'{locale} last shard date does not match evidence end')

        actual_dates = [row['date'] for row in rows]
        expected_dates = expected_contiguous(ledger_start, ledger_end)
        require(actual_dates == expected_dates,
                f'{locale} editorial coverage is not contiguous from {ledger_start} through {ledger_end}')
        total += len(rows)

    require(total == int(reviewed['totalRecords']),
            f'evidence totalRecords {reviewed["totalRecords"]} does not match shard total {total}')
    require(total < int(manifest['initial_total_records']),
            'partial editorial progress validator must not be used to certify a complete release catalog')

    remaining = int(manifest['initial_total_records']) - total
    print(
        'daily-message editorial progress OK: '
        f'{total}/{manifest["initial_total_records"]} records are contiguous and ledger-backed; '
        f'{remaining} remain before strict release completeness'
    )


if __name__ == '__main__':
    main()
