import csv
from datetime import date, timedelta
import json
from pathlib import Path
import tempfile
import unittest

from tools.content.validate_daily_message_release_horizon import validate_release_horizon


class DailyMessageReleaseHorizonTest(unittest.TestCase):
    def _fixture(self, *, start: date, end: date, missing: set[tuple[str, str]] | None = None):
        temp = tempfile.TemporaryDirectory()
        root = Path(temp.name)
        manifest = root / 'manifest.json'
        catalog = root / 'catalog.csv'
        manifest.write_text(
            json.dumps({
                'rolling_release_horizon_years': 10,
                'locales': ['tr', 'en'],
            }),
            encoding='utf-8',
        )
        missing = missing or set()
        with catalog.open('w', encoding='utf-8', newline='') as handle:
            writer = csv.DictWriter(
                handle,
                fieldnames=['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag'],
            )
            writer.writeheader()
            current = start
            while current <= end:
                iso = current.isoformat()
                for locale in ('tr', 'en'):
                    if (iso, locale) in missing:
                        continue
                    writer.writerow({
                        'date': iso,
                        'locale': locale,
                        'title': f'{locale}-{iso}',
                        'teaser': 'teaser',
                        'full_text': 'full',
                        'theme_tag': 'test',
                    })
                current += timedelta(days=1)
        return temp, catalog, manifest

    def test_full_ten_year_release_window_passes(self):
        release = date(2026, 9, 1)
        temp, catalog, manifest = self._fixture(
            start=release,
            end=date(2036, 9, 1),
        )
        self.addCleanup(temp.cleanup)
        report = validate_release_horizon(
            catalog=catalog,
            manifest=manifest,
            release_date=release,
        )
        self.assertTrue(report['ok'])
        self.assertEqual(report['required_through'], '2036-09-01')
        self.assertEqual(report['missing_release_window_records'], 0)

    def test_one_missing_locale_date_is_release_blocker(self):
        release = date(2026, 9, 1)
        missing = {('2031-05-04', 'en')}
        temp, catalog, manifest = self._fixture(
            start=release,
            end=date(2036, 9, 1),
            missing=missing,
        )
        self.addCleanup(temp.cleanup)
        with self.assertRaisesRegex(AssertionError, 'release horizon is short'):
            validate_release_horizon(
                catalog=catalog,
                manifest=manifest,
                release_date=release,
            )

    def test_catalog_ending_one_day_early_is_release_blocker(self):
        release = date(2026, 9, 1)
        temp, catalog, manifest = self._fixture(
            start=release,
            end=date(2036, 8, 31),
        )
        self.addCleanup(temp.cleanup)
        with self.assertRaisesRegex(AssertionError, 'required_through=2036-09-01'):
            validate_release_horizon(
                catalog=catalog,
                manifest=manifest,
                release_date=release,
            )

    def test_leap_day_release_clamps_target_to_february_28(self):
        release = date(2028, 2, 29)
        temp, catalog, manifest = self._fixture(
            start=release,
            end=date(2038, 2, 28),
        )
        self.addCleanup(temp.cleanup)
        report = validate_release_horizon(
            catalog=catalog,
            manifest=manifest,
            release_date=release,
        )
        self.assertEqual(report['required_through'], '2038-02-28')


if __name__ == '__main__':
    unittest.main()
