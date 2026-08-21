#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'evidence/numerology/golden_vectors_v1.json'
TEST = ROOT / 'test/calculation_core/numerology/golden_vectors_test.dart'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    if not DATA.exists() or not TEST.exists():
        fail('Numerology golden dataset or test is missing')

    doc = json.loads(DATA.read_text(encoding='utf-8'))
    if doc.get('schemaVersion') != 1:
        fail('Unexpected numerology golden schemaVersion')
    provenance = doc.get('provenance', {})
    if provenance.get('type') != 'hand-calculated-independent-fixtures':
        fail('Golden vectors must declare independent hand-calculated provenance')
    if not str(provenance.get('rule', '')).strip():
        fail('Golden vectors need an explicit provenance rule')

    sections = {'pythagorean': 2, 'chaldean': 2, 'loShu': 2}
    ids = set()
    for key, minimum in sections.items():
        vectors = doc.get(key)
        if not isinstance(vectors, list) or len(vectors) < minimum:
            fail(f'{key} needs at least {minimum} independent fixtures')
        for vector in vectors:
            vid = vector.get('id')
            if not vid or vid in ids:
                fail(f'Missing or duplicate vector id: {vid}')
            ids.add(vid)
            if not str(vector.get('manualDerivation', '')).strip() and key != 'pythagorean':
                fail(f'{vid} needs manualDerivation')
            if key == 'pythagorean':
                derivation = vector.get('manualDerivation')
                if not isinstance(derivation, dict) or len(derivation) < 6:
                    fail(f'{vid} needs explicit manual derivations for core metrics')

    leap = [v for v in doc['loShu'] if v.get('birthDate') == '2028-02-29']
    if len(leap) != 1:
        fail('Lo Shu golden vectors must include exactly one 2028-02-29 fixture')
    if leap[0]['expectedCounts'].get('2') != 4:
        fail('Leap-day fixture must preserve four digit-2 occurrences')

    test_text = TEST.read_text(encoding='utf-8')
    for token in [
        'PythagoreanProfileEngine.calculate',
        'ChaldeanNameEngine.calculate',
        'LoShuGridEngine.calculate',
        'golden_vectors_v1.json',
    ]:
        if token not in test_text:
            fail(f'Golden test missing token: {token}')

    print(f'Numerology golden vectors: OK ({len(ids)} fixtures)')


if __name__ == '__main__':
    main()
