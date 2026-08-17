#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
P = R / 'ui/design_tokens.json'
if not P.is_file():
    print('ERROR: missing ui/design_tokens.json', file=sys.stderr)
    raise SystemExit(1)

data = json.loads(P.read_text(encoding='utf-8'))
required_colors = {'background','surface','surfaceSoft','textPrimary','textMuted','line','primary','primaryStrong','gold','success','danger'}
missing = required_colors - set(data.get('colors', {}))
if missing:
    print('ERROR: missing colors: ' + ', '.join(sorted(missing)), file=sys.stderr)
    raise SystemExit(1)
for name, value in data['colors'].items():
    if not re.fullmatch(r'#[0-9A-Fa-f]{6}', value):
        print(f'ERROR: invalid color token {name}={value}', file=sys.stderr)
        raise SystemExit(1)
if data.get('touch', {}).get('minimumTargetDp', 0) < 48:
    print('ERROR: minimum touch target must be at least 48dp', file=sys.stderr)
    raise SystemExit(1)
if data.get('navigation', {}).get('items') != ['TODAY','TOOLS','RECORDS','PROFILE']:
    print('ERROR: bottom navigation contract drift', file=sys.stderr)
    raise SystemExit(1)
spacing = list(data.get('spacingDp', {}).values())
if sorted(spacing) != [4,8,12,16,24,32]:
    print('ERROR: spacing grid drift', file=sys.stderr)
    raise SystemExit(1)
font_ids = {
    data.get('typography', {}).get('uiFontAssetId'),
    data.get('typography', {}).get('reportSerifAssetId'),
    data.get('typography', {}).get('symbolFallbackAssetId'),
}
required_font_ids = {'ASSET-FONT-SANS-PRIMARY','ASSET-FONT-SERIF-REPORT','ASSET-FONT-SYMBOL-FALLBACK'}
if font_ids != required_font_ids:
    print('ERROR: typography asset contract drift', file=sys.stderr)
    raise SystemExit(1)
print('Design tokens OK: colors=11 spacing=6 minTouch=48dp nav=4 fontContracts=3')
