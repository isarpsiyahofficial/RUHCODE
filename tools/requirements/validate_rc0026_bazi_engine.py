#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0026'
CONTRACT = ROOT / 'requirements/contracts/rc0026_bazi_engine_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
ENGINE = ROOT / 'lib/src/calculation_core/bazi/bazi_engine.dart'
TEST = ROOT / 'test/calculation_core/bazi/bazi_engine_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)
    require(contract['rcId'] == RC_ID, 'RC-0026 contract id mismatch')
    require(contract['bindingRequirementSha256'] == row['source_text_sha256'], 'RC-0026 binding SHA mismatch')

    engine = ENGINE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    for marker in (
        'final class BaZiEngine',
        'implements CalculationEngine<BaZiInput, BaZiChart>',
        "String get engineId => 'bazi'",
        "_validated(input.year, 'year')",
        "_validated(input.month, 'month')",
        "_validated(input.day, 'day')",
        "_validated(input.hour, 'hour')",
        'input.stemIndex < 0 || input.stemIndex > 9',
        'input.branchIndex < 0 || input.branchIndex > 11',
        'input.manifest.engineId != engineId',
    ):
        require(marker in engine, f'RC-0026 engine marker missing: {marker}')

    for forbidden in ('DateTime.now()', '../western/', '../vedic/', '../chinese/'):
        require(forbidden not in engine, f'RC-0026 forbidden coupling found: {forbidden}')

    for marker in (
        'uses a BaZi-specific CalculationEngine identity',
        'preserves four independently supplied validated pillars',
        'rejects foreign and invalid manifests',
        'rejects invalid stem and branch indices',
    ):
        require(marker in test, f'RC-0026 compiled regression missing: {marker}')

    print('RC-0026 BaZi engine contract: PASS')


if __name__ == '__main__':
    main()
