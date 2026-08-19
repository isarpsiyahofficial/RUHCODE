#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'evidence/astronomy/western_natal_aspects.json'
SOURCE = ROOT / 'lib/src/calculation_core/western/natal_aspects.dart'
CHART = ROOT / 'lib/src/calculation_core/western/natal_chart.dart'
TEST = ROOT / 'test/calculation_core/western/natal_aspects_test.dart'
CHART_TEST = ROOT / 'test/calculation_core/western/natal_chart_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path, label in ((MANIFEST, 'manifest'), (SOURCE, 'source'), (CHART, 'chart source'), (TEST, 'tests'), (CHART_TEST, 'chart tests')):
        require(path.exists(), f'missing Western natal aspect {label}')

    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    require(manifest.get('contract') == 'western_natal_aspects', 'wrong contract id')
    require(manifest.get('status') == 'SOURCE_LEVEL_ONLY', 'aspects must remain source-level before physical proof')
    require(manifest.get('physical_ephemeris_proven') is False, 'physical ephemeris proof must not be claimed')
    require(manifest.get('independent_accuracy_proven') is False, 'independent accuracy proof must not be claimed')

    source = SOURCE.read_text(encoding='utf-8')
    for token in ('MajorAspect', 'conjunction(0)', 'sextile(60)', 'square(90)', 'trine(120)', 'opposition(180)', 'AspectOrbPolicy', '_shortestSeparation'):
        require(token in source, f'missing aspect source token: {token}')

    test = TEST.read_text(encoding='utf-8')
    for token in ('359', '91.000001', 'custom orb policy', 'throwsStateError'):
        require(token in test, f'missing aspect test token: {token}')

    chart = CHART.read_text(encoding='utf-8')
    require('WesternNatalChartAssembler' in chart, 'missing natal chart assembler')
    require('provenance mismatch' in chart, 'missing chart provenance guard')
    require('WesternNatalAspects.build' in chart, 'chart does not bind aspect engine')

    print('Western natal aspect structural contract OK')


if __name__ == '__main__':
    main()
