from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/content/daily_messages/daily_message_catalog.dart'
DART_TEST = ROOT / 'test/content/daily_message_catalog_test.dart'
MANIFEST = ROOT / 'requirements/content_manifests/daily_messages.json'
AUDITOR = ROOT / 'tools/content/validate_daily_message_catalog.py'
AUDITOR_TEST = ROOT / 'tools/content/test_validate_daily_message_catalog.py'
BUILDER = ROOT / 'tools/content/build_daily_message_catalog.py'
APPENDER = ROOT / 'tools/content/append_daily_message_batch.py'
APPENDER_TEST = ROOT / 'tools/content/test_append_daily_message_batch.py'
RELEASE_HORIZON = ROOT / 'tools/content/validate_daily_message_release_horizon.py'
RELEASE_HORIZON_TEST = ROOT / 'tools/content/test_validate_daily_message_release_horizon.py'


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
    builder = read(BUILDER)
    appender = read(APPENDER)
    appender_test = read(APPENDER_TEST)
    release_horizon = read(RELEASE_HORIZON)
    release_horizon_test = read(RELEASE_HORIZON_TEST)

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
    assert manifest['status'] in {
        'SCHEMA_AND_QA_READY_CONTENT_NOT_POPULATED',
        'EDITORIAL_CONTENT_IN_PROGRESS',
        'EDITORIAL_CONTENT_COMPLETE_PENDING_RELEASE_AUDIT',
        'RELEASE_AUDIT_COMPLETE',
    }, f"unsupported daily-message lifecycle status: {manifest['status']!r}"

    storage = manifest['storage']
    assert storage['model'] == 'locale_period_csv_shards'
    assert storage['shards_root'] == 'assets/content/daily_messages'
    assert storage['shard_patterns'] == ['{locale}/{year}.csv', '{locale}/{year}-{month}.csv']
    assert storage['compiler'] == 'tools/content/build_daily_message_catalog.py'
    assert storage['strict_auditor'] == 'tools/content/validate_daily_message_catalog.py'
    assert storage['release_horizon_validator'] == 'tools/content/validate_daily_message_release_horizon.py'
    assert storage['release_audit_must_be_complete'] is True

    for token in ('SHARD_FILE', 'date {row["date"]!r} does not match shard month', 'Duplicate exact daily-message key across shards'):
        assert token in builder, f'missing period-shard compiler token: {token}'
    for token in ('append_paired_batch', "f'{year:04d}-{month:02d}.csv'", 'batch overlaps committed dates'):
        assert token in appender, f'missing safe paired batch appender token: {token}'
    for token in (
        'test_appends_paired_contiguous_batch_to_month_shards_and_updates_ledger',
        'test_rejects_gap_without_mutating_shards_or_evidence',
        'test_rejects_mismatched_language_date_ranges',
    ):
        assert token in appender_test, f'missing paired batch appender test: {token}'

    for token in (
        'rolling_release_horizon_years',
        'required_through',
        'missing_release_window_records',
        'release horizon is short',
    ):
        assert token in release_horizon, f'missing rolling release-horizon token: {token}'
    for token in (
        'test_full_ten_year_release_window_passes',
        'test_one_missing_locale_date_is_release_blocker',
        'test_catalog_ending_one_day_early_is_release_blocker',
        'test_leap_day_release_clamps_target_to_february_28',
    ):
        assert token in release_horizon_test, f'missing rolling release-horizon test: {token}'

    gates = set(manifest['quality_gates'])
    for gate in (
        'exact_duplicate_detection',
        'near_duplicate_review',
        'repetitive_opening_pattern_review',
        'unsafe_certainty_review',
        'tr_en_independent_editorial_review',
        'rolling_ten_year_release_horizon',
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

print('daily message contract OK: exact-date TR/EN lookup, scalable deterministic period shards, safe paired append, rolling ten-year release horizon, editorial lifecycle states and duplicate/near-duplicate/opening/certainty QA gates are present')
