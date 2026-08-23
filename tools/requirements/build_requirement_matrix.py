#!/usr/bin/env python3
from pathlib import Path
import csv
import json
import re

from classify_requirements import classify

ROOT = Path(__file__).resolve().parents[2]
FILES = [ROOT / 'RUH_CODE_MASTER_SARTNAME.md', ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md']
STATE = ROOT / 'requirements' / 'requirement_state.csv'
OUT = ROOT / 'requirements' / 'requirement_matrix.csv'
EVIDENCE_ROOT = ROOT / 'evidence'
PATTERN = re.compile(r'^(\d+)\.\s+(.+)$')
VALID_STATUSES = {'NOT_STARTED','IMPLEMENTED','TESTED','VERIFIED','DONE'}
SOURCE_LEVEL_EVIDENCE_STATUSES = {'SOURCE_LEVEL_IMPLEMENTED', 'IMPLEMENTED', 'TESTED', 'VERIFIED'}

items = []
for path in FILES:
    for line in path.read_text(encoding='utf-8').splitlines():
        match = PATTERN.match(line)
        if match:
            items.append((int(match.group(1)), path.name, match.group(2)))

if [n for n, _, _ in items] != list(range(1, 1443)):
    raise SystemExit('Binding specification is not an exact RC-0001..RC-1442 sequence')


def load_source_evidence():
    by_requirement = {}
    if not EVIDENCE_ROOT.exists():
        return by_requirement
    for path in sorted(EVIDENCE_ROOT.rglob('*.json')):
        payload = json.loads(path.read_text(encoding='utf-8'))
        if not isinstance(payload, dict):
            continue
        status = str(payload.get('status', '')).strip().upper()
        if status not in SOURCE_LEVEL_EVIDENCE_STATUSES:
            continue
        reqs = payload.get('requirements')
        if reqs is None:
            reqs = payload.get('requirement_ids')
        if not isinstance(reqs, list):
            continue
        relative = path.relative_to(ROOT).as_posix()
        for token in reqs:
            if not isinstance(token, str):
                raise SystemExit(f'{relative}: invalid non-string requirement token {token!r}')
            match = re.fullmatch(r'RC-(\d{4})', token)
            if not match:
                raise SystemExit(f'{relative}: invalid requirement token {token!r}')
            number = int(match.group(1))
            if not 1 <= number <= 1442:
                raise SystemExit(f'{relative}: out-of-range requirement token {token!r}')
            by_requirement.setdefault(number, []).append(relative)
    return {number: sorted(set(paths)) for number, paths in by_requirement.items()}


source_evidence = load_source_evidence()

overrides = {}
if STATE.exists():
    with STATE.open(encoding='utf-8', newline='') as handle:
        reader = csv.DictReader(handle)
        required = {'rc_id','status','task_ids','tags','evidence_required','evidence_links','notes'}
        if not required.issubset(reader.fieldnames or []):
            raise SystemExit(f'Invalid requirement_state.csv columns: {reader.fieldnames}')
        for row in reader:
            rc_id = row['rc_id'].strip()
            if not rc_id:
                continue
            match = re.fullmatch(r'RC-(\d{4})', rc_id)
            if not match:
                raise SystemExit(f'Invalid state rc_id: {rc_id}')
            number = int(match.group(1))
            if not 1 <= number <= 1442:
                raise SystemExit(f'Out-of-range state rc_id: {rc_id}')
            if number in overrides:
                raise SystemExit(f'Duplicate state row: {rc_id}')
            if row['status'] not in VALID_STATUSES:
                raise SystemExit(f'Invalid status for {rc_id}: {row["status"]}')
            if not row['task_ids'].strip():
                raise SystemExit(f'Missing task_ids for {rc_id}')
            if row['status'] == 'DONE':
                if row['evidence_required'].strip() in {'', 'TBD'}:
                    raise SystemExit(f'DONE without defined evidence: {rc_id}')
                if not row['evidence_links'].strip():
                    raise SystemExit(f'DONE without evidence link: {rc_id}')
            overrides[number] = row

OUT.parent.mkdir(parents=True, exist_ok=True)
columns = ['rc_id','requirement_number','source_file','requirement_text','status','task_ids','tags','evidence_required','evidence_links','notes']
with OUT.open('w', encoding='utf-8', newline='') as handle:
    writer = csv.DictWriter(handle, fieldnames=columns, lineterminator='\n')
    writer.writeheader()
    for number, source, text in items:
        auto_tags, auto_evidence = classify(number, text)
        current = overrides.get(number, {})
        evidence_paths = source_evidence.get(number, [])
        explicit_status = current.get('status', '').strip()
        status = explicit_status or ('IMPLEMENTED' if evidence_paths else 'NOT_STARTED')
        tags = current.get('tags', '').strip() or auto_tags
        evidence_required = current.get('evidence_required', '').strip() or auto_evidence
        explicit_links = current.get('evidence_links', '').strip()
        evidence_links = explicit_links or '|'.join(evidence_paths)
        notes = current.get('notes', '').strip()
        if not notes and not explicit_status and evidence_paths:
            notes = 'IMPLEMENTED auto-derived from SOURCE_LEVEL_IMPLEMENTED evidence; not proof of TESTED/VERIFIED/DONE.'
        if tags in {'', 'UNCLASSIFIED'}:
            raise SystemExit(f'Unclassified requirement: RC-{number:04d}')
        if evidence_required in {'', 'TBD'}:
            raise SystemExit(f'Undefined evidence contract: RC-{number:04d}')
        if status in {'IMPLEMENTED', 'TESTED', 'VERIFIED', 'DONE'} and not evidence_links:
            raise SystemExit(f'{status} without evidence link: RC-{number:04d}')
        writer.writerow({
            'rc_id': f'RC-{number:04d}',
            'requirement_number': number,
            'source_file': source,
            'requirement_text': text,
            'status': status,
            'task_ids': current.get('task_ids', f'TASK-RC-{number:04d}'),
            'tags': tags,
            'evidence_required': evidence_required,
            'evidence_links': evidence_links,
            'notes': notes,
        })

implemented_from_evidence = sum(1 for n in range(1, 1443) if n in source_evidence and n not in overrides)
print(
    f'OK: wrote {len(items)} classified rows to {OUT.relative_to(ROOT)}; '
    f'state overrides={len(overrides)}; auto IMPLEMENTED from source evidence={implemented_from_evidence}'
)
