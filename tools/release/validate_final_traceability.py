#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / 'requirements/requirement_state.csv'
EXPECTED_IDS = [f'RC-{i:04d}' for i in range(1, 1443)]
DIMENSION_TAGS = {
    'I18N': ('TR', 'EN'),
    'OFFLINE': ('OFFLINE',),
    'ENTITLEMENT': ('FREE', 'PRO'),
    'BACKUP': ('BACKUP',),
    'PDF': ('PDF',),
    'CALC': ('CALCULATION_REFERENCE',),
    'UI': ('UI_DEVICE',),
}


def fail(message: str) -> None:
    raise SystemExit(f'FINAL_TRACEABILITY_FAIL: {message}')


def load_rows() -> list[dict[str, str]]:
    with MATRIX.open(encoding='utf-8', newline='') as handle:
        rows = list(csv.DictReader(handle))
    ids = [row['rc_id'].strip() for row in rows]
    if ids != EXPECTED_IDS:
        fail('matrix must contain exact ordered RC-0001..RC-1442 without duplicates or gaps')
    return rows


def evidence_tokens(row: dict[str, str]) -> set[str]:
    haystack = '|'.join((row.get('evidence_type', ''), row.get('evidence_links', ''), row.get('notes', ''))).upper()
    tokens = set(re.findall(r'[A-Z][A-Z0-9_-]+', haystack))
    return tokens


def validate_dimensions(rows: list[dict[str, str]]) -> None:
    for row in rows:
        rc_id = row['rc_id'].strip()
        status = row['status'].strip()
        tags = {item.strip() for item in row['tags'].split('|') if item.strip()}
        tokens = evidence_tokens(row)
        if status in {'TESTED', 'VERIFIED', 'DONE'} and not row['evidence_links'].strip():
            fail(f'{rc_id}: tested-or-later state requires concrete evidence links')
        if status == 'DONE':
            if row['blocked'].strip() != 'NO':
                fail(f'{rc_id}: DONE cannot be blocked')
            if 'TEST' not in '|'.join(tokens):
                fail(f'{rc_id}: DONE requires regression/test evidence')
            for tag, dimensions in DIMENSION_TAGS.items():
                if tag not in tags:
                    continue
                for dimension in dimensions:
                    aliases = {
                        'TR': ('TR', 'I18N'),
                        'EN': ('EN', 'I18N'),
                        'FREE': ('FREE', 'ENTITLEMENT'),
                        'PRO': ('PRO', 'ENTITLEMENT'),
                        'BACKUP': ('BACKUP', 'ROUND', 'RESTORE'),
                        'PDF': ('PDF',),
                        'CALCULATION_REFERENCE': ('GOLDEN', 'REFERENCE', 'CALC'),
                        'UI_DEVICE': ('UI', 'DEVICE', 'GOLDEN'),
                        'OFFLINE': ('OFFLINE', 'AIRPLANE'),
                    }[dimension]
                    if not any(alias in tokens or alias in '|'.join(tokens) for alias in aliases):
                        fail(f'{rc_id}: DONE lacks required {dimension} evidence')


def validate_release(rows: list[dict[str, str]], manifest_path: Path) -> None:
    open_rows = [row['rc_id'] for row in rows if row['status'].strip() != 'DONE' or row['blocked'].strip() != 'NO']
    if open_rows:
        fail(f'release requires all 1442 requirements DONE/unblocked; first open={open_rows[:10]}')
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    commit = str(manifest.get('commitSha', '')).strip()
    artifact = str(manifest.get('artifactPath', '')).strip()
    digest = str(manifest.get('artifactSha256', '')).strip().lower()
    tag = str(manifest.get('gitTag', '')).strip()
    if not re.fullmatch(r'[0-9a-f]{40}', commit):
        fail('release manifest commitSha must be exact 40-char git SHA')
    if not tag:
        fail('release manifest gitTag is required')
    path = ROOT / artifact
    if not path.is_file():
        fail(f'exact release artifact missing: {artifact}')
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if not re.fullmatch(r'[0-9a-f]{64}', digest) or actual != digest:
        fail('release artifact SHA-256 does not match manifest')
    manifest_head = str(manifest.get('testedCommitSha', '')).strip()
    if manifest_head != commit:
        fail('artifact commit and tested commit must be identical')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--release-manifest', type=Path)
    args = parser.parse_args()
    rows = load_rows()
    validate_dimensions(rows)
    if args.release_manifest:
        validate_release(rows, args.release_manifest)
    print(f'FINAL_TRACEABILITY_OK total={len(rows)} release={bool(args.release_manifest)}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
