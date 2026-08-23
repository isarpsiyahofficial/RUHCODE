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


builder = load_module('build_daily_message_catalog', TOOLS / 'build_daily_message_catalog.py')
auditor = load_module('validate_daily_message_catalog_for_shards', TOOLS / 'validate_daily_message_catalog.py')

FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']


def write_manifest(path: Path) -> None:
    path.write_text(
        json.dumps({
            'initial_coverage_start': '2026-01-01',
            'initial_coverage_end': '2026-01-03',
            'locales': ['tr', 'en'],
            'initial_days': 3,
            'initial_total_records': 6,
            'required_leap_dates': [],
            'quality_thresholds': {
                'near_duplicate_similarity': 0.90,
                'near_duplicate_min_shared_tokens': 4,
                'near_duplicate_max_token_document_ratio': 1.0,
                'repetitive_opening_max_uses': 19,
                'fail_on_near_duplicate': True,
                'fail_on_unsafe_certainty': True,
            },
        }),
        encoding='utf-8',
    )


def write_shard(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
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
        'full_text': f'Distinct editorial message {suffix} with enough unique language for review.',
        'theme_tag': f'theme-{suffix}',
    }


class DailyMessageShardTest(unittest.TestCase):
    def test_partial_shards_compile_and_pass_editorial_quality_without_claiming_complete(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            shards = root / 'shards'
            output = root / 'catalog.csv'
            write_manifest(manifest)
            write_shard(shards / 'tr' / '2026.csv', [row('2026-01-01', 'tr', 'tr-alpha')])
            write_shard(shards / 'en' / '2026.csv', [row('2026-01-01', 'en', 'en-bravo')])

            summary = builder.build(shards_root=shards, manifest_path=manifest, output=output)
            self.assertEqual(summary['records'], 2)
            self.assertEqual(summary['shards'], 2)

            result = auditor.audit(output, manifest, allow_incomplete=True)
            self.assertTrue(result['ok'], result['errors'])
            self.assertFalse(result['complete'])
            self.assertEqual(result['missing_record_count'], 4)

            strict = auditor.audit(output, manifest)
            self.assertFalse(strict['ok'])
            self.assertTrue(any('missing exact date/locale keys' in item for item in strict['errors']))

    def test_builder_rejects_locale_directory_and_row_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            shards = root / 'shards'
            output = root / 'catalog.csv'
            write_manifest(manifest)
            write_shard(shards / 'tr' / '2026.csv', [row('2026-01-01', 'en', 'wrong-locale')])

            with self.assertRaisesRegex(ValueError, 'does not match shard directory'):
                builder.build(shards_root=shards, manifest_path=manifest, output=output)

    def test_builder_rejects_date outside shard year(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            manifest = root / 'manifest.json'
            shards = root / 'shards'
            output = root / 'catalog.csv'
            write_manifest(manifest)
            write_shard(shards / 'tr' / '2026.csv', [row('2027-01-01', 'tr', 'wrong-year')])

            with self.assertRaisesRegex(ValueError, 'does not match shard year'):
                builder.build(shards_root=shards, manifest_path=manifest, output=output)


if __name__ == '__main__':
    unittest.main()
