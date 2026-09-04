#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0008_rc0010_time_determinism_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/time/time_zone_runtime.dart'
DAILY = ROOT / 'lib/src/calculation_core/time/daily_date_context.dart'
TEST = ROOT / 'test/calculation_core/time_zone_runtime_test.dart'
DAILY_TEST = ROOT / 'test/calculation_core/daily_date_context_test.dart'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f'RC-0008/0009/0010 FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    runtime = RUNTIME.read_text(encoding='utf-8')
    daily = DAILY.read_text(encoding='utf-8')
    tests = TEST.read_text(encoding='utf-8')
    daily_tests = DAILY_TEST.read_text(encoding='utf-8')

    require(set(contract['binding_requirements']) == {'RC-0008', 'RC-0009', 'RC-0010'}, 'binding requirement set drifted')

    # RC-0009: production runtime must use the bundled IANA tz database.
    require("package:timezone/data/latest_all.dart" in runtime, 'latest_all IANA tzdb import missing')
    require("package:timezone/timezone.dart" in runtime, 'timezone runtime import missing')
    require("databaseVersion = '2025c'" in runtime, 'declared tzdb version changed without contract update')
    require('initializeTimeZones()' in runtime, 'IANA database initialization missing')
    require('tz.getLocation(zoneId)' in runtime, 'IANA zone-id lookup missing')

    # RC-0008: calculation core must not derive its deterministic date input from the device clock.
    time_module = '\n'.join(p.read_text(encoding='utf-8') for p in (ROOT / 'lib/src/calculation_core/time').glob('*.dart'))
    require('DateTime.now(' not in time_module, 'device wall clock DateTime.now() leaked into calculation_core/time')
    require('required DateTime utcInstant' in daily, 'DailyDateResolver does not require explicit UTC instant')
    require('if (!utcInstant.isUtc)' in daily, 'DailyDateResolver does not reject non-UTC instants')
    require('required this.zoneId' in daily, 'DailyDateContext does not preserve explicit IANA zone id')
    require("cachePartitionKey => '$dateKey|$zoneId'" in daily, 'daily cache is not partitioned by civil date + zone id')

    # RC-0010: DST gaps/folds and historical discontinuities must be explicit and tested.
    required_runtime_markers = [
        'AmbiguousLocalTimePolicy',
        'NonexistentLocalTimePolicy',
        'AmbiguousLocalTimeException',
        'NonexistentLocalTimeException',
        'LocalTimeResolutionKind.ambiguousEarlier',
        'LocalTimeResolutionKind.ambiguousLater',
        'LocalTimeResolutionKind.shiftedForward',
    ]
    for marker in required_runtime_markers:
        require(marker in runtime, f'runtime DST/history marker missing: {marker}')

    required_test_markers = [
        "America/New_York",
        "Pacific/Apia",
        "Asia/Kolkata",
        "Asia/Kathmandu",
        "Pacific/Kiritimati",
        "ambiguous fall-back time rejects unless a policy is explicit",
        "nonexistent spring-forward time rejects by default",
        "historical skipped civil day is not silently treated as valid",
    ]
    for marker in required_test_markers:
        require(marker in tests, f'historical/DST regression evidence missing: {marker}')

    require('DailyDateResolver.atUtc' in daily_tests, 'deterministic daily resolver lacks direct regression coverage')
    require('DateTime.utc(' in daily_tests, 'daily resolver test does not use an explicit UTC instant')

    print('RC-0008/RC-0009/RC-0010 PASS: deterministic explicit time inputs, bundled IANA tzdb, DST/history fail-closed contract present.')


if __name__ == '__main__':
    main()
