#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/numerology/chaldean_name.json'
SOURCE = ROOT / 'lib/src/calculation_core/numerology/chaldean_name.dart'
TEST = ROOT / 'test/calculation_core/numerology/chaldean_name_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(EVIDENCE.exists(), 'Missing Chaldean evidence manifest.')
    require(SOURCE.exists(), 'Missing Chaldean source.')
    require(TEST.exists(), 'Missing Chaldean tests.')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    require(data.get('contractId') == 'NUM-CHALDEAN-NAME-V1', 'Unexpected contract id.')
    require(data.get('done') is False, 'Chaldean contract cannot be DONE before exact test/reference proof.')
    require(data.get('policy', {}).get('pythagoreanLetterTableReuse') is False, 'Chaldean must not reuse the Pythagorean letter table.')

    requirements = set(data.get('requirements', []))
    require('RC-0184' in requirements, 'Missing explicit RC-0184 separation mapping.')

    source = SOURCE.read_text(encoding='utf-8')
    require('ChaldeanNameEngine' in source, 'Missing Chaldean engine.')
    require('static const Map<String, int> letterValues' in source, 'Missing independent Chaldean table.')
    require('PythagoreanProfileEngine.letterValue' not in source, 'Chaldean engine must not call the Pythagorean letter table.')
    for token in ("'A': 1", "'B': 2", "'C': 3", "'D': 4", "'E': 5", "'U': 6", "'O': 7", "'F': 8"):
        require(token in source, f'Missing Chaldean mapping anchor: {token}')

    tests = TEST.read_text(encoding='utf-8')
    require('compoundTotal, 42' in tests, 'Exact Chaldean Turkish-name regression missing.')
    require("letterValue('I'), 1" in tests, 'Pythagorean-separation regression missing.')

    print('Chaldean name structural contract: OK')


if __name__ == '__main__':
    main()
