#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import csv

CANONICAL_FIELDS = ['date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag']
LEGACY_FIELDS = ['date', 'title', 'teaser', 'message', 'theme']


class DailyMessageSchemaError(ValueError):
    pass


def _clean(value: str | None) -> str:
    return (value or '').strip()


def read_shard_rows(
    path: Path,
    *,
    expected_locale: str,
    allow_legacy: bool = True,
) -> tuple[list[dict[str, str]], str]:
    """Read a shard into the single canonical in-memory schema.

    Legacy committed shards are accepted only when ``allow_legacy`` is true.
    Their locale is derived from the containing locale directory/caller and
    ``message/theme`` are deterministically mapped to ``full_text/theme_tag``.
    All returned rows always use CANONICAL_FIELDS.
    """
    with path.open(encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        fields = reader.fieldnames
        if fields == CANONICAL_FIELDS:
            schema = 'canonical-v1'
        elif allow_legacy and fields == LEGACY_FIELDS:
            schema = 'legacy-v0'
        else:
            raise DailyMessageSchemaError(
                f'{path}: expected canonical columns {CANONICAL_FIELDS}'
                + (f' or legacy columns {LEGACY_FIELDS}' if allow_legacy else '')
                + f', got {fields}'
            )

        rows: list[dict[str, str]] = []
        for line_number, row in enumerate(reader, start=2):
            if schema == 'canonical-v1':
                locale = _clean(row.get('locale'))
                if locale != expected_locale:
                    raise DailyMessageSchemaError(
                        f'{path}:{line_number}: locale {locale!r} does not match expected locale {expected_locale!r}'
                    )
                normalized = {field: _clean(row.get(field)) for field in CANONICAL_FIELDS}
            else:
                normalized = {
                    'date': _clean(row.get('date')),
                    'locale': expected_locale,
                    'title': _clean(row.get('title')),
                    'teaser': _clean(row.get('teaser')),
                    'full_text': _clean(row.get('message')),
                    'theme_tag': _clean(row.get('theme')),
                }
            rows.append(normalized)
    return rows, schema


def read_canonical_batch(path: Path, *, expected_locale: str) -> list[dict[str, str]]:
    """Read an incoming editorial batch; new writes must use canonical schema."""
    rows, _ = read_shard_rows(path, expected_locale=expected_locale, allow_legacy=False)
    return rows
