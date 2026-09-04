#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0027'
CONTRACT = ROOT / 'requirements/contracts/rc0027_numerology_independence_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
NUMEROLOGY_ROOT = ROOT / 'lib/src/calculation_core/numerology'
GOLDEN = ROOT / 'test/calculation_core/numerology/golden_vectors_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)
    require(contract['rcId'] == RC_ID, 'RC-0027 contract id mismatch')
    require(contract['bindingRequirementSha256'] == row['source_text_sha256'], 'RC-0027 binding SHA mismatch')
    require(NUMEROLOGY_ROOT.is_dir(), 'RC-0027 numerology production root missing')
    dart_files = sorted(NUMEROLOGY_ROOT.rglob('*.dart'))
    require(len(dart_files) >= 5, 'RC-0027 numerology implementation is unexpectedly incomplete')

    forbidden = tuple(contract['evidence']['forbiddenCalculationCouplings'])
    for path in dart_files:
        text = path.read_text(encoding='utf-8')
        normalized = text.replace('\\', '/')
        for marker in forbidden:
            require(marker not in normalized, f'RC-0027 forbidden astrology coupling in {path.relative_to(ROOT)}: {marker}')
        require('DateTime.now()' not in text, f'RC-0027 implicit device-time dependency in {path.relative_to(ROOT)}')

    require(GOLDEN.is_file(), 'RC-0027 compiled numerology golden regression missing')
    golden = GOLDEN.read_text(encoding='utf-8')
    for marker in ('Pythagorean', 'Chaldean', 'Lo Shu'):
        require(marker in golden, f'RC-0027 golden coverage missing numerology family: {marker}')

    print(f'RC-0027 numerology independence contract: PASS ({len(dart_files)} production files)')


if __name__ == '__main__':
    main()
