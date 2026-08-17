#!/usr/bin/env python3
import csv
import os
from collections import Counter, defaultdict
from pathlib import Path

R = Path(__file__).resolve().parents[2]
ACT = R / 'ui/action_registry.csv'
OUT = R / 'build/ui-action-coverage.csv'

rows = list(csv.DictReader(ACT.open(encoding='utf-8', newline='')))
active = [r for r in rows if r['status'].strip() == 'ACTIVE']
by_source = defaultdict(list)
for r in active:
    by_source[r['source_screen_id'].strip()].append(r)

OUT.parent.mkdir(parents=True, exist_ok=True)
fields = ['source_screen_id','active_action_count','navigation','input','toggle','calculation','data','filter','pdf','share','backup','purchase','offline_available','requires_network','offline_unavailable','a11y_required']
with OUT.open('w', encoding='utf-8', newline='') as f:
    w = csv.DictWriter(f, fieldnames=fields)
    w.writeheader()
    for source in sorted(by_source):
        rs = by_source[source]
        types = Counter(r['action_type'].strip().upper() for r in rs)
        offline = Counter(r['offline_behavior'].strip().upper() for r in rs)
        w.writerow({
            'source_screen_id': source,
            'active_action_count': len(rs),
            'navigation': types['NAVIGATION'],
            'input': types['INPUT'],
            'toggle': types['TOGGLE'],
            'calculation': types['CALCULATION'],
            'data': types['DATA'],
            'filter': types['FILTER'],
            'pdf': types['PDF'],
            'share': types['SHARE'],
            'backup': types['BACKUP'],
            'purchase': types['PURCHASE'],
            'offline_available': offline['AVAILABLE'],
            'requires_network': offline['REQUIRES_NETWORK'],
            'offline_unavailable': offline['UNAVAILABLE'],
            'a11y_required': sum(r['a11y_label_required'].strip().lower() == 'true' for r in rs),
        })

print(f'Action coverage report written: {OUT.relative_to(R)}')
print(f'ACTIVE actions={len(active)} sources={len(by_source)}')

summary = os.environ.get('GITHUB_STEP_SUMMARY')
if summary:
    with open(summary, 'a', encoding='utf-8') as f:
        f.write('## UI Action Coverage\n\n')
        f.write(f'- ACTIVE actions: **{len(active)}**\n')
        f.write(f'- Covered action sources: **{len(by_source)}**\n')
        f.write(f'- Actions requiring accessibility labels: **{sum(r["a11y_label_required"].strip().lower() == "true" for r in active)}**\n')
        f.write(f'- Offline-available actions: **{sum(r["offline_behavior"].strip() == "AVAILABLE" for r in active)}**\n')
        f.write(f'- Network-required actions: **{sum(r["offline_behavior"].strip() == "REQUIRES_NETWORK" for r in active)}**\n')
