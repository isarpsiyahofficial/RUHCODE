#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0023'
CONTRACT = ROOT / 'requirements/contracts/rc0023_western_engine_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
ENGINE = ROOT / 'lib/src/calculation_core/western/western_astrology_engine.dart'
TEST = ROOT / 'test/calculation_core/western/western_astrology_engine_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)

    require(contract['rcId'] == RC_ID, 'RC-0023 contract id mismatch')
    require(
        contract['bindingRequirementSha256'] == row['source_text_sha256'],
        'RC-0023 binding SHA mismatch',
    )

    engine = ENGINE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')

    for marker in (
        'final class WesternAstrologyEngine',
        'implements CalculationEngine<WesternAstrologyInput, WesternNatalChart>',
        "String get engineId => 'western-astrology'",
        'WesternNatalChartAssembler.build(',
        'CalculationResult<WesternNatalChart>',
        "input.manifest.engineId != engineId",
        'chart.dataVersion != input.manifest.dataVersion',
    ):
        require(marker in engine, f'RC-0023 engine marker missing: {marker}')

    require('DateTime.now()' not in engine, 'RC-0023 engine must not depend on device clock')
    require('../vedic/' not in engine, 'RC-0023 western engine must not import Vedic calculation code')
    require('../chinese/' not in engine, 'RC-0023 western engine must not import Chinese calculation code')
    require('../bazi/' not in engine, 'RC-0023 western engine must not import BaZi calculation code')
    require('../numerology/' not in engine, 'RC-0023 western engine must not import numerology calculation code')

    for marker in (
        "dedicated western engine assembles a WesternNatalChart",
        "fails closed on a foreign engine manifest",
        "fails closed on ephemeris/manifest data-version mismatch",
    ):
        require(marker in test, f'RC-0023 compiled regression missing: {marker}')

    print('RC-0023 western engine contract: PASS')


if __name__ == '__main__':
    main()
