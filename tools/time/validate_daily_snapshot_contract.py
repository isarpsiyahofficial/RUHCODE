from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/calculation_core/daily/daily_snapshot.dart'
TEST = ROOT / 'test/calculation_core/daily_snapshot_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    tests = read(TEST)
    for token in (
        'DailySnapshotIdentity',
        'profileId',
        'civilDate',
        'ianaTimeZoneId',
        'latitude',
        'longitude',
        'engineVersion',
        'timezoneDatabaseVersion',
        'cacheKey',
        'DailyFactorReference',
        'sourceEngineId',
        'sourceEngineVersion',
        'resultId',
        'DailySnapshotAssembler',
        'factorOrder',
        'Duplicate daily factor kind is not allowed',
        'DailySnapshot generation time must be UTC',
    ):
        assert token in core, f'missing DailySnapshot contract token: {token}'

    for token in (
        'same calendar month/day in different years never shares cache key',
        'timezone is part of DailySnapshot identity',
        'profile and location are part of DailySnapshot identity',
        'engine and timezone database versions invalidate cache',
        'leap day has its own exact snapshot identity',
        'snapshot can exist without inventing unavailable factor results',
        'factor references retain source engine provenance',
        'assembler applies deterministic factor order',
        'assembler rejects duplicate factor kinds',
        'assembler rejects empty provenance and non-UTC generation time',
    ):
        assert token in tests, f'missing DailySnapshot test contract: {token}'
except AssertionError as exc:
    print(f'daily snapshot contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('daily snapshot contract OK: exact identity, provenance, UTC generation, uniqueness and deterministic factor ordering are present')
