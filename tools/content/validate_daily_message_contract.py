from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/content/daily_messages/daily_message_catalog.dart'
DART_TEST = ROOT / 'test/content/daily_message_catalog_test.dart'
MANIFEST = ROOT / 'requirements/content_manifests/daily_messages.json'
AUDITOR = ROOT / 'tools/content/validate_daily_message_catalog.py'
AUDITOR_TEST = ROOT / 'tools/content/test_validate_daily_message_catalog.py'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    dart_test = read(DART_TEST)
    manifest = json.loads(read(MANIFEST))
    auditor = read(AUDITOR)
    auditor_test = read(AUDITOR_TEST)

    for token in (
        'DailyMessageEntry',
        'DailyMessageCatalog',
        "'${date.isoKey}|$localeTag'",
        'Duplicate daily message key',
        'Missing daily message',
    ):
        assert token in core, f'missing daily-message runtime token: {token}'

    for token in (
        'lookup uses exact YYYY-MM-DD plus locale key',
        'same date and locale duplicate is rejected',
        'missing exact date never falls back to a random message',
        '29 February is a normal exact catalog key on leap years',
    ):
        assert token in dart_test, f'missing daily-message Dart test: {token}'

    assert manifest['lookup_key'] == 'YYYY-MM-DD|locale'
    assert manifest['locales'] == ['tr', 'en']
    assert manifest['initial_coverage_start'] == '2026-01-01'
    assert manifest['initial_coverage_end'] == '2036-12-31'
    assert manifest['initial_days'] == 4018
    assert manifest['initial_total_records'] == 8036
    assert manifest['rolling_release_horizon_years'] == 10
    assert manifest['runtime_ai_generation_allowed'] is False
    assert manifest['random_fallback_allowed'] is False
    assert manifest['machine_translation_between_tr_en_allowed'] is False
    assert manifest['status'] == 'SCHEMA_AND_QA_READY_CONTENT_NOT_POPULATED'

    gates = set(manifest['quality_gates'])
    for gate in (
        'exact_duplicate_detection',
        'near_duplicate_review',
        'repetitive_opening_pattern_review',
        'unsafe_certainty_review',
        'tr_en_independent_editorial_review',
    ):
        assert gate in gates, f'missing quality gate: {gate}'

    thresholds = manifest['quality_thresholds']
    assert 0.0 < float(thresholds['near_duplicate_similarity']) <= 1.0
    assert int(thresholds['near_duplicate_min_shared_tokens']) >= 1
    assert 0.0 < float(thresholds['near_duplicate_max_token_document_ratio']) <= 1.0
    assert int(thresholds['repetitive_opening_max_uses']) >= 1
    assert thresholds['fail_on_near_duplicate'] is True
    assert thresholds['fail_on_unsafe_certainty'] is True

    for token in (
        'expected_keys',
        'duplicate exact date/locale keys',
        'missing exact date/locale keys',
        'exact duplicate message bodies detected',
        'repetitive opening patterns',
        '_near_duplicate_pairs',
        'near-duplicate editorial review failed',
        '_unsafe_certainty_findings',
        'unsafe certainty review failed',
        'required_leap_dates',
        'catalog_sha256',
    ):
        assert token in auditor, f'missing daily-message auditor token: {token}'

    for token in (
        'test_complete_exact_date_locale_fixture_passes',
        'test_missing_leap_locale_and_duplicate_key_fail',
        'test_exact_duplicate_content_fails_even_on_different_dates',
        'test_near_duplicate_is_flagged_within_same_locale',
        'test_cross_locale_similarity_is_not_near_duplicate',
        'test_unsafe_certainty_is_flagged_for_tr_and_en',
    ):
        assert token in auditor_test, f'missing daily-message auditor test: {token}'
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'daily message contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('daily message contract OK: exact-date TR/EN lookup plus duplicate, near-duplicate, repetitive-opening and unsafe-certainty QA gates are present')
