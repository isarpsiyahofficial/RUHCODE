from __future__ import annotations

from pathlib import Path
import csv
import json
import tempfile
import unittest

from tools.content.append_daily_message_batch import BatchAppendError, append_paired_batch

FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']


def write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS, lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)


def row(day: str, locale: str, suffix: str) -> dict[str, str]:
    return {
        'date': day,
        'locale': locale,
        'title': f'{locale.upper()} title {suffix}',
        'teaser': f'{locale.upper()} teaser {suffix}',
        'full_text': f'{locale.upper()} full text for {suffix} with independent wording.',
        'theme_tag': 'test',
    }


class AppendDailyMessageBatchTest(unittest.TestCase):
    def fixture(self) -> tuple[Path, Path, Path, Path, tempfile.TemporaryDirectory[str]]:
        temp = tempfile.TemporaryDirectory()
        root = Path(temp.name)
        shards = root / 'assets/content/daily_messages'
        evidence = root / 'evidence/content/daily_messages_editorial_progress.json'
        evidence.parent.mkdir(parents=True, exist_ok=True)
        evidence.write_text(json.dumps({
            'status': 'EDITORIAL_IN_PROGRESS',
            'done': False,
            'currentReviewedCoverage': {
                'tr': {'start': '2026-01-01', 'end': '2026-01-02', 'records': 2},
                'en': {'start': '2026-01-01', 'end': '2026-01-02', 'records': 2},
                'totalRecords': 4,
            },
        }), encoding='utf-8')
        for locale in ('tr', 'en'):
            write_csv(shards / locale / '2026.csv', [
                row('2026-01-01', locale, 'one'),
                row('2026-01-02', locale, 'two'),
            ])
        tr_batch = root / 'tr_batch.csv'
        en_batch = root / 'en_batch.csv'
        return shards, evidence, tr_batch, en_batch, temp

    def test_appends_paired_contiguous_batch_and_updates_ledger(self) -> None:
        shards, evidence, tr_batch, en_batch, temp = self.fixture()
        self.addCleanup(temp.cleanup)
        write_csv(tr_batch, [row('2026-01-03', 'tr', 'three'), row('2026-01-04', 'tr', 'four')])
        write_csv(en_batch, [row('2026-01-03', 'en', 'THREE'), row('2026-01-04', 'en', 'FOUR')])

        summary = append_paired_batch(
            shards_root=shards,
            evidence_path=evidence,
            tr_batch=tr_batch,
            en_batch=en_batch,
            year=2026,
        )

        self.assertEqual(summary.start, '2026-01-03')
        self.assertEqual(summary.end, '2026-01-04')
        self.assertEqual(summary.records_per_locale, 2)
        self.assertEqual(summary.total_records_after, 8)
        updated = json.loads(evidence.read_text(encoding='utf-8'))['currentReviewedCoverage']
        self.assertEqual(updated['tr']['records'], 4)
        self.assertEqual(updated['en']['records'], 4)
        self.assertEqual(updated['totalRecords'], 8)
        self.assertEqual(len(list(csv.DictReader((shards / 'tr/2026.csv').open(encoding='utf-8')))), 4)
        self.assertEqual(len(list(csv.DictReader((shards / 'en/2026.csv').open(encoding='utf-8')))), 4)

    def test_rejects_gap_without_mutating_shards_or_evidence(self) -> None:
        shards, evidence, tr_batch, en_batch, temp = self.fixture()
        self.addCleanup(temp.cleanup)
        write_csv(tr_batch, [row('2026-01-04', 'tr', 'gap')])
        write_csv(en_batch, [row('2026-01-04', 'en', 'GAP')])
        before_tr = (shards / 'tr/2026.csv').read_text(encoding='utf-8')
        before_en = (shards / 'en/2026.csv').read_text(encoding='utf-8')
        before_evidence = evidence.read_text(encoding='utf-8')

        with self.assertRaises(BatchAppendError):
            append_paired_batch(
                shards_root=shards,
                evidence_path=evidence,
                tr_batch=tr_batch,
                en_batch=en_batch,
                year=2026,
            )

        self.assertEqual((shards / 'tr/2026.csv').read_text(encoding='utf-8'), before_tr)
        self.assertEqual((shards / 'en/2026.csv').read_text(encoding='utf-8'), before_en)
        self.assertEqual(evidence.read_text(encoding='utf-8'), before_evidence)

    def test_rejects_mismatched_language_date_ranges(self) -> None:
        shards, evidence, tr_batch, en_batch, temp = self.fixture()
        self.addCleanup(temp.cleanup)
        write_csv(tr_batch, [row('2026-01-03', 'tr', 'three')])
        write_csv(en_batch, [row('2026-01-03', 'en', 'THREE'), row('2026-01-04', 'en', 'FOUR')])

        with self.assertRaises(BatchAppendError):
            append_paired_batch(
                shards_root=shards,
                evidence_path=evidence,
                tr_batch=tr_batch,
                en_batch=en_batch,
                year=2026,
            )

    def test_rejects_locale_mismatch(self) -> None:
        shards, evidence, tr_batch, en_batch, temp = self.fixture()
        self.addCleanup(temp.cleanup)
        write_csv(tr_batch, [row('2026-01-03', 'en', 'wrong-locale')])
        write_csv(en_batch, [row('2026-01-03', 'en', 'THREE')])

        with self.assertRaises(BatchAppendError):
            append_paired_batch(
                shards_root=shards,
                evidence_path=evidence,
                tr_batch=tr_batch,
                en_batch=en_batch,
                year=2026,
            )


if __name__ == '__main__':
    unittest.main()
