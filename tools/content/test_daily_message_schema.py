from __future__ import annotations

from pathlib import Path
import csv
import tempfile
import unittest

from tools.content.daily_message_schema import (
    CANONICAL_FIELDS,
    LEGACY_FIELDS,
    DailyMessageSchemaError,
    read_canonical_batch,
    read_shard_rows,
)


class DailyMessageSchemaTest(unittest.TestCase):
    def write_rows(self, path: Path, fields: list[str], rows: list[dict[str, str]]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open('w', encoding='utf-8', newline='') as handle:
            writer = csv.DictWriter(handle, fieldnames=fields, lineterminator='\n')
            writer.writeheader()
            writer.writerows(rows)

    def test_legacy_shard_is_normalized_without_content_loss(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'tr' / '2034-08.csv'
            self.write_rows(path, LEGACY_FIELDS, [{
                'date': '2034-08-01',
                'title': 'Başlık',
                'teaser': 'Kısa açıklama',
                'message': 'Tam mesaj',
                'theme': 'accessibility',
            }])

            rows, schema = read_shard_rows(path, expected_locale='tr', allow_legacy=True)

            self.assertEqual(schema, 'legacy-v0')
            self.assertEqual(rows, [{
                'date': '2034-08-01',
                'locale': 'tr',
                'title': 'Başlık',
                'teaser': 'Kısa açıklama',
                'full_text': 'Tam mesaj',
                'theme_tag': 'accessibility',
            }])

    def test_canonical_shard_preserves_exact_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'en' / '2034-08.csv'
            row = {
                'date': '2034-08-01',
                'locale': 'en',
                'title': 'Title',
                'teaser': 'Teaser',
                'full_text': 'Full message',
                'theme_tag': 'accessibility',
            }
            self.write_rows(path, CANONICAL_FIELDS, [row])
            rows, schema = read_shard_rows(path, expected_locale='en', allow_legacy=True)
            self.assertEqual(schema, 'canonical-v1')
            self.assertEqual(rows, [row])

    def test_new_editorial_batch_rejects_legacy_schema(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'tr_batch.csv'
            self.write_rows(path, LEGACY_FIELDS, [{
                'date': '2034-09-01',
                'title': 'Başlık',
                'teaser': 'Teaser',
                'message': 'Mesaj',
                'theme': 'test',
            }])
            with self.assertRaises(DailyMessageSchemaError):
                read_canonical_batch(path, expected_locale='tr')

    def test_canonical_locale_mismatch_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'tr' / '2034-08.csv'
            self.write_rows(path, CANONICAL_FIELDS, [{
                'date': '2034-08-01',
                'locale': 'en',
                'title': 'Title',
                'teaser': 'Teaser',
                'full_text': 'Message',
                'theme_tag': 'test',
            }])
            with self.assertRaises(DailyMessageSchemaError):
                read_shard_rows(path, expected_locale='tr', allow_legacy=True)


if __name__ == '__main__':
    unittest.main()
