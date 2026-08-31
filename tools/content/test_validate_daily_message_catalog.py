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
                'quality_thresholds': {
                    'near_duplicate_similarity': 0.88,
                    'near_duplicate_min_shared_tokens': 3,
                    'near_duplicate_max_token_document_ratio': 1.0,
                    'repetitive_opening_max_uses': 19,
                    'fail_on_near_duplicate': True,
                    'fail_on_unsafe_certainty': True,
                },
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
        'full_text': f'Unique full message for {suffix} with a distinct reflective direction.',
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
                    row('2028-02-28', 'tr', 'alpha'),
                    row('2028-02-28', 'en', 'bravo'),
                    row('2028-02-29', 'tr', 'charlie'),
                    row('2028-02-29', 'en', 'delta'),
                ],
            )
            result = module.audit(catalog, manifest)
            self.assertTrue(result['ok'], result['errors'])
            self.assertEqual(result['record_count'], 4)
            self.assertEqual(result['expected_record_count'], 4)
            self.assertEqual(len(result['catalog_sha256']), 64)
            self.assertEqual(result['near_duplicate_candidates'], [])
            self.assertEqual(result['unsafe_certainty_findings'], [])

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
            self.assertTrue(any('exact duplicate message bodies' in error for error in result['errors']))

    def test_near_duplicate_is_flagged_within_same_locale(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            first = row('2028-02-28', 'tr', 'alpha')
            second = row('2028-02-29', 'tr', 'beta')
            first.update({
                'title': 'İçsel denge',
                'teaser': 'Bugün acele etmeden yönünü gör.',
                'full_text': 'Kendi ritmini koruduğunda önündeki seçenekleri daha sakin ve daha açık değerlendirebilirsin.',
            })
            second.update({
                'title': 'İçsel denge',
                'teaser': 'Bugün acele etmeden yönünü gör.',
                'full_text': 'Kendi ritmini koruduğunda önündeki seçenekleri daha sakin ve daha net değerlendirebilirsin.',
            })
            write_catalog(
                catalog,
                [first, row('2028-02-28', 'en', 'bravo'), second, row('2028-02-29', 'en', 'delta')],
            )
            result = module.audit(catalog, manifest)
            self.assertFalse(result['ok'])
            self.assertGreaterEqual(len(result['near_duplicate_candidates']), 1)
            self.assertTrue(any('near-duplicate editorial review failed' in error for error in result['errors']))

    def test_cross_locale_similarity_is_not_near_duplicate(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            tr = row('2028-02-28', 'tr', 'tr-a')
            en = row('2028-02-28', 'en', 'en-a')
            shared = 'This same literal sentence exists only to prove locale isolation in the candidate engine.'
            tr['full_text'] = shared
            en['full_text'] = shared
            write_catalog(catalog, [tr, en, row('2028-02-29', 'tr', 'tr-b'), row('2028-02-29', 'en', 'en-b')])
            result = module.audit(catalog, manifest)
            self.assertFalse(any('near-duplicate editorial review failed' in error for error in result['errors']))

    def test_unsafe_certainty_is_flagged_for_tr_and_en(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            tr = row('2028-02-28', 'tr', 'tr-a')
            tr['full_text'] = 'Bugün beklediğin gelişme kesinlikle gerçekleşecek.'
            en = row('2028-02-28', 'en', 'en-a')
            en['full_text'] = 'The outcome you expect will definitely happen today.'
            write_catalog(catalog, [tr, en, row('2028-02-29', 'tr', 'tr-b'), row('2028-02-29', 'en', 'en-b')])
            result = module.audit(catalog, manifest)
            self.assertFalse(result['ok'])
            self.assertEqual({item['locale'] for item in result['unsafe_certainty_findings']}, {'tr', 'en'})
            self.assertTrue(any('unsafe certainty review failed' in error for error in result['errors']))

    def test_negated_guarantee_is_safe_but_positive_guarantee_still_fails(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            catalog = root / 'catalog.csv'
            write_manifest(manifest)
            tr = row('2028-02-28', 'tr', 'tr-safe')
            tr['full_text'] = 'Bu seçim aynı sonucu garanti etmez; yalnız daha dengeli bir seçenek sunabilir.'
            en = row('2028-02-28', 'en', 'en-safe')
            en['full_text'] = 'Writing does not guarantee the answer, but it can clarify the tradeoffs.'
            tr_positive = row('2028-02-29', 'tr', 'tr-positive')
            tr_positive['full_text'] = 'Bu yöntem başarıyı garanti eder.'
            en_positive = row('2028-02-29', 'en', 'en-positive')
            en_positive['full_text'] = 'This method guarantees the result.'
            write_catalog(catalog, [tr, en, tr_positive, en_positive])

            result = module.audit(catalog, manifest)
            findings = result['unsafe_certainty_findings']
            self.assertEqual({item['row'] for item in findings}, {4, 5})
            self.assertEqual({item['locale'] for item in findings}, {'tr', 'en'})
            self.assertTrue(any('unsafe certainty review failed' in error for error in result['errors']))


if __name__ == '__main__':
    unittest.main()
