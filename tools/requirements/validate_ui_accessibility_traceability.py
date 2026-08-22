#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
ADDENDUM = ROOT / 'RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md'
EVIDENCE = (
    ROOT / 'evidence/ui/design_token_contrast_contract.json',
    ROOT / 'evidence/ui/runtime_theme_token_contract.json',
    ROOT / 'evidence/ui/accessibility_text_scale_contract.json',
    ROOT / 'evidence/ui/critical_semantics_contract.json',
)


def master_item(number: int) -> str:
    text = MASTER.read_text(encoding='utf-8') + '\n' + ADDENDUM.read_text(encoding='utf-8')
    match = re.search(rf'^{number}\.\s+(.+)$', text, re.MULTILINE)
    if match is None:
        raise AssertionError(f'RC-{number:04d} missing from MASTER')
    return match.group(1).strip()


def requirements(path: Path) -> set[str]:
    payload = json.loads(path.read_text(encoding='utf-8'))
    values = payload.get('requirements', payload.get('requirement_ids'))
    if not isinstance(values, list) or not values:
        raise AssertionError(f'{path.relative_to(ROOT)}: requirements[] is required')
    return set(values)


rc1441 = master_item(1441)
for keyword in ('Accessibility', 'dokunma', 'kontrast', 'screen-reader', 'font'):
    if keyword.casefold() not in rc1441.casefold():
        raise AssertionError(
            f'RC-1441 MASTER ownership drift: missing expected keyword {keyword!r}: {rc1441}'
        )

for path in EVIDENCE:
    if not path.is_file():
        raise AssertionError(f'missing UI accessibility evidence: {path.relative_to(ROOT)}')
    actual = requirements(path)
    if actual != {'RC-1441'}:
        raise AssertionError(
            f'{path.relative_to(ROOT)} must own exact RC-1441 only; got {sorted(actual)}'
        )

print(f'OK: {len(EVIDENCE)} UI accessibility evidence contracts retain exact MASTER RC-1441 ownership')
