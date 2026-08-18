from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
PUBSPEC = ROOT / 'pubspec.yaml'
RUNTIME = ROOT / 'lib/src/calculation_core/time/time_zone_runtime.dart'
DAILY = ROOT / 'lib/src/calculation_core/time/daily_date_context.dart'
DEVICE = ROOT / 'lib/src/data/time/device_time_zone_provider.dart'
TEST = ROOT / 'test/calculation_core/time_zone_runtime_test.dart'
DAILY_TEST = ROOT / 'test/calculation_core/daily_date_context_test.dart'
MANIFEST = ROOT / 'requirements/data_manifests/timezone.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    pubspec = read(PUBSPEC)
    runtime = read(RUNTIME)
    daily = read(DAILY)
    device = read(DEVICE)
    tests = read(TEST)
    daily_tests = read(DAILY_TEST)
    manifest = json.loads(read(MANIFEST))

    for token in ('timezone: ^0.11.1', 'flutter_timezone: ^5.1.0'):
        assert token in pubspec, f'missing dependency contract: {token}'

    for token in (
        "package:timezone/data/latest_all.dart",
        "databaseVersion = '2025c'",
        'AmbiguousLocalTimePolicy',
        'NonexistentLocalTimePolicy',
        'resolveLocal',
        'civilDateAtUtc',
        'offsetAtUtc',
        '36 * 60',
    ):
        assert token in runtime, f'missing runtime contract token: {token}'

    for token in ('DailyDateContext', 'dateKey', 'cachePartitionKey', 'DailyDateResolver'):
        assert token in daily, f'missing daily-date contract token: {token}'

    for token in ('FlutterTimezone.getLocalTimezone', 'info.identifier', 'TimeZoneRuntime.location'):
        assert token in device, f'missing device-timezone contract token: {token}'

    for token in (
        'half-hour timezone is resolved exactly',
        '45-minute timezone is resolved exactly',
        'UTC+14 timezone preserves the correct civil-day boundary',
        'date-line zones can be on different civil dates at one instant',
        'ambiguous fall-back time rejects unless a policy is explicit',
        'nonexistent spring-forward time rejects by default',
        'historical skipped civil day is not silently treated as valid',
    ):
        assert token in tests, f'missing timezone boundary test: {token}'

    for token in (
        'same UTC instant can belong to different civil dates',
        'Istanbul daily key rolls over exactly at local midnight',
        'same month and day in different years never share a daily key',
        'leap day remains an exact daily key',
    ):
        assert token in daily_tests, f'missing daily-date boundary test: {token}'

    assert manifest['dataset_id'] == 'iana-tzdb'
    assert manifest['runtime_package_version'] == '0.11.1'
    assert manifest['database_variant'] == 'latest_all'
    assert manifest['iana_version'] == '2025c'
    assert manifest['offline'] is True
    assert manifest['supported_civil_year_min'] == 1890
    assert manifest['supported_civil_year_max'] == 2110
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'timezone contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('timezone contract OK: bundled IANA runtime, DST policies, device-zone validation and daily-date boundaries present')
