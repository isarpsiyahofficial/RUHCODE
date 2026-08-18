#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'requirements/reference_manifests/vedic_daily_runtime.json'
ENGINE = ROOT / 'lib/src/calculation_core/vedic/vedic_daily_indicators.dart'
FACTOR = ROOT / 'lib/src/calculation_core/daily/vedic_indicator_factor.dart'
TEST = ROOT / 'test/calculation_core/vedic_daily_indicators_test.dart'
FACTOR_TEST = ROOT / 'test/calculation_core/vedic_indicator_daily_factor_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (MANIFEST, ENGINE, FACTOR, TEST, FACTOR_TEST):
        require(path.exists(), f'missing required Vedic daily contract file: {path}')

    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    requirements = manifest['requirements']
    require(manifest['proven'] is False, 'Vedic daily contract must stay unproven until physical evidence exists')
    require(requirements['nakshatra_count'] == 27, 'nakshatra count must be 27')
    require(requirements['pada_per_nakshatra'] == 4, 'pada count must be 4')
    require(requirements['tithi_count'] == 30, 'tithi count must be 30')
    require(requirements['tithi_span_degrees'] == 12.0, 'tithi span must be 12 degrees')
    require(requirements['runtime_network_required'] is False, 'Vedic daily runtime must remain offline')
    require(requirements['silent_fallback_forbidden'] is True, 'silent fallback must remain forbidden')

    engine = ENGINE.read_text(encoding='utf-8')
    factor = FACTOR.read_text(encoding='utf-8')
    tests = TEST.read_text(encoding='utf-8')

    for token in (
        '360.0 / 27.0',
        '_nakshatraSpanDegrees / 4.0',
        '_tithiSpanDegrees = 12.0',
        'VedicPaksha.shukla',
        'VedicPaksha.krishna',
        'ayanamshaId',
        'ayanamshaVersion',
        'sourceId',
        'sourceVersion',
    ):
        require(token in engine, f'Vedic engine missing contract token: {token}')

    require('DailyFactorKind.vedicIndicator' in factor, 'DailySnapshot Vedic factor binding missing')
    require('359.999999' in tests, '360-degree boundary regression missing')
    require('throwsArgumentError' in tests, 'provenance validation regression missing')

    print('Vedic daily contract: OK (source-level, not physically proven)')


if __name__ == '__main__':
    main()
