#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter, defaultdict
from datetime import date, timedelta
from difflib import SequenceMatcher
from pathlib import Path
import argparse
import csv
import hashlib
import json
import re
import sys

REQUIRED_COLUMNS = {'date', 'locale', 'title', 'teaser', 'full_text', 'theme_tag'}
ISO_DATE = re.compile(r'^\d{4}-\d{2}-\d{2}$')
TOKEN = re.compile(r"[^\W_]+(?:['’][^\W_]+)?", re.UNICODE)

UNSAFE_CERTAINTY_PATTERNS = {
    'tr': (
        re.compile(r'\bkesin(?:likle)?\s+(?:gerçekleşecek|olacak|yaşanacak)\b', re.I),
        re.compile(r'\bmutlaka\b.{0,40}\b(?:olacak|gerçekleşecek|yaşanacak)\b', re.I),
        re.compile(r'\bgaranti(?:dir|li)?\b', re.I),
        re.compile(r'\bkaçınılmaz\s+olarak\b', re.I),
    ),
    'en': (
        re.compile(r'\bwill\s+definitely\b', re.I),
        re.compile(r'\bguaranteed?\b', re.I),
        re.compile(r'\bcertain\s+to\b', re.I),
        re.compile(r'\binevitably\b', re.I),
    ),
}


def date_range(start: date, end: date):
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


def normalized_text(value: str) -> str:
    return ' '.join(value.casefold().split())


def tokenized(value: str) -> tuple[str, ...]:
    return tuple(TOKEN.findall(normalized_text(value)))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def load_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        fields = set(reader.fieldnames or [])
        if fields != REQUIRED_COLUMNS:
            raise ValueError(f'Expected columns {sorted(REQUIRED_COLUMNS)}, got {sorted(fields)}')
        return list(reader)


def _near_duplicate_pairs(
    rows: list[dict[str, str]],
    *,
    similarity_threshold: float,
    min_shared_tokens: int,
    max_token_document_ratio: float,
) -> list[dict[str, object]]:
    """Find likely near-copies per locale without a full O(n²) scan."""
    by_locale: dict[str, list[tuple[int, str, tuple[str, ...]]]] = defaultdict(list)
    for row_index, row in enumerate(rows, start=2):
        combined = normalized_text(f"{row['title']} {row['teaser']} {row['full_text']}")
        by_locale[row['locale'].strip()].append((row_index, combined, tokenized(combined)))

    findings: list[dict[str, object]] = []
    for locale, entries in by_locale.items():
        document_frequency: Counter[str] = Counter()
        token_sets: list[set[str]] = []
        for _, _, item_tokens in entries:
            token_set = {token for token in item_tokens if len(token) >= 3}
            token_sets.append(token_set)
            document_frequency.update(token_set)

        max_df = max(2, int(len(entries) * max_token_document_ratio))
        postings: dict[str, list[int]] = defaultdict(list)
        for local_index, token_set in enumerate(token_sets):
            for token in token_set:
                if document_frequency[token] <= max_df:
                    postings[token].append(local_index)

        shared_counts: Counter[tuple[int, int]] = Counter()
        for indices in postings.values():
            for pos, left in enumerate(indices):
                for right in indices[pos + 1:]:
                    shared_counts[(left, right)] += 1

        for (left, right), shared in shared_counts.items():
            if shared < min_shared_tokens:
                continue
            left_row, left_text, _ = entries[left]
            right_row, right_text, _ = entries[right]
            if left_text == right_text:
                continue
            shorter = min(len(left_text), len(right_text))
            longer = max(len(left_text), len(right_text))
            if not longer or shorter / longer < 0.72:
                continue
            ratio = SequenceMatcher(None, left_text, right_text, autojunk=False).ratio()
            if ratio >= similarity_threshold:
                findings.append({
                    'locale': locale,
                    'left_row': left_row,
                    'right_row': right_row,
                    'similarity': round(ratio, 6),
                    'shared_informative_tokens': shared,
                })

    findings.sort(key=lambda item: (-float(item['similarity']), str(item['locale']), int(item['left_row'])))
    return findings


def _unsafe_certainty_findings(rows: list[dict[str, str]]) -> list[dict[str, object]]:
    findings: list[dict[str, object]] = []
    for row_index, row in enumerate(rows, start=2):
        locale = row['locale'].strip()
        text = f"{row['title']} {row['teaser']} {row['full_text']}"
        for pattern in UNSAFE_CERTAINTY_PATTERNS.get(locale, ()):
            match = pattern.search(text)
            if match:
                findings.append({
                    'row': row_index,
                    'locale': locale,
                    'pattern': pattern.pattern,
                    'match': match.group(0),
                })
                break
    return findings


def audit(
    path: Path,
    manifest_path: Path,
    *,
    allow_incomplete: bool = False,
) -> dict[str, object]:
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    start = date.fromisoformat(manifest['initial_coverage_start'])
    end = date.fromisoformat(manifest['initial_coverage_end'])
    locales = tuple(manifest['locales'])
    expected_dates = [item.isoformat() for item in date_range(start, end)]
    expected_keys = {f'{day}|{locale}' for day in expected_dates for locale in locales}

    thresholds = manifest.get('quality_thresholds', {})
    near_threshold = float(thresholds.get('near_duplicate_similarity', 0.90))
    min_shared_tokens = int(thresholds.get('near_duplicate_min_shared_tokens', 4))
    max_token_ratio = float(thresholds.get('near_duplicate_max_token_document_ratio', 0.08))
    opening_limit = int(thresholds.get('repetitive_opening_max_uses', 19))
    fail_near = bool(thresholds.get('fail_on_near_duplicate', True))
    fail_unsafe = bool(thresholds.get('fail_on_unsafe_certainty', True))

    if not 0.0 < near_threshold <= 1.0:
        raise ValueError('near_duplicate_similarity must be in (0, 1].')
    if min_shared_tokens < 1:
        raise ValueError('near_duplicate_min_shared_tokens must be >= 1.')
    if not 0.0 < max_token_ratio <= 1.0:
        raise ValueError('near_duplicate_max_token_document_ratio must be in (0, 1].')

    rows = load_rows(path)
    keys: list[str] = []
    exact_texts: Counter[str] = Counter()
    opening_patterns: Counter[tuple[str, str]] = Counter()
    errors: list[str] = []

    for index, row in enumerate(rows, start=2):
        raw_date = row['date'].strip()
        locale = row['locale'].strip()
        if not ISO_DATE.fullmatch(raw_date):
            errors.append(f'row {index}: invalid date format {raw_date!r}')
            continue
        try:
            parsed_date = date.fromisoformat(raw_date)
        except ValueError:
            errors.append(f'row {index}: invalid Gregorian date {raw_date!r}')
            continue
        if not start <= parsed_date <= end:
            errors.append(f'row {index}: date outside initial coverage {raw_date}')
        if locale not in locales:
            errors.append(f'row {index}: unsupported locale {locale!r}')
        for field in ('title', 'teaser', 'full_text', 'theme_tag'):
            if not row[field].strip():
                errors.append(f'row {index}: blank {field}')
        key = f'{raw_date}|{locale}'
        keys.append(key)
        combined = normalized_text(f"{row['title']} {row['teaser']} {row['full_text']}")
        exact_texts[combined] += 1
        opening = ' '.join(normalized_text(row['full_text']).split()[:6])
        if opening:
            opening_patterns[(locale, opening)] += 1

    key_counts = Counter(keys)
    duplicates = sorted(key for key, count in key_counts.items() if count > 1)
    if duplicates:
        errors.append(f'duplicate exact date/locale keys: {duplicates[:10]}')

    actual_keys = set(keys)
    missing = sorted(expected_keys - actual_keys)
    extra = sorted(actual_keys - expected_keys)
    if missing and not allow_incomplete:
        errors.append(f'missing exact date/locale keys: {missing[:10]} (total={len(missing)})')
    if extra:
        errors.append(f'extra date/locale keys: {extra[:10]} (total={len(extra)})')

    duplicate_texts = [text for text, count in exact_texts.items() if count > 1]
    if duplicate_texts:
        errors.append(f'exact duplicate message bodies detected: {len(duplicate_texts)} groups')

    repetitive_openings = [
        (locale, opening, count)
        for (locale, opening), count in opening_patterns.items()
        if count > opening_limit
    ]
    if repetitive_openings:
        repetitive_openings.sort(key=lambda item: (-item[2], item[0], item[1]))
        errors.append(f'repetitive opening patterns >{opening_limit} uses: {repetitive_openings[:10]}')

    near_duplicates = _near_duplicate_pairs(
        rows,
        similarity_threshold=near_threshold,
        min_shared_tokens=min_shared_tokens,
        max_token_document_ratio=max_token_ratio,
    )
    if near_duplicates and fail_near:
        errors.append(
            f'near-duplicate editorial review failed: {len(near_duplicates)} candidate pairs '
            f'at similarity >= {near_threshold:.3f}'
        )

    unsafe_certainty = _unsafe_certainty_findings(rows)
    if unsafe_certainty and fail_unsafe:
        errors.append(
            f'unsafe certainty review failed: {len(unsafe_certainty)} message rows require review'
        )

    if not allow_incomplete:
        required_leap_dates = set(manifest['required_leap_dates'])
        for leap_date in required_leap_dates:
            for locale in locales:
                if f'{leap_date}|{locale}' not in actual_keys:
                    errors.append(f'missing required leap date {leap_date}|{locale}')

        if len(expected_dates) != manifest['initial_days']:
            errors.append('manifest initial_days does not match Gregorian range')
        if len(expected_keys) != manifest['initial_total_records']:
            errors.append('manifest initial_total_records does not match date × locale range')

    return {
        'ok': not errors,
        'complete': not missing and not extra and len(actual_keys) == len(expected_keys),
        'allow_incomplete': allow_incomplete,
        'errors': errors,
        'record_count': len(rows),
        'expected_record_count': len(expected_keys),
        'missing_record_count': len(missing),
        'catalog_sha256': sha256(path),
        'coverage_start': start.isoformat(),
        'coverage_end': end.isoformat(),
        'near_duplicate_candidates': near_duplicates,
        'unsafe_certainty_findings': unsafe_certainty,
        'repetitive_opening_findings': [
            {'locale': locale, 'opening': opening, 'count': count}
            for locale, opening, count in repetitive_openings
        ],
        'quality_thresholds': {
            'near_duplicate_similarity': near_threshold,
            'near_duplicate_min_shared_tokens': min_shared_tokens,
            'near_duplicate_max_token_document_ratio': max_token_ratio,
            'repetitive_opening_max_uses': opening_limit,
            'fail_on_near_duplicate': fail_near,
            'fail_on_unsafe_certainty': fail_unsafe,
        },
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description='Audit Ruh Code exact-date TR/EN daily message catalog.')
    result.add_argument('--catalog', required=True, type=Path)
    result.add_argument(
        '--manifest',
        type=Path,
        default=Path('requirements/content_manifests/daily_messages.json'),
    )
    result.add_argument('--report', type=Path)
    result.add_argument(
        '--allow-incomplete',
        action='store_true',
        help='Allow missing date/locale keys while still enforcing schema, uniqueness and editorial quality gates.',
    )
    return result


if __name__ == '__main__':
    args = parser().parse_args()
    result = audit(args.catalog, args.manifest, allow_incomplete=args.allow_incomplete)
    serialized = json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(serialized + '\n', encoding='utf-8')
    print(serialized)
    if not result['ok']:
        sys.exit(1)
