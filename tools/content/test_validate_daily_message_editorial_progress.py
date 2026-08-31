#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import csv
import importlib.util
import json
import sys
import tempfile
import unittest

TOOLS = Path(__file__).resolve().parent


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


validator = load_module(
    'validate_daily_message_editorial_progress_for_test',
    TOOLS / 'validate_daily_message_editorial_progress.py',
)

FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']


def write_csv(path: Path, locale: str, dates: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, lineterminator='\n')
        writer.writeheader()
        for index, day in enumerate(dates, start=1):
            writer.writerow({
                'date': day,
                'locale': locale,
                'title': f'Title {locale} {index}',
                'teaser': f'Teaser {locale} {index}',
                'full_text': f'Editorial text {locale} {index} with distinct wording.',
                'theme_tag': f'theme-{locale}-{index}',
            })


class DailyMessageEditorialProgressLeapTest(unittest.TestCase):
    def configure(self, root: Path, *, end: str, records: int) -> None:
        manifest = root / 'manifest.json'
        evidence = root / 'evidence.json'
        shards = root / 'shards'
        manifest.write_text(json.dumps({
            'status': 'EDITORIAL_CONTENT_IN_PROGRESS',
            'locales': ['tr', 'en'],
            'initial_coverage_start': '2028-02-28',
            'initial_coverage_end': '2036-12-31',
            'initial_total_records': 100,
            'required_leap_dates': ['2028-02-29', '2032-02-29', '2036-02-29'],
        }), encoding='utf-8')
        evidence.write_text(json.dumps({
            'status': 'EDITORIAL_IN_PROGRESS',
            'done': False,
            'currentReviewedCoverage': {
                'tr': {'start': '2028-02-28', 'end': end, 'records': records},
                'en': {'start': '2028-02-28', 'end': end, 'records': records},
                'totalRecords': records * 2,
            },
        }), encoding='utf-8')
        validator.MANIFEST = manifest
        validator.EVIDENCE = evidence
        validator.SHARDS = shards
        validator.ROOT = root

    def test_reviewed_leap_day_is_required_once_ledger_crosses_it(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.configure(root, end='2028-02-29', records=2)
            write_csv(root / 'shards/tr/2028-02.csv', 'tr', ['2028-02-28'])
            write_csv(root / 'shards/en/2028-02.csv', 'en', ['2028-02-28', '2028-02-29'])

            with self.assertRaisesRegex(SystemExit, 'evidence count 2 does not match shard rows 1'):
                validator.main()

    def test_leap_day_passes_when_both_locales_have_exact_record(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.configure(root, end='2028-02-29', records=2)
            for locale in ('tr', 'en'):
                write_csv(root / f'shards/{locale}/2028-02.csv', locale, ['2028-02-28', '2028-02-29'])

            validator.main()

    def test_future_required_leap_dates_do_not_block_earlier_ledger(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.configure(root, end='2028-02-28', records=1)
            for locale in ('tr', 'en'):
                write_csv(root / f'shards/{locale}/2028-02.csv', locale, ['2028-02-28'])

            validator.main()

    def test_complete_pending_release_audit_requires_exact_full_coverage(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            evidence = root / 'evidence.json'
            shards = root / 'shards'
            manifest.write_text(json.dumps({
                'status': 'EDITORIAL_CONTENT_COMPLETE_PENDING_RELEASE_AUDIT',
                'locales': ['tr', 'en'],
                'initial_coverage_start': '2036-12-30',
                'initial_coverage_end': '2036-12-31',
                'initial_total_records': 4,
                'required_leap_dates': [],
            }), encoding='utf-8')
            evidence.write_text(json.dumps({
                'status': 'EDITORIAL_COMPLETE_PENDING_RELEASE_AUDIT',
                'done': False,
                'currentReviewedCoverage': {
                    'tr': {'start': '2036-12-30', 'end': '2036-12-31', 'records': 2},
                    'en': {'start': '2036-12-30', 'end': '2036-12-31', 'records': 2},
                    'totalRecords': 4,
                },
            }), encoding='utf-8')
            for locale in ('tr', 'en'):
                write_csv(shards / f'{locale}/2036-12.csv', locale, ['2036-12-30', '2036-12-31'])

            validator.MANIFEST = manifest
            validator.EVIDENCE = evidence
            validator.SHARDS = shards
            validator.ROOT = root
            validator.main()


if __name__ == '__main__':
    unittest.main()
