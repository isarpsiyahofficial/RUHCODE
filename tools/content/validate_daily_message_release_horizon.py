from __future__ import annotations

import argparse
import csv
from datetime import date, timedelta
import json
from pathlib import Path
import sys


def _parse_date(value: str) -> date:
    try:
        return date.fromisoformat(value)
    except ValueError as exc:
        raise ValueError(f'invalid ISO release date: {value!r}') from exc


def _add_calendar_years(value: date, years: int) -> date:
    try:
        return value.replace(year=value.year + years)
    except ValueError:
        # 29 February has no direct counterpart in a non-leap target year.
        # Clamp to the last valid day of the same month; this never shortens
        # the requirement by more than the calendar's unavoidable one day.
        return value.replace(year=value.year + years, day=28)


def _date_range(start: date, end: date):
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


def validate_release_horizon(*, catalog: Path, manifest: Path, release_date: date) -> dict:
    config = json.loads(manifest.read_text(encoding='utf-8'))
    years = int(config['rolling_release_horizon_years'])
    if years < 10:
        raise AssertionError(
            f'rolling_release_horizon_years must be at least 10, got {years}'
        )

    locales = tuple(config['locales'])
    if set(locales) != {'tr', 'en'}:
        raise AssertionError(f'rolling horizon requires exact TR/EN locales, got {locales!r}')

    target_date = _add_calendar_years(release_date, years)
    keys: set[tuple[date, str]] = set()
    duplicates: list[str] = []
    latest_by_locale: dict[str, date | None] = {locale: None for locale in locales}

    with catalog.open('r', encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        required_columns = {'date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag'}
        if reader.fieldnames is None or not required_columns.issubset(reader.fieldnames):
            raise AssertionError(
                f'catalog must contain canonical columns {sorted(required_columns)}'
            )
        for row in reader:
            row_date = _parse_date(row['date'])
            locale = row['locale'].strip()
            if locale not in latest_by_locale:
                continue
            key = (row_date, locale)
            if key in keys:
                duplicates.append(f'{row_date.isoformat()}|{locale}')
            keys.add(key)
            previous = latest_by_locale[locale]
            if previous is None or row_date > previous:
                latest_by_locale[locale] = row_date

    expected_keys = {
        (current, locale)
        for current in _date_range(release_date, target_date)
        for locale in locales
    }
    missing = sorted(expected_keys - keys)

    report = {
        'release_date': release_date.isoformat(),
        'rolling_release_horizon_years': years,
        'required_through': target_date.isoformat(),
        'locales': list(locales),
        'latest_by_locale': {
            locale: value.isoformat() if value else None
            for locale, value in latest_by_locale.items()
        },
        'expected_release_window_records': len(expected_keys),
        'missing_release_window_records': len(missing),
        'duplicate_keys': sorted(set(duplicates)),
        'ok': not missing and not duplicates,
    }

    if duplicates:
        raise AssertionError(
            'duplicate exact date/locale keys in release window source: '
            + ', '.join(sorted(set(duplicates))[:10])
        )
    if missing:
        sample = ', '.join(f'{d.isoformat()}|{locale}' for d, locale in missing[:10])
        raise AssertionError(
            f'daily-message release horizon is short: release={release_date.isoformat()} '
            f'required_through={target_date.isoformat()} missing={len(missing)} sample={sample}'
        )
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description='Enforce RC-1433 rolling 10-full-year daily-message stock at release time.'
    )
    parser.add_argument('--catalog', required=True, type=Path)
    parser.add_argument('--manifest', required=True, type=Path)
    parser.add_argument('--release-date', required=True, help='Release date as YYYY-MM-DD')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args(argv)

    try:
        report = validate_release_horizon(
            catalog=args.catalog,
            manifest=args.manifest,
            release_date=_parse_date(args.release_date),
        )
    except (AssertionError, KeyError, ValueError, json.JSONDecodeError) as exc:
        print(f'daily-message release horizon FAILED: {exc}', file=sys.stderr)
        return 1

    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )
    print(
        'daily-message release horizon OK: '
        f"release={report['release_date']} through={report['required_through']} "
        f"records={report['expected_release_window_records']}"
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
