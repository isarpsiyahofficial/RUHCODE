#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import argparse
import csv
import json
import re

REQUIRED_COLUMNS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']
SHARD_FILE = re.compile(r'^(\d{4})(?:-(\d{2}))?\.csv$')


def _shard_period(path: Path) -> tuple[int, int | None]:
    match = SHARD_FILE.fullmatch(path.name)
    if match is None:
        raise ValueError(f'Unexpected daily-message shard file name: {path}')
    year = int(match.group(1))
    month = int(match.group(2)) if match.group(2) is not None else None
    if month is not None and not 1 <= month <= 12:
        raise ValueError(f'Invalid daily-message shard month: {path}')
    return year, month


def build(*, shards_root: Path, manifest_path: Path, output: Path) -> dict[str, object]:
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    locales = tuple(manifest['locales'])
    start_year = int(str(manifest['initial_coverage_start'])[:4])
    end_year = int(str(manifest['initial_coverage_end'])[:4])

    rows: list[dict[str, str]] = []
    shard_paths: list[str] = []
    seen_keys: set[str] = set()

    if not shards_root.is_dir():
        raise FileNotFoundError(f'Daily-message shards directory is missing: {shards_root}')

    for locale_dir in sorted(path for path in shards_root.iterdir() if path.is_dir()):
        locale = locale_dir.name
        if locale not in locales:
            raise ValueError(f'Unexpected locale shard directory: {locale}')
        for path in sorted(locale_dir.iterdir()):
            if not path.is_file():
                continue
            year, month = _shard_period(path)
            if year < start_year or year > end_year:
                raise ValueError(f'Shard year outside manifest coverage: {path}')

            with path.open(encoding='utf-8', newline='') as handle:
                reader = csv.DictReader(handle)
                if reader.fieldnames != REQUIRED_COLUMNS:
                    raise ValueError(
                        f'{path}: expected exact columns {REQUIRED_COLUMNS}, got {reader.fieldnames}'
                    )
                for line_number, row in enumerate(reader, start=2):
                    if row['locale'].strip() != locale:
                        raise ValueError(
                            f'{path}:{line_number}: locale {row["locale"]!r} does not match shard directory {locale!r}'
                        )
                    raw_date = row['date'].strip()
                    if not raw_date.startswith(f'{year:04d}-'):
                        raise ValueError(
                            f'{path}:{line_number}: date {row["date"]!r} does not match shard year {year}'
                        )
                    if month is not None and not raw_date.startswith(f'{year:04d}-{month:02d}-'):
                        raise ValueError(
                            f'{path}:{line_number}: date {row["date"]!r} does not match shard month '
                            f'{year:04d}-{month:02d}'
                        )
                    key = f"{raw_date}|{locale}"
                    if key in seen_keys:
                        raise ValueError(f'Duplicate exact daily-message key across shards: {key}')
                    seen_keys.add(key)
                    rows.append({column: row[column] for column in REQUIRED_COLUMNS})
            shard_paths.append(path.as_posix())

    rows.sort(key=lambda row: (row['date'], row['locale']))
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('w', encoding='utf-8', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=REQUIRED_COLUMNS, lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)

    return {
        'records': len(rows),
        'shards': len(shard_paths),
        'shard_paths': shard_paths,
        'output': output.as_posix(),
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description='Build one deterministic Ruh Code daily-message catalog from locale/year or locale/year-month shards.'
    )
    result.add_argument('--shards-root', type=Path, default=Path('assets/content/daily_messages'))
    result.add_argument('--manifest', type=Path, default=Path('requirements/content_manifests/daily_messages.json'))
    result.add_argument('--output', type=Path, required=True)
    return result


if __name__ == '__main__':
    args = parser().parse_args()
    summary = build(shards_root=args.shards_root, manifest_path=args.manifest, output=args.output)
    print(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True))
