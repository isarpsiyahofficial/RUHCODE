#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/numerology/lo_shu_grid.json'
SOURCE = ROOT / 'lib/src/calculation_core/numerology/lo_shu_grid.dart'
TEST = ROOT / 'test/calculation_core/numerology/lo_shu_grid_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(EVIDENCE.exists(), 'Missing Lo Shu evidence manifest.')
    require(SOURCE.exists(), 'Missing Lo Shu source.')
    require(TEST.exists(), 'Missing Lo Shu tests.')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    require(data.get('contractId') == 'NUM-LO-SHU-GRID-V1', 'Unexpected Lo Shu contract id.')
    require(data.get('done') is False, 'Lo Shu contract cannot be DONE before exact test/reference proof.')
    require(data.get('policy', {}).get('canonicalGrid') == [[4, 9, 2], [3, 5, 7], [8, 1, 6]], 'Canonical Lo Shu grid changed.')
    require(data.get('policy', {}).get('pythagoreanTableReuse') is False, 'Lo Shu must remain independent from Pythagorean mapping.')
    require(data.get('policy', {}).get('chaldeanTableReuse') is False, 'Lo Shu must remain independent from Chaldean mapping.')

    requirements = set(data.get('requirements', []))
    for rc in ('RC-0164', 'RC-0185'):
        require(rc in requirements, f'Missing requirement mapping: {rc}')

    source = SOURCE.read_text(encoding='utf-8')
    require('LoShuGridEngine' in source, 'Missing Lo Shu engine.')
    require('<int>[4, 9, 2]' in source, 'Canonical top Lo Shu row missing.')
    require('if (digit == 0)' in source, 'Zero handling must remain explicit.')
    require('PythagoreanProfileEngine' not in source, 'Lo Shu must not depend on Pythagorean profile math.')
    require('ChaldeanNameEngine' not in source, 'Lo Shu must not depend on Chaldean name math.')

    tests = TEST.read_text(encoding='utf-8')
    require('year: 2028, month: 2, day: 29' in tests, 'Leap-day Lo Shu regression missing.')
    require('countOf(2), 4' in tests, 'Leap-day digit-frequency regression is not exact.')

    print('Lo Shu structural contract: OK')


if __name__ == '__main__':
    main()
