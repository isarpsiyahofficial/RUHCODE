#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
FILES = [ROOT / 'RUH_CODE_MASTER_SARTNAME.md', ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md']
PATTERN = re.compile(r'^(\d+)\.\s+(.+)$')

numbers = []
for path in FILES:
    if not path.exists():
        raise SystemExit(f'Missing specification file: {path.name}')
    for line in path.read_text(encoding='utf-8').splitlines():
        match = PATTERN.match(line)
        if match:
            numbers.append(int(match.group(1)))

expected = list(range(1, 1443))
if numbers != expected:
    missing = sorted(set(expected) - set(numbers))
    duplicates = sorted({n for n in numbers if numbers.count(n) > 1})
    raise SystemExit(f'Invalid requirement sequence. missing={missing} duplicates={duplicates} count={len(numbers)}')

print('OK: RC-0001 through RC-1442 are present exactly once and in order.')
