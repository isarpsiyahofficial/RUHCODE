#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'evidence/astronomy/western_natal_distribution.json'
SOURCE = ROOT / 'lib/src/calculation_core/western/natal_distribution.dart'
TEST = ROOT / 'test/calculation_core/western/natal_distribution_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(MANIFEST.exists(), 'missing Western natal distribution manifest')
    require(SOURCE.exists(), 'missing Western natal distribution source')
    require(TEST.exists(), 'missing Western natal distribution tests')

    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    require(manifest.get('contract') == 'western_natal_distribution', 'wrong contract id')
    require(manifest.get('status') == 'SOURCE_LEVEL_ONLY', 'distribution must remain source-level before physical proof')
    require(manifest.get('physical_ephemeris_proven') is False, 'physical ephemeris proof must not be claimed')

    source = SOURCE.read_text(encoding='utf-8')
    for token in ('WesternElement', 'WesternModality', 'PlacementWeightPolicy', 'elementPercent', 'modalityPercent', 'all zero'):
        require(token.lower() in source.lower(), f'missing distribution source token: {token}')

    test = TEST.read_text(encoding='utf-8')
    for token in ('Aries: fire/cardinal', 'Taurus: earth/fixed', 'Gemini: air/mutable', 'Cancer: water/cardinal', 'all-zero'):
        require(token in test, f'missing distribution test token: {token}')

    print('Western natal distribution structural contract OK')


if __name__ == '__main__':
    main()
