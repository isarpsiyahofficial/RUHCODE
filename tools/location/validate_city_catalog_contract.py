from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/data/location/city_catalog.dart'
TEST = ROOT / 'test/data/city_catalog_test.dart'
BUILDER = ROOT / 'tools/location/build_city_catalog.py'
BUILDER_TEST = ROOT / 'tools/location/test_build_city_catalog.py'
MANIFEST = ROOT / 'requirements/data_manifests/cities.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    tests = read(TEST)
    builder = read(BUILDER)
    builder_tests = read(BUILDER_TEST)
    manifest = json.loads(read(MANIFEST))

    for token in (
        'CityRecord',
        'countryCode',
        'latitude',
        'longitude',
        'ianaTimeZoneId',
        'aliases',
        'disambiguationLabel',
        'normalizeCitySearchText',
    ):
        assert token in core, f'missing city catalog contract token: {token}'

    for token in (
        'Turkish diacritics and ASCII aliases find the same city',
        'aliases are searchable without changing canonical display name',
        'same-name cities remain separate and visibly disambiguated',
        'search is deterministic and respects result limit',
        'invalid coordinates and duplicate ids are rejected',
    ):
        assert token in tests, f'missing city catalog test: {token}'

    for token in (
        'sha256',
        'parse_alternate_names',
        'parse_cities',
        'stable_id',
        'iana_timezone_id',
        'output_sha256',
        'alternate_names_enrichment',
        'sources',
    ):
        assert token in builder, f'missing builder contract token: {token}'

    for token in (
        'test_fixture_build_is_deterministic_and_preserves_timezone_aliases',
        'test_duplicate_zip_members_are_rejected',
        'Constantinople',
        'Europe/Istanbul',
        'America/Chicago',
    ):
        assert token in builder_tests, f'missing builder test contract token: {token}'

    assert manifest['source_provider'] == 'GeoNames'
    assert manifest['license'] == 'CC-BY-4.0'
    assert manifest['attribution_required'] is True
    assert manifest['commercial_use_allowed'] is True
    assert manifest['runtime_network_required'] is False
    assert manifest['source_listing_verified_at_utc'].endswith('Z')
    assert manifest['license_verified_at_utc'].endswith('Z')
    assert manifest['source_listing_observed_modified_date']

    required = manifest['required_source_artifacts']
    optional = manifest['optional_enrichment_artifacts']
    assert 'cities500.zip' in required
    assert 'admin1CodesASCII.txt' in required
    assert 'countryInfo.txt' in required
    assert 'readme.txt' in required
    assert 'alternateNamesV2.zip' not in required
    assert 'alternateNamesV2.zip' in optional

    evidence = manifest['release_evidence_required']
    for key in (
        'source_artifact_sha256',
        'generated_catalog_sha256',
        'record_count',
        'unique_stable_ids',
        'valid_iana_timezone_ids',
        'attribution_text_bundled',
        'source_snapshot_date_recorded',
    ):
        assert evidence[key] is True, f'city release evidence gate disabled: {key}'

    assert 'GeoNames' in manifest['attribution_text']
    assert 'CC BY 4.0' in manifest['attribution_text']
    assert 'web listing observation alone is not physical artifact evidence' in manifest['integrity_policy']
    assert manifest['status'] == 'SOURCE_SELECTED_NOT_BUNDLED'
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'city catalog contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('city catalog contract OK: offline schema, GeoNames CC BY 4.0 provenance, compact source set, attribution and release SHA/evidence gates are present')
