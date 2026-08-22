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


def srgb_channel(value: int) -> float:
    channel = value / 255.0
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def relative_luminance(hex_color: str) -> float:
    raw = hex_color.lstrip('#')
    red = srgb_channel(int(raw[0:2], 16))
    green = srgb_channel(int(raw[2:4], 16))
    blue = srgb_channel(int(raw[4:6], 16))
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def contrast_ratio(first: str, second: str) -> float:
    l1 = relative_luminance(first)
    l2 = relative_luminance(second)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


contrast = data.get('accessibilityContrast', {})
normal_minimum = float(contrast.get('normalTextMinimumRatio', 0))
large_minimum = float(contrast.get('largeTextMinimumRatio', 0))
if normal_minimum < 4.5:
    print('ERROR: normal text contrast minimum must be at least 4.5:1', file=sys.stderr)
    raise SystemExit(1)
if large_minimum < 3.0:
    print('ERROR: large text contrast minimum must be at least 3.0:1', file=sys.stderr)
    raise SystemExit(1)

colors = data['colors']
required_pairs = contrast.get('requiredNormalTextPairs', [])
if not required_pairs:
    print('ERROR: required normal-text contrast pairs must not be empty', file=sys.stderr)
    raise SystemExit(1)
for pair in required_pairs:
    if not isinstance(pair, list) or len(pair) != 2:
        print(f'ERROR: invalid contrast pair {pair!r}', file=sys.stderr)
        raise SystemExit(1)
    foreground, background = pair
    if foreground not in colors or background not in colors:
        print(f'ERROR: contrast pair references unknown token {pair!r}', file=sys.stderr)
        raise SystemExit(1)
    ratio = contrast_ratio(colors[foreground], colors[background])
    if ratio + 1e-9 < normal_minimum:
        print(
            f'ERROR: normal-text contrast fails for {foreground}/{background}: '
            f'{ratio:.2f}:1 < {normal_minimum:.2f}:1',
            file=sys.stderr,
        )
        raise SystemExit(1)

light_surfaces = contrast.get('lightSurfaceTokens', [])
non_text_tokens = contrast.get('nonTextAccentTokensOnLightSurfaces', [])
if set(light_surfaces) != {'background', 'surface', 'surfaceSoft'}:
    print('ERROR: light-surface token contract drift', file=sys.stderr)
    raise SystemExit(1)
if not {'gold', 'success'}.issubset(set(non_text_tokens)):
    print('ERROR: gold and success must remain non-text accents on light surfaces', file=sys.stderr)
    raise SystemExit(1)
for token in non_text_tokens:
    if token not in colors:
        print(f'ERROR: non-text accent references unknown token {token}', file=sys.stderr)
        raise SystemExit(1)
    for surface in light_surfaces:
        ratio = contrast_ratio(colors[token], colors[surface])
        if ratio >= normal_minimum:
            print(
                f'ERROR: {token}/{surface} now meets normal-text contrast ({ratio:.2f}:1); '
                'review whether its non-text-only restriction is still necessary instead of silently keeping stale policy',
                file=sys.stderr,
            )
            raise SystemExit(1)

print(
    'Design tokens OK: colors=11 spacing=6 minTouch=48dp nav=4 fontContracts=3 '
    f'normalContrastPairs={len(required_pairs)} normalMin={normal_minimum:.1f}:1 '
    f'nonTextAccents={len(non_text_tokens)}'
)