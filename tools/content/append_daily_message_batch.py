#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
import argparse
import csv
import io
import json
import os
import re
import sys
import tempfile

TOOLS = Path(__file__).resolve().parent
if str(TOOLS) not in sys.path:
    sys.path.insert(0, str(TOOLS))

from daily_message_schema import CANONICAL_FIELDS, DailyMessageSchemaError, read_canonical_batch, read_shard_rows

FIELDS = CANONICAL_FIELDS
LOCALES = ('tr', 'en')
SHARD_FILE = re.compile(r'^(\d{4})(?:-(\d{2}))?\.csv$')


class BatchAppendError(ValueError):
    pass


@dataclass(frozen=True)
class AppendSummary:
    start: str
    end: str
    records_per_locale: int
    total_records_after: int
    target_shards: tuple[str, str]


def _read_batch(path: Path, *, locale: str) -> list[dict[str, str]]:
    try:
        return read_canonical_batch(path, expected_locale=locale)
    except DailyMessageSchemaError as exc:
        raise BatchAppendError(str(exc)) from exc


def _read_committed_shard(path: Path, *, locale: str) -> list[dict[str, str]]:
    try:
        rows, _schema = read_shard_rows(path, expected_locale=locale, allow_legacy=True)
        return rows
    except DailyMessageSchemaError as exc:
        raise BatchAppendError(str(exc)) from exc


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
    if any(item.month != parsed[0].month for item in parsed):
        raise BatchAppendError(f'{context}: one append batch must stay inside one calendar month')
    return parsed


def _read_all_locale_rows(folder: Path, *, locale: str) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    seen: set[str] = set()
    for path in sorted(folder.glob('*.csv')):
        match = SHARD_FILE.fullmatch(path.name)
        if match is None:
            raise BatchAppendError(f'unexpected shard name: {path}')
        year = int(match.group(1))
        month = int(match.group(2)) if match.group(2) else None
        if month is not None and not 1 <= month <= 12:
            raise BatchAppendError(f'invalid shard month: {path}')
        for row in _read_committed_shard(path, locale=locale):
            parsed = _parse_date(row['date'], context=str(path))
            if parsed.year != year or (month is not None and parsed.month != month):
                raise BatchAppendError(f'{path}: date {parsed} does not match shard period')
            if row['date'] in seen:
                raise BatchAppendError(f'{locale}: duplicate committed date across shards: {row["date"]}')
            seen.add(row['date'])
            rows.append(row)
    rows.sort(key=lambda item: item['date'])
    return rows


def _render_csv(rows: list[dict[str, str]]) -> str:
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

    batches = {'tr': _read_batch(tr_batch, locale='tr'), 'en': _read_batch(en_batch, locale='en')}
    batch_dates = {
        locale: _validate_rows(
            rows,
            locale=locale,
            year=year,
            context=str(tr_batch if locale == 'tr' else en_batch),
        )
        for locale, rows in batches.items()
    }
    if batch_dates['tr'] != batch_dates['en']:
        raise BatchAppendError('TR and EN editorial batches must cover the exact same dates')

    month = batch_dates['tr'][0].month
    committed: dict[str, list[dict[str, str]]] = {}
    target_paths: dict[str, Path] = {}
    target_rows: dict[str, list[dict[str, str]]] = {}

    for locale in LOCALES:
        folder = shards_root / locale
        current_all = _read_all_locale_rows(folder, locale=locale)
        committed[locale] = current_all
        expected_start = batch_dates[locale][0] if not current_all else _parse_date(
            current_all[-1]['date'], context=f'{locale} committed coverage'
        ) + timedelta(days=1)
        if batch_dates[locale][0] != expected_start:
            raise BatchAppendError(
                f'{locale}: batch must start immediately after committed coverage: '
                f'expected {expected_start}, got {batch_dates[locale][0]}'
            )
        existing_dates = {row['date'] for row in current_all}
        overlap = existing_dates.intersection(row['date'] for row in batches[locale])
        if overlap:
            raise BatchAppendError(f'{locale}: batch overlaps committed dates: {sorted(overlap)}')

        target = folder / f'{year:04d}-{month:02d}.csv'
        target_paths[locale] = target
        current_target = _read_committed_shard(target, locale=locale) if target.exists() else []
        target_rows[locale] = current_target + batches[locale]

    for tr_row, en_row in zip(batches['tr'], batches['en']):
        if tr_row['title'].casefold() == en_row['title'].casefold():
            raise BatchAppendError(f'{tr_row["date"]}: TR and EN titles are unexpectedly identical')
        if tr_row['full_text'].casefold() == en_row['full_text'].casefold():
            raise BatchAppendError(f'{tr_row["date"]}: TR and EN full text are unexpectedly identical')

    reviewed = evidence['currentReviewedCoverage']
    end = batch_dates['tr'][-1].isoformat()
    increment = len(batch_dates['tr'])
    new_counts: dict[str, int] = {}
    for locale in LOCALES:
        ledger = reviewed[locale]
        if int(ledger['records']) != len(committed[locale]):
            raise BatchAppendError(
                f'{locale}: evidence ledger count {ledger["records"]} does not match committed shard rows '
                f'{len(committed[locale])}'
            )
        new_counts[locale] = len(committed[locale]) + increment
        ledger['end'] = end
        ledger['records'] = new_counts[locale]
    reviewed['totalRecords'] = new_counts['tr'] + new_counts['en']

    targets: dict[Path, str] = {
        target_paths['tr']: _render_csv(target_rows['tr']),
        target_paths['en']: _render_csv(target_rows['en']),
        evidence_path: json.dumps(evidence, ensure_ascii=False, indent=2) + '\n',
    }
    originals: dict[Path, str | None] = {
        path: path.read_text(encoding='utf-8') if path.exists() else None for path in targets
    }
    written: list[Path] = []
    try:
        for path, text in targets.items():
            _atomic_write_text(path, text)
            written.append(path)
    except Exception:
        for path in reversed(written):
            original = originals[path]
            if original is None:
                path.unlink(missing_ok=True)
            else:
                _atomic_write_text(path, original)
        raise

    return AppendSummary(
        start=batch_dates['tr'][0].isoformat(),
        end=end,
        records_per_locale=increment,
        total_records_after=int(reviewed['totalRecords']),
        target_shards=(target_paths['tr'].as_posix(), target_paths['en'].as_posix()),
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description='Safely append one paired TR+EN editorial batch to Ruh Code monthly shards.')
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
