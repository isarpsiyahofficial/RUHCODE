#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
import argparse
import csv
import json
import os
import tempfile

FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']
LOCALES = ('tr', 'en')


class BatchAppendError(ValueError):
    pass


@dataclass(frozen=True)
class AppendSummary:
    start: str
    end: str
    records_per_locale: int
    total_records_after: int


def _read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != FIELDS:
            raise BatchAppendError(f'{path}: expected exact columns {FIELDS}, got {reader.fieldnames}')
        rows = [{field: (row[field] or '').strip() for field in FIELDS} for row in reader]
    return rows


def _parse_date(raw: str, *, context: str) -> date:
    try:
        return date.fromisoformat(raw)
    except ValueError as exc:
        raise BatchAppendError(f'{context}: invalid ISO date {raw!r}') from exc


def _validate_rows(rows: list[dict[str, str]], *, locale: str, year: int, context: str) -> list[date]:
    if not rows:
        raise BatchAppendError(f'{context}: batch must contain at least one row')
    parsed: list[date] = []
    seen: set[str] = set()
    for index, row in enumerate(rows, start=2):
        key = row['date']
        if not key or key in seen:
            raise BatchAppendError(f'{context}:{index}: blank or duplicate date {key!r}')
        seen.add(key)
        current = _parse_date(key, context=f'{context}:{index}')
        if current.year != year:
            raise BatchAppendError(f'{context}:{index}: date {key} does not match target year {year}')
        if row['locale'] != locale:
            raise BatchAppendError(f'{context}:{index}: locale {row["locale"]!r} must be {locale!r}')
        for field in FIELDS[2:]:
            if not row[field]:
                raise BatchAppendError(f'{context}:{index}: blank {field} for {key}|{locale}')
        parsed.append(current)
    for previous, current in zip(parsed, parsed[1:]):
        if current != previous + timedelta(days=1):
            raise BatchAppendError(f'{context}: batch dates are not contiguous at {previous} -> {current}')
    return parsed


def _render_csv(rows: list[dict[str, str]]) -> str:
    import io
    output = io.StringIO(newline='')
    writer = csv.DictWriter(output, fieldnames=FIELDS, lineterminator='\n', quoting=csv.QUOTE_MINIMAL)
    writer.writeheader()
    writer.writerows(rows)
    return output.getvalue()


def _atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f'.{path.name}.', suffix='.tmp', dir=path.parent)
    temp = Path(temp_name)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='') as handle:
            handle.write(text)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp, path)
    finally:
        if temp.exists():
            temp.unlink()


def append_paired_batch(
    *,
    shards_root: Path,
    evidence_path: Path,
    tr_batch: Path,
    en_batch: Path,
    year: int,
) -> AppendSummary:
    evidence = json.loads(evidence_path.read_text(encoding='utf-8'))
    if evidence.get('status') != 'EDITORIAL_IN_PROGRESS' or evidence.get('done') is not False:
        raise BatchAppendError('editorial evidence must be EDITORIAL_IN_PROGRESS and done=false')

    batches: dict[str, list[dict[str, str]]] = {
        'tr': _read_csv(tr_batch),
        'en': _read_csv(en_batch),
    }
    batch_dates = {
        locale: _validate_rows(rows, locale=locale, year=year, context=str(tr_batch if locale == 'tr' else en_batch))
        for locale, rows in batches.items()
    }
    if batch_dates['tr'] != batch_dates['en']:
        raise BatchAppendError('TR and EN editorial batches must cover the exact same dates')

    shard_rows: dict[str, list[dict[str, str]]] = {}
    for locale in LOCALES:
        shard = shards_root / locale / f'{year}.csv'
        current = _read_csv(shard)
        if not current:
            expected_start = batch_dates[locale][0]
        else:
            last = _parse_date(current[-1]['date'], context=str(shard))
            expected_start = last + timedelta(days=1)
        if batch_dates[locale][0] != expected_start:
            raise BatchAppendError(
                f'{locale}: batch must start immediately after committed coverage: '
                f'expected {expected_start}, got {batch_dates[locale][0]}'
            )
        existing_dates = {row['date'] for row in current}
        overlap = existing_dates.intersection(row['date'] for row in batches[locale])
        if overlap:
            raise BatchAppendError(f'{locale}: batch overlaps committed dates: {sorted(overlap)}')
        shard_rows[locale] = current + batches[locale]

    # Keep language tracks editorially independent at a minimum structural level.
    for tr_row, en_row in zip(batches['tr'], batches['en']):
        if tr_row['title'].casefold() == en_row['title'].casefold():
            raise BatchAppendError(f'{tr_row["date"]}: TR and EN titles are unexpectedly identical')
        if tr_row['full_text'].casefold() == en_row['full_text'].casefold():
            raise BatchAppendError(f'{tr_row["date"]}: TR and EN full text are unexpectedly identical')

    reviewed = evidence['currentReviewedCoverage']
    end = batch_dates['tr'][-1].isoformat()
    increment = len(batch_dates['tr'])
    for locale in LOCALES:
        ledger = reviewed[locale]
        if int(ledger['records']) != len(shard_rows[locale]) - increment:
            raise BatchAppendError(
                f'{locale}: evidence ledger count {ledger["records"]} does not match committed shard before append '
                f'{len(shard_rows[locale]) - increment}'
            )
        ledger['end'] = end
        ledger['records'] = len(shard_rows[locale])
    reviewed['totalRecords'] = len(shard_rows['tr']) + len(shard_rows['en'])

    # All validation happens before any replacement. Preserve originals for rollback on write failure.
    targets = {
        shards_root / 'tr' / f'{year}.csv': _render_csv(shard_rows['tr']),
        shards_root / 'en' / f'{year}.csv': _render_csv(shard_rows['en']),
        evidence_path: json.dumps(evidence, ensure_ascii=False, indent=2) + '\n',
    }
    originals = {path: path.read_text(encoding='utf-8') for path in targets}
    written: list[Path] = []
    try:
        for path, text in targets.items():
            _atomic_write_text(path, text)
            written.append(path)
    except Exception:
        for path in reversed(written):
            _atomic_write_text(path, originals[path])
        raise

    return AppendSummary(
        start=batch_dates['tr'][0].isoformat(),
        end=end,
        records_per_locale=increment,
        total_records_after=int(reviewed['totalRecords']),
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description='Safely append one paired TR+EN editorial batch to Ruh Code year shards.')
    result.add_argument('--shards-root', type=Path, default=Path('assets/content/daily_messages'))
    result.add_argument('--evidence', type=Path, default=Path('evidence/content/daily_messages_editorial_progress.json'))
    result.add_argument('--tr-batch', type=Path, required=True)
    result.add_argument('--en-batch', type=Path, required=True)
    result.add_argument('--year', type=int, required=True)
    return result


if __name__ == '__main__':
    args = parser().parse_args()
    summary = append_paired_batch(
        shards_root=args.shards_root,
        evidence_path=args.evidence,
        tr_batch=args.tr_batch,
        en_batch=args.en_batch,
        year=args.year,
    )
    print(json.dumps(summary.__dict__, ensure_ascii=False, indent=2, sort_keys=True))
