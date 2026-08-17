#!/usr/bin/env python3
from pathlib import Path
import csv
import re

ROOT = Path(__file__).resolve().parents[2]
FILES = [ROOT / 'RUH_CODE_MASTER_SARTNAME.md', ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md']
OUT = ROOT / 'requirements' / 'requirement_matrix.csv'
PATTERN = re.compile(r'^(\d+)\.\s+(.+)$')

items = []
for path in FILES:
    for line in path.read_text(encoding='utf-8').splitlines():
        match = PATTERN.match(line)
        if match:
            items.append((int(match.group(1)), path.name, match.group(2)))

if [n for n, _, _ in items] != list(range(1, 1443)):
    raise SystemExit('Binding specification is not an exact RC-0001..RC-1442 sequence')

OUT.parent.mkdir(parents=True, exist_ok=True)
columns = ['rc_id','requirement_number','source_file','requirement_text','status','task_ids','tags','evidence_required','evidence_links','notes']
with OUT.open('w', encoding='utf-8', newline='') as handle:
    writer = csv.DictWriter(handle, fieldnames=columns, lineterminator='\n')
    writer.writeheader()
    for number, source, text in items:
        writer.writerow({
            'rc_id': f'RC-{number:04d}',
            'requirement_number': number,
            'source_file': source,
            'requirement_text': text,
            'status': 'NOT_STARTED',
            'task_ids': f'TASK-RC-{number:04d}',
            'tags': 'UNCLASSIFIED',
            'evidence_required': 'TBD',
            'evidence_links': '',
            'notes': '',
        })

print(f'OK: wrote {len(items)} rows to {OUT.relative_to(ROOT)}')
