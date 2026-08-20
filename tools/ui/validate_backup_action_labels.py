#!/usr/bin/env python3
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / 'ui/action_registry.csv'

rows = list(csv.DictReader(REGISTRY.open(encoding='utf-8', newline='')))
by_id = {row['action_id'].strip(): row for row in rows}

required = {
    'ACTION-BACKUP-EXPORT': ('Tam Yedek Oluştur', 'EFFECT:EXPORT_FULL_BACKUP'),
    'ACTION-BACKUP-IMPORT': ('Yedekten Geri Yükle', 'SCR-BACKUP-IMPORT-001'),
}

errors = []
for action_id, (label, target) in required.items():
    row = by_id.get(action_id)
    if row is None:
        errors.append(f'missing backup action {action_id}')
        continue
    if row['label_or_purpose'].strip() != label:
        errors.append(f'{action_id} must use label {label!r}')
    if row['target_screen_id_or_effect'].strip() != target:
        errors.append(f'{action_id} must target {target!r}')
    if row['offline_behavior'].strip() != 'AVAILABLE':
        errors.append(f'{action_id} must remain fully offline')

legacy_visible = {'CSV Dışa Aktar', 'CSV İçe Aktar'}
for row in rows:
    if row['label_or_purpose'].strip() in legacy_visible:
        errors.append(
            f"legacy CSV-only wording remains visible in {row['action_id']}: {row['label_or_purpose']}"
        )

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Portable backup action wording OK: full .ruhcode.zip backup is not mislabeled as CSV-only.')
