#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from datetime import date, timedelta
from difflib import SequenceMatcher
from pathlib import Path
import argparse
import csv
import hashlib
import json
import re
import sys

REQUIRED_COLUMNS = {'date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag'}
ISO_DATE = re.compile(r'^\d{4}-\d{2}-\d{2}$')


def date_range(start: date, end: date):
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


def normalized_text(value: str) -> str:
    return ' '.join(value.casefold().split())


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def load_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        fields = set(reader.fieldnames or [])
        if fields != REQUIRED_COLUMNS:
            raise ValueError(f'Expected columns {sorted(REQUIRED_COLUMNS)}, got {sorted(fields)}')
        return list(reader)


def audit(path: Path, manifest_path: Path) -> dict[str, object]:
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    start = date.fromisoformat(manifest['initial_coverage_start'])
    end = date.fromisoformat(manifest['initial_coverage_end'])
    locales = tuple(manifest['locales'])
    expected_dates = [item.isoformat() for item in date_range(start, end)]
    expected_keys = {f'{day}|{locale}' for day in expected_dates for locale in locales}

    rows = load_rows(path)
    keys: list[str] = []
    exact_texts: Counter[str] = Counter()
    opening_patterns: Counter[str] = Counter()
    errors: list[str] = []

    for index, row in enumerate(rows, start=2):
        raw_date = row['date'].strip()
        locale = row['locale'].strip()
        if not ISO_DATE.fullmatch(raw_date):
            errors.append(f'row {index}: invalid date format {raw_date!r}')
            continue
        try:
            parsed_date = date.fromisoformat(raw_date)
        except ValueError:
            errors.append(f'row {index}: invalid Gregorian date {raw_date!r}')
            continue
        if not start <= parsed_date <= end:
            errors.append(f'row {index}: date outside initial coverage {raw_date}')
        if locale not in locales:
            errors.append(f'row {index}: unsupported locale {locale!r}')
        for field in ('title', 'teaser', 'full_text', 'theme_tag'):
            if not row[field].strip():
                errors.append(f'row {index}: blank {field}')
        key = f'{raw_date}|{locale}'
        keys.append(key)
        combined = normalized_text(f"{row['title']} {row['teaser']} {row['full_text']}")
        exact_texts[combined] += 1
        opening = ' '.join(normalized_text(row['full_text']).split()[:6])
        if opening:
            opening_patterns[opening] += 1

    key_counts = Counter(keys)
    duplicates = sorted(key for key, count in key_counts.items() if count > 1)
    if duplicates:
        errors.append(f'duplicate exact date/locale keys: {duplicates[:10]}')

    actual_keys = set(keys)
    missing = sorted(expected_keys - actual_keys)
    extra = sorted(actual_keys - expected_keys)
    if missing:
        errors.append(f'missing exact date/locale keys: {missing[:10]} (total={len(missing)})')
    if extra:
        errors.append(f'extra date/locale keys: {extra[:10]} (total={len(extra)})')

    duplicate_texts = [text for text, count in exact_texts.items() if count > 1]
    if duplicate_texts:
        errors.append(f'exact duplicate message bodies detected: {len(duplicate_texts)} groups')

    repetitive_openings = [(opening, count) for opening, count in opening_patterns.items() if count >= 20]
    if repetitive_openings:
        repetitive_openings.sort(key=lambda pair: (-pair[1], pair[0]))
        errors.append(f'repetitive opening patterns >=20 uses: {repetitive_openings[:10]}')

    required_leap_dates = set(manifest['required_leap_dates'])
    for leap_date in required_leap_dates:
        for locale in locales:
            if f'{leap_date}|{locale}' not in actual_keys:
                errors.append(f'missing required leap date {leap_date}|{locale}')

    if len(expected_dates) != manifest['initial_days']:
        errors.append('manifest initial_days does not match Gregorian range')
    if len(expected_keys) != manifest['initial_total_records']:
        errors.append('manifest initial_total_records does not match date × locale range')

    return {
        'ok': not errors,
        'errors': errors,
        'record_count': len(rows),
        'expected_record_count': len(expected_keys),
        'catalog_sha256': sha256(path),
        'coverage_start': start.isoformat(),
        'coverage_end': end.isoformat(),
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description='Audit Ruh Code exact-date TR/EN daily message catalog.')
    result.add_argument('--catalog', required=True, type=Path)
    result.add_argument(
        '--manifest',
        type=Path,
        default=Path('requirements/content_manifests/daily_messages.json'),
    )
    result.add_argument('--report', type=Path)
    return result


if __name__ == '__main__':
    args = parser().parse_args()
    result = audit(args.catalog, args.manifest)
    serialized = json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(serialized + '\n', encoding='utf-8')
    print(serialized)
    if not result['ok']:
        sys.exit(1)
