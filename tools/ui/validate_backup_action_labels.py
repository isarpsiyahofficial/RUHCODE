#!/usr/bin/env python3
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRIES = (
    ROOT / 'ui/action_registry.csv',
    ROOT / 'ui/action_registry_runtime_extensions.csv',
)

rows = []
for registry in REGISTRIES:
    rows.extend(csv.DictReader(registry.open(encoding='utf-8', newline='')))

by_id = {}
duplicates = []
for row in rows:
    action_id = row['action_id'].strip()
    if action_id in by_id:
        duplicates.append(action_id)
    by_id[action_id] = row

required = {
    'ACTION-BACKUP-EXPORT': ('Tam Yedek Oluştur', 'EFFECT:EXPORT_FULL_BACKUP'),
    'ACTION-BACKUP-SHARE': ('Yedeği Paylaş', 'EFFECT:SHARE_FULL_BACKUP'),
    'ACTION-BACKUP-IMPORT': ('Yedekten Geri Yükle', 'SCR-BACKUP-IMPORT-001'),
}

errors = []
if duplicates:
    errors.append('duplicate action IDs across backup registries: ' + ', '.join(sorted(duplicates)))
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
    if row['a11y_label_required'].strip().lower() != 'true':
        errors.append(f'{action_id} must require an accessibility label')
    if row['status'].strip() != 'ACTIVE':
        errors.append(f'{action_id} must remain ACTIVE')

legacy_visible = {'CSV Dışa Aktar', 'CSV İçe Aktar'}
for row in rows:
    if row['label_or_purpose'].strip() in legacy_visible:
        errors.append(
            f"legacy CSV-only wording remains visible in {row['action_id']}: {row['label_or_purpose']}"
        )

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Portable backup actions OK: create/share/restore use canonical offline .ruhcode.zip wording and a11y labels.')
