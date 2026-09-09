from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1273_rc1285_design_system_contract.json'
DART = ROOT / 'lib/src/ui/theme/ruh_design_tokens.dart'
TOKENS = ROOT / 'ui/design_tokens.json'
TEST = ROOT / 'test/ui/ruh_design_system_rc1273_rc1285_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')

try:
    contract = json.loads(read(CONTRACT))
    dart = read(DART)
    tokens = json.loads(read(TOKENS))
    test = read(TEST)
    expected = [f'RC-{i:04d}' for i in range(1273, 1286)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'RuhTypographyTokens', 'static const TextStyle title',
        'static const TextStyle section', 'static const TextStyle body',
        'static const TextStyle caption', 'paragraphSpacing', 'sectionSpacing',
        'cardPadding', 'screenEdgePadding', 'pdfEdgePadding', 'chartLegendGap',
        'chartLegendItemGap', 'chartLabelMinimumFontSize', 'darkBackground',
        'darkTextPrimary', 'darkTextMuted', 'static ThemeData dark()',
    ):
        assert token in dart, f'missing production design-system token: {token}'

    semantics = tokens['typography']['semanticClasses']
    assert list(semantics.keys()) == ['title', 'section', 'body', 'caption']
    assert semantics['body']['fontSizeSp'] >= 16
    assert tokens['typography']['chartLabelMinimumSp'] >= 13
    spacing = tokens['spacingDp']
    for key in ('paragraph', 'section', 'cardPadding', 'screenEdgePadding', 'pdfEdgePadding', 'chartLegendGap', 'chartLegendItemGap'):
        assert spacing[key] > 0, f'invalid spacing token {key}'
    assert tokens['accessibilityContrast']['normalTextMinimumRatio'] >= 4.5
    assert len(tokens['accessibilityContrast']['requiredDarkTextPairs']) >= 4

    for phrase in (
        'title section body caption are explicit and visibly distinct',
        'baseline line heights and semantic spacing are explicit',
        'light mode normal text contrast meets WCAG AA 4.5',
        'dark mode normal text contrast meets WCAG AA 4.5',
        'light and dark themes expose semantic text classes',
    ):
        assert phrase in test, f'missing regression phrase: {phrase}'

except (AssertionError, KeyError, TypeError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1273_RC1285_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1273_RC1285_OK')
