#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / 'requirements' / 'requirement_matrix.csv'
STATE = ROOT / 'requirements' / 'requirement_state.csv'
RC_RE = re.compile(r'RC-(\d{4})$')
SOURCE_LEVEL_STATUSES = {'SOURCE_LEVEL_IMPLEMENTED', 'IMPLEMENTED', 'TESTED', 'VERIFIED'}


def parse_claims(path: Path) -> set[str]:
    payload = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(payload, dict):
        raise AssertionError(f'{path.relative_to(ROOT)}: evidence must be a JSON object')
    status = str(payload.get('status', '')).strip().upper()
    if status not in SOURCE_LEVEL_STATUSES:
        raise AssertionError(
            f'{path.relative_to(ROOT)}: matrix source evidence has non-implementing status {status!r}'
        )
    raw = payload.get('requirements')
    if raw is None:
        raw = payload.get('requirement_ids')
    if not isinstance(raw, list) or not raw:
        raise AssertionError(f'{path.relative_to(ROOT)}: source evidence needs RC claims')
    claims: set[str] = set()
    for token in raw:
        if not isinstance(token, str) or RC_RE.fullmatch(token) is None:
            raise AssertionError(f'{path.relative_to(ROOT)}: invalid RC token {token!r}')
        claims.add(token)
    return claims


def load_explicit_state() -> dict[str, dict[str, str]]:
    if not STATE.exists():
        return {}
    with STATE.open(encoding='utf-8', newline='') as handle:
        rows = list(csv.DictReader(handle))
    result: dict[str, dict[str, str]] = {}
    for row in rows:
        rc_id = row.get('rc_id', '').strip()
        if not rc_id:
            continue
        if RC_RE.fullmatch(rc_id) is None:
            raise AssertionError(f'requirement_state.csv: invalid rc_id {rc_id!r}')
        if rc_id in result:
            raise AssertionError(f'requirement_state.csv: duplicate {rc_id}')
        result[rc_id] = row
    return result


def main() -> None:
    if not MATRIX.is_file():
        raise AssertionError('requirements/requirement_matrix.csv is missing; run build_requirement_matrix.py first')

    explicit = load_explicit_state()
    with MATRIX.open(encoding='utf-8', newline='') as handle:
        rows = list(csv.DictReader(handle))

    if len(rows) != 1442:
        raise AssertionError(f'matrix must contain 1,442 rows; got {len(rows)}')

    evidence_cache: dict[Path, set[str]] = {}
    auto_implemented = 0
    explicit_non_default = 0
    done_count = 0

    for index, row in enumerate(rows, start=1):
        rc_id = row.get('rc_id', '').strip()
        expected = f'RC-{index:04d}'
        if rc_id != expected:
            raise AssertionError(f'matrix order mismatch at row {index}: {rc_id!r} != {expected}')

        status = row.get('status', '').strip()
        links = [part.strip() for part in row.get('evidence_links', '').split('|') if part.strip()]
        state_row = explicit.get(rc_id)

        if status == 'NOT_STARTED':
            continue

        if not links:
            raise AssertionError(f'{rc_id}: non-default status {status} requires evidence_links')

        if status == 'DONE':
            done_count += 1
            if state_row is None or state_row.get('status', '').strip() != 'DONE':
                raise AssertionError(f'{rc_id}: DONE must come from explicit requirement_state.csv override')
            if not state_row.get('evidence_links', '').strip():
                raise AssertionError(f'{rc_id}: explicit DONE override needs evidence_links')
            continue

        if state_row is not None:
            explicit_non_default += 1
            continue

        if status != 'IMPLEMENTED':
            raise AssertionError(
                f'{rc_id}: auto-derived state may only be IMPLEMENTED; got {status}'
            )

        auto_implemented += 1
        for raw in links:
            path = ROOT / raw
            try:
                relative = path.relative_to(ROOT)
            except ValueError as exc:
                raise AssertionError(f'{rc_id}: evidence link escapes repository: {raw}') from exc
            if not path.is_file() or path.suffix.lower() != '.json' or 'evidence' not in relative.parts:
                raise AssertionError(f'{rc_id}: auto evidence link is not an evidence JSON file: {raw}')
            claims = evidence_cache.get(path)
            if claims is None:
                claims = parse_claims(path)
                evidence_cache[path] = claims
            if rc_id not in claims:
                raise AssertionError(
                    f'{rc_id}: linked evidence {relative.as_posix()} does not claim this requirement'
                )

    print(
        'OK: requirement matrix provenance validated; '
        f'auto IMPLEMENTED={auto_implemented}, explicit non-default={explicit_non_default}, DONE={done_count}'
    )


if __name__ == '__main__':
    main()
