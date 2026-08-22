#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
TOKENS_JSON = R / 'ui/design_tokens.json'
DART_TOKENS = R / 'lib/src/ui/theme/ruh_design_tokens.dart'
APP_THEME = R / 'lib/src/app/ruh_code_app.dart'

for path in (TOKENS_JSON, DART_TOKENS, APP_THEME):
    if not path.is_file():
        print(f'ERROR: missing required runtime-theme file: {path.relative_to(R)}', file=sys.stderr)
        raise SystemExit(1)

data = json.loads(TOKENS_JSON.read_text(encoding='utf-8'))
dart = DART_TOKENS.read_text(encoding='utf-8')
app = APP_THEME.read_text(encoding='utf-8')

# The Dart bridge must carry the exact canonical color values. This deliberately
# avoids interpreting color names semantically; equality is byte-for-byte RGB.
for name, hex_color in data.get('colors', {}).items():
    expected = '0xFF' + hex_color.lstrip('#').upper()
    pattern = rf'static\s+const\s+Color\s+{re.escape(name)}\s*=\s*Color\({expected}\);'
    if not re.search(pattern, dart):
        print(
            f'ERROR: Dart runtime token {name} does not exactly match canonical {hex_color}',
            file=sys.stderr,
        )
        raise SystemExit(1)

for name, value in data.get('radiusDp', {}).items():
    dart_name = 'radius' + name[0].upper() + name[1:]
    if not re.search(rf'static\s+const\s+double\s+{dart_name}\s*=\s*{value}(?:\.0)?\s*;', dart):
        print(f'ERROR: Dart radius token drift: {name}={value}', file=sys.stderr)
        raise SystemExit(1)
for name, value in data.get('spacingDp', {}).items():
    dart_name = 'spacing' + name[0].upper() + name[1:]
    if not re.search(rf'static\s+const\s+double\s+{dart_name}\s*=\s*{value}(?:\.0)?\s*;', dart):
        print(f'ERROR: Dart spacing token drift: {name}={value}', file=sys.stderr)
        raise SystemExit(1)
minimum_touch = data.get('touch', {}).get('minimumTargetDp')
if not re.search(
    rf'static\s+const\s+double\s+minimumTouchTarget\s*=\s*{minimum_touch}(?:\.0)?\s*;', dart
):
    print('ERROR: Dart minimum touch target drift', file=sys.stderr)
    raise SystemExit(1)

if "import '../ui/theme/ruh_design_tokens.dart';" not in app:
    print('ERROR: RuhCodeApp does not import the canonical runtime theme bridge', file=sys.stderr)
    raise SystemExit(1)
if 'theme: RuhAppTheme.light(),' not in app:
    print('ERROR: RuhCodeApp is not using RuhAppTheme.light()', file=sys.stderr)
    raise SystemExit(1)

# Presentation code must not bypass the canonical bridge with literal Flutter
# colors. The bridge itself is the only allowed location for Color(0x...) values.
scan_roots = [R / 'lib/src/ui', R / 'lib/src/app']
excluded = {DART_TOKENS.resolve()}
raw_patterns = [
    (re.compile(r'\bColor\s*\(\s*0x[0-9A-Fa-f]+\s*\)'), 'literal Color(0x...)'),
    (re.compile(r'\bColor\.from(?:ARGB|RGBO)\s*\('), 'Color.fromARGB/fromRGBO'),
    (re.compile(r'\bColors\.[A-Za-z_]\w*'), 'Material Colors.*'),
]
violations = []
for root in scan_roots:
    if not root.is_dir():
        continue
    for path in sorted(root.rglob('*.dart')):
        if path.resolve() in excluded:
            continue
        text = path.read_text(encoding='utf-8')
        for regex, label in raw_patterns:
            for match in regex.finditer(text):
                line = text.count('\n', 0, match.start()) + 1
                violations.append(
                    f'{path.relative_to(R)}:{line}: {label}: {match.group(0)}'
                )
if violations:
    print('ERROR: rendered/runtime UI bypasses canonical design tokens:', file=sys.stderr)
    for violation in violations:
        print('  ' + violation, file=sys.stderr)
    raise SystemExit(1)

print(
    'Runtime theme tokens OK: canonical JSON == Dart bridge; RuhCodeApp uses centralized theme; '
    'no raw Flutter color literals found outside token bridge'
)
