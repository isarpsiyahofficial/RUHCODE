#!/usr/bin/env python3
import csv
import sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
P = R / 'ui/asset_manifest.csv'
REQUIRED = {'LOGO','ZODIAC_GLYPHS','PLANET_GLYPHS','DECORATIVE_GEOMETRY','ICON_SET','TAROT_ART','FONT_SANS','FONT_SERIF','FONT_SYMBOL'}
FONT_IDS = {'ASSET-FONT-SANS-PRIMARY','ASSET-FONT-SERIF-REPORT','ASSET-FONT-SYMBOL-FALLBACK'}

if not P.is_file():
    print('ERROR: missing asset manifest', file=sys.stderr)
    raise SystemExit(1)
rows = list(csv.DictReader(P.open(encoding='utf-8', newline='')))
ids = [r['asset_id'].strip() for r in rows]
if len(ids) != len(set(ids)):
    print('ERROR: duplicate asset ids', file=sys.stderr)
    raise SystemExit(1)
categories = {r['category'].strip() for r in rows}
missing = sorted(REQUIRED - categories)
if missing:
    print('ERROR: missing required asset categories: ' + ', '.join(missing), file=sys.stderr)
    raise SystemExit(1)
missing_fonts = sorted(FONT_IDS - set(ids))
if missing_fonts:
    print('ERROR: missing font contracts: ' + ', '.join(missing_fonts), file=sys.stderr)
    raise SystemExit(1)
for r in rows:
    status = r['approval_status'].strip()
    if status not in {'PENDING','APPROVED','REJECTED'}:
        print('ERROR: invalid status for ' + r['asset_id'], file=sys.stderr)
        raise SystemExit(1)
    if status == 'APPROVED' and (not r['path'].strip() or not r['sha256'].strip() or r['license'].strip() in {'','TBD'} or not r['provenance'].strip()):
        print('ERROR: approved asset lacks path/hash/license/provenance: ' + r['asset_id'], file=sys.stderr)
        raise SystemExit(1)
print(f'Static asset contracts OK: assets={len(rows)} required_categories={len(REQUIRED)} font_contracts={len(FONT_IDS)}')
