from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/calculation_core/time/civil_calendar.dart'
TEST = ROOT / 'test/calculation_core/civil_calendar_test.dart'

required_core = [
    'minimumSupportedYear = 1890',
    'maximumSupportedYear = 2110',
    'year % 400 == 0',
    'year % 100 == 0',
    'year % 4 == 0',
    'CivilWeekday',
    'weekdayOf',
    'parseIso',
    'isoKey',
]

required_tests = [
    '1900 is not a leap year',
    '2000 is a leap year',
    '2028, 2032 and 2036 are leap years',
    '2100 is not a leap year',
    'leap-year February rolls 28 -> 29 -> March 1',
    'normal February rolls 28 -> March 1',
    '16.08.2026 and 16.08.2027 remain distinct dates',
    'ISO keys parse and round trip without locale formatting',
]

def require_file(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')

try:
    core = require_file(CORE)
    test = require_file(TEST)
    for token in required_core:
        assert token in core, f'missing calendar-core contract token: {token}'
    for token in required_tests:
        assert token in test, f'missing calendar test contract: {token}'
except AssertionError as exc:
    print(f'calendar contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('calendar contract OK: deterministic Gregorian/leap/weekday/ISO boundary coverage present')
