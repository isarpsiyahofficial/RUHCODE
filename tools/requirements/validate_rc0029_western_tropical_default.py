#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0029'
CONTRACT = ROOT / 'requirements/contracts/rc0029_western_tropical_default_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
SOURCE = ROOT / 'lib/src/calculation_core/western/natal_placements.dart'
TEST = ROOT / 'test/calculation_core/western/natal_placements_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)
    require(contract['rcId'] == RC_ID, 'RC-0029 contract id mismatch')
    require(contract['bindingRequirementSha256'] == row['source_text_sha256'], 'RC-0029 binding SHA mismatch')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0029 promotion ceiling weakened')
    require(SOURCE.is_file(), 'RC-0029 production file missing')
    require(TEST.is_file(), 'RC-0029 compiled test file missing')

    source = SOURCE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    require('enum TropicalZodiacSign' in source, 'RC-0029 explicit Tropical zodiac enum missing')
    require('final signIndex = (state.longitudeDegrees / 30.0).floor();' in source, 'RC-0029 tropical 30-degree mapping missing')
    require('TropicalZodiacSign.values[signIndex]' in source, 'RC-0029 placement does not use Tropical zodiac mapping')
    lowered = source.lower()
    require('ayanamsha' not in lowered and 'sidereal' not in lowered, 'RC-0029 Western default must not apply sidereal/ayanamsha offset')
    for marker in (
        'state(AstroBody.sun, 0)',
        'state(AstroBody.mercury, 30)',
        'state(AstroBody.venus, 359.999999)',
        'TropicalZodiacSign.aries',
        'TropicalZodiacSign.taurus',
        'TropicalZodiacSign.pisces',
    ):
        require(marker in test, f'RC-0029 boundary regression missing: {marker}')

    print('RC-0029 Western Tropical default contract: PASS')


if __name__ == '__main__':
    main()
