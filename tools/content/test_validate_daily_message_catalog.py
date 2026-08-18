#!/usr/bin/env python3
from pathlib import Path
import csv
import importlib.util
import json
import sys
import tempfile
import unittest

MODULE_PATH = Path(__file__).with_name('validate_daily_message_catalog.py')
spec = importlib.util.spec_from_file_location('validate_daily_message_catalog', MODULE_PATH)
assert spec and spec.loader
module = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = module
spec.loader.exec_module(module)

FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']


def write_manifest(path: Path) -> None:
    path.write_text(
        json.dumps(
            {
                'initial_coverage_start': '2028-02-28',
                'initial_coverage_end': '2028-02-29',
                'locales': ['tr', 'en'],
                'initial_days': 2,
                'initial_total_records': 4,
                'required_leap_dates': ['2028-02-29'],
            }
        ),
        encoding='utf-8',
    )


def write_catalog(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open('w', encoding='utf-8', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)


def row(day: str, locale: str, suffix: str) -> dict[str, str]:
    return {
        'date': day,
        'locale': locale,
        'title': f'Title {suffix}',
        'teaser': f'Teaser {suffix}',
        'full_text': f'Unique full message for {suffix}.',
        'theme_tag': f'theme-{suffix}',
    }


class DailyMessageAuditorTest(unittest.TestCase):
    def test_complete_exact_date_locale_fixture_passes(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            write_catalog(
                catalog,
                [
                    row('2028-02-28', 'tr', 'a'),
                    row('2028-02-28', 'en', 'b'),
                    row('2028-02-29', 'tr', 'c'),
                    row('2028-02-29', 'en', 'd'),
                ],
            )
            result = module.audit(catalog, manifest)
            self.assertTrue(result['ok'], result['errors'])
            self.assertEqual(result['record_count'], 4)
            self.assertEqual(result['expected_record_count'], 4)
            self.assertEqual(len(result['catalog_sha256']), 64)

    def test_missing_leap_locale_and_duplicate_key_fail(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            write_catalog(
                catalog,
                [
                    row('2028-02-28', 'tr', 'a'),
                    row('2028-02-28', 'tr', 'b'),
                    row('2028-02-28', 'en', 'c'),
                ],
            )
            result = module.audit(catalog, manifest)
            self.assertFalse(result['ok'])
            joined = '\n'.join(result['errors'])
            self.assertIn('duplicate exact date/locale keys', joined)
            self.assertIn('missing required leap date 2028-02-29|tr', joined)
            self.assertIn('missing required leap date 2028-02-29|en', joined)

    def test_exact_duplicate_content_fails_even_on_different_dates(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            shared = {
                'title': 'Same',
                'teaser': 'Same teaser',
                'full_text': 'Same full body.',
                'theme_tag': 'same',
            }
            rows = []
            for day, locale in (
                ('2028-02-28', 'tr'),
                ('2028-02-28', 'en'),
                ('2028-02-29', 'tr'),
                ('2028-02-29', 'en'),
            ):
                rows.append({'date': day, 'locale': locale, **shared})
            write_catalog(catalog, rows)
            result = module.audit(catalog, manifest)
            self.assertFalse(result['ok'])
            self.assertTrue(
                any('exact duplicate message bodies' in error for error in result['errors'])
            )


if __name__ == '__main__':
    unittest.main()
