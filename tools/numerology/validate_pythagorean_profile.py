#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/numerology/pythagorean_profile.json'
SOURCE = ROOT / 'lib/src/calculation_core/numerology/pythagorean_profile.dart'
TEST = ROOT / 'test/calculation_core/numerology/pythagorean_profile_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(EVIDENCE.exists(), 'Missing Pythagorean evidence manifest.')
    require(SOURCE.exists(), 'Missing Pythagorean profile source.')
    require(TEST.exists(), 'Missing Pythagorean profile tests.')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    require(data.get('contractId') == 'NUM-PYTH-PROFILE-V1', 'Unexpected contract id.')
    require(data.get('status') == 'SOURCE_LEVEL_IMPLEMENTED', 'Unexpected source status.')
    require(data.get('done') is False, 'Pythagorean contract cannot be DONE before exact test/reference proof.')

    calculations = set(data.get('calculations', []))
    required_calculations = {
        'lifePath', 'expression', 'soulUrge', 'personality', 'birthday', 'maturity'
    }
    require(required_calculations <= calculations, 'Missing required Pythagorean calculations.')

    requirements = set(data.get('requirements', []))
    for rc in ('RC-0161', 'RC-0162', 'RC-0166', 'RC-0167', 'RC-0168', 'RC-0169', 'RC-0170', 'RC-0171', 'RC-0182', 'RC-0183'):
        require(rc in requirements, f'Missing requirement mapping: {rc}')

    source = SOURCE.read_text(encoding='utf-8')
    for token in (
        'PythagoreanNameNormalizer',
        'PythagoreanProfileEngine',
        'lifePath',
        'expression',
        'soulUrge',
        'personality',
        'birthday',
        'maturity',
        'Unsupported character',
    ):
        require(token in source, f'Missing source contract token: {token}')

    require("'İ': 'I'" in source, 'Turkish dotted-I mapping is not explicit.')
    require("'ı': 'I'" in source, 'Turkish dotless-I mapping is not explicit.')
    require("vowels = <String>{'A', 'E', 'I', 'O', 'U'}" in source, 'Vowel policy must be explicit.')

    tests = TEST.read_text(encoding='utf-8')
    require('İbrahim Yeşilyurt' in tests, 'Turkish normalization regression case missing.')
    require('Renée' in tests, 'Unsupported-character negative regression missing.')
    require('preserves master numbers only when policy requests it' in tests, 'Master-number policy regression missing.')

    print('Pythagorean profile structural contract: OK')


if __name__ == '__main__':
    main()
