#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0024'
CONTRACT = ROOT / 'requirements/contracts/rc0024_vedic_engine_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
ENGINE = ROOT / 'lib/src/calculation_core/vedic/vedic_astrology_engine.dart'
TEST = ROOT / 'test/calculation_core/vedic/vedic_astrology_engine_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)

    require(contract['rcId'] == RC_ID, 'RC-0024 contract id mismatch')
    require(
        contract['bindingRequirementSha256'] == row['source_text_sha256'],
        'RC-0024 binding SHA mismatch',
    )

    engine = ENGINE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')

    for marker in (
        'final class VedicAstrologyEngine',
        'implements CalculationEngine<VedicAstrologyInput, VedicChart>',
        "String get engineId => 'vedic-astrology'",
        "manifest.zodiacSystemId != 'sidereal'",
        'manifest.ayanamshaId',
        'state.longitudeDegrees - input.ayanamshaDegrees',
        'CalculationResult<VedicChart>',
        'state.sourceId != first.sourceId',
        'state.dataVersion != first.dataVersion',
        '!seenBodies.add(state.body)',
    ):
        require(marker in engine, f'RC-0024 engine marker missing: {marker}')

    require('DateTime.now()' not in engine, 'RC-0024 engine must not depend on device clock')
    require('../western/' not in engine, 'RC-0024 Vedic engine must not import western calculation code')
    require('../chinese/' not in engine, 'RC-0024 Vedic engine must not import Chinese calculation code')
    require('../bazi/' not in engine, 'RC-0024 Vedic engine must not import BaZi calculation code')
    require('../numerology/' not in engine, 'RC-0024 Vedic engine must not import numerology calculation code')

    for marker in (
        'is a separate CalculationEngine with a Vedic engine id',
        'converts explicit tropical states to normalized sidereal placements',
        'rejects a foreign engine manifest',
        'requires explicit sidereal and ayanamsha manifest identity',
        'rejects invalid ayanamsha and provenance mismatches',
        'rejects duplicate bodies instead of silently overwriting them',
    ):
        require(marker in test, f'RC-0024 compiled regression missing: {marker}')

    print('RC-0024 Vedic engine contract: PASS')


if __name__ == '__main__':
    main()
