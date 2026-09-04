#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0017_julian_time_core_contract.json'
CORE = ROOT / 'lib/src/calculation_core/time/julian_day.dart'
TEST = ROOT / 'test/calculation_core/julian_day_test.dart'
REFERENCE = ROOT / 'requirements/reference_sources/julian_day.json'


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(f'RC-0017 FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    core = CORE.read_text(encoding='utf-8')
    tests = TEST.read_text(encoding='utf-8')
    reference = json.loads(REFERENCE.read_text(encoding='utf-8'))

    require(contract['binding_requirement']['rc_id'] == 'RC-0017', 'binding id drifted')
    require(contract['central_core']['implementation'] == 'lib/src/calculation_core/time/julian_day.dart', 'central implementation drifted')
    require('abstract final class JulianDay' in core, 'central JulianDay core missing')
    for marker in ('static double fromUtc', 'static double fromCivilDate', 'static double modified', 'static double centuriesSinceJ2000'):
        require(marker in core, f'central conversion missing: {marker}')
    require('if (!utcInstant.isUtc)' in core, 'UTC input discipline missing')
    require('2451545.0' in core, 'J2000 epoch basis missing')
    require(reference.get('authority') == 'U.S. Naval Observatory Astronomical Applications Department', 'USNO authority provenance missing')
    expected = {2443509.5, 2443711.125, 2451545.0}
    actual = {float(c['julian_day']) for c in reference.get('reference_cases', [])}
    require(expected <= actual, 'USNO/J2000 reference values incomplete')
    for marker in (
        'USNO reference 1978-01-01 00 UT is JD 2443509.5',
        'USNO reference 1978-07-21 15 UT is JD 2443711.125',
        'J2000 epoch is JD 2451545.0',
        'one second advances Julian Day by 1/86400',
        'non UTC DateTime is rejected',
    ):
        require(marker in tests, f'compiled regression marker missing: {marker}')
    print('RC-0017 PASS: central Julian Day/time conversion core is bound to USNO/J2000 reference regressions.')


if __name__ == '__main__':
    main()
