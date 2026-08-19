#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'evidence/astronomy/western_asc_mc.json'
SOURCE = ROOT / 'lib/src/calculation_core/western/asc_mc.dart'
TEST = ROOT / 'test/calculation_core/western/asc_mc_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(MANIFEST.exists(), 'missing Western ASC/MC manifest')
    require(SOURCE.exists(), 'missing Western ASC/MC source')
    require(TEST.exists(), 'missing Western ASC/MC tests')

    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    require(manifest.get('contract') == 'western_asc_mc', 'wrong contract id')
    require(manifest.get('status') == 'SOURCE_LEVEL_ONLY', 'ASC/MC must remain source-level until golden proof')
    accuracy = manifest.get('accuracy', {})
    require(accuracy.get('budget_degrees') == 0.05, 'ASC/MC accuracy budget must be 0.05 degrees')
    require(accuracy.get('independent_golden_proven') is False, 'golden proof must not be claimed yet')

    source = SOURCE.read_text(encoding='utf-8')
    for token in (
        'julianDayUt1',
        'julianDayTt',
        'meanObliquityIau2006',
        'SiderealTime.greenwichMeanHours',
        'ascendantDegrees',
        'midheavenDegrees',
    ):
        require(token in source, f'missing ASC/MC source token: {token}')

    test = TEST.read_text(encoding='utf-8')
    for token in ('90', '180', '270', 'throwsRangeError', '2451545.0'):
        require(token in test, f'missing ASC/MC boundary test token: {token}')

    print('Western ASC/MC structural contract OK')


if __name__ == '__main__':
    main()
