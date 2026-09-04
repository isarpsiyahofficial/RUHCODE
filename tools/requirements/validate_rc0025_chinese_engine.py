#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0025'
CONTRACT = ROOT / 'requirements/contracts/rc0025_chinese_engine_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
ENGINE = ROOT / 'lib/src/calculation_core/chinese/chinese_astrology_engine.dart'
TEST = ROOT / 'test/calculation_core/chinese/chinese_astrology_engine_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)
    require(contract['rcId'] == RC_ID, 'RC-0025 contract id mismatch')
    require(contract['bindingRequirementSha256'] == row['source_text_sha256'], 'RC-0025 binding SHA mismatch')

    engine = ENGINE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    for marker in (
        'final class ChineseAstrologyEngine',
        'implements CalculationEngine<ChineseAstrologyInput, ChineseYearCycle>',
        "String get engineId => 'chinese-astrology'",
        'static const int _jiaZiReferenceYear = 1984',
        '_floorMod(input.cycleYear - _jiaZiReferenceYear, 60)',
        'heavenlyStemIndex: sexagenaryIndex % 10',
        'earthlyBranchIndex: sexagenaryIndex % 12',
        'manifest.engineId != engineId',
        'manifest.validity != CalculationValidity.valid',
    ):
        require(marker in engine, f'RC-0025 engine marker missing: {marker}')

    for forbidden in ('DateTime.now()', '../western/', '../vedic/', '../bazi/'):
        require(forbidden not in engine, f'RC-0025 forbidden coupling found: {forbidden}')
    require('Chinese New Year' in engine, 'RC-0025 source must explicitly document calendar-boundary ownership')

    for marker in (
        'is a separate CalculationEngine with Chinese engine identity',
        'maps the 1984 Jia-Zi reference year to cycle index zero',
        'maps 2024 deterministically within the 60-year cycle',
        'normalizes pre-reference years with floor-mod semantics',
        'rejects foreign engine and invalid calculation manifests',
        'rejects cycle years outside the explicitly supported range',
    ):
        require(marker in test, f'RC-0025 compiled regression missing: {marker}')

    print('RC-0025 Chinese engine contract: PASS')


if __name__ == '__main__':
    main()
