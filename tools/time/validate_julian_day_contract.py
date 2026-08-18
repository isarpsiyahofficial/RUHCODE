from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/calculation_core/time/julian_day.dart'
TEST = ROOT / 'test/calculation_core/julian_day_test.dart'
REFERENCE = ROOT / 'requirements/reference_sources/julian_day.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    tests = read(TEST)
    reference = json.loads(read(REFERENCE))
    for token in (
        'fromUtc',
        'fromCivilDate',
        'gregorianCorrection',
        'modified',
        'centuriesSinceJ2000',
    ):
        assert token in core, f'missing Julian Day core token: {token}'

    for token in (
        'USNO reference 1978-01-01 00 UT is JD 2443509.5',
        'USNO reference 1978-07-21 15 UT is JD 2443711.125',
        'J2000 epoch is JD 2451545.0',
        'one second advances Julian Day by 1/86400',
        'non UTC DateTime is rejected',
    ):
        assert token in tests, f'missing Julian Day test: {token}'

    assert reference['authority'] == 'U.S. Naval Observatory Astronomical Applications Department'
    cases = reference['reference_cases']
    assert cases[0]['julian_day'] == 2443509.5
    assert cases[1]['julian_day'] == 2443711.125
    assert cases[2]['julian_day'] == 2451545.0
    assert 'UT1 or TT' in reference['time_scale_note']
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'julian day contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('julian day contract OK: USNO reference values, UTC input discipline and J2000/MJD foundations are present')
