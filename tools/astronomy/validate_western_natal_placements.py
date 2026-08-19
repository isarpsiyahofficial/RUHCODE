#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'evidence/astronomy/western_natal_placements.json'
SOURCE = ROOT / 'lib/src/calculation_core/western/natal_placements.dart'
TEST = ROOT / 'test/calculation_core/western/natal_placements_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(MANIFEST.exists(), 'missing Western natal placements manifest')
    require(SOURCE.exists(), 'missing Western natal placements source')
    require(TEST.exists(), 'missing Western natal placements tests')
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    require(manifest.get('contract') == 'western_natal_placements', 'wrong contract id')
    require(manifest.get('status') == 'SOURCE_LEVEL_ONLY', 'placements must remain source-level')
    require(manifest.get('physical_ephemeris_proven') is False, 'physical ephemeris proof must not be claimed')

    source = SOURCE.read_text(encoding='utf-8')
    for token in ('TropicalZodiacSign', 'houseForLongitude', 'degreeInSign', 'motion(', 'Duplicate ephemeris body'):
        require(token in source, f'missing placement source token: {token}')

    test = TEST.read_text(encoding='utf-8')
    for token in ('29.999999', '30', '359.999999', 'retrograde', 'stationary', 'throwsStateError'):
        require(token in test, f'missing placement test token: {token}')

    print('Western natal placement structural contract OK')


if __name__ == '__main__':
    main()
