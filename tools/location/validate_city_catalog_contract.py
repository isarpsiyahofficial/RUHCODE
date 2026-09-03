from pathlib import Path
import gzip
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/data/location/city_catalog.dart'
TEST = ROOT / 'test/data/city_catalog_test.dart'
BUILDER = ROOT / 'tools/location/build_city_catalog.py'
BUILDER_TEST = ROOT / 'tools/location/test_build_city_catalog.py'
MANIFEST = ROOT / 'requirements/data_manifests/cities.json'
PUBSPEC = ROOT / 'pubspec.yaml'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


try:
    core = read(CORE)
    tests = read(TEST)
    builder = read(BUILDER)
    builder_tests = read(BUILDER_TEST)
    manifest = json.loads(read(MANIFEST))
    pubspec = read(PUBSPEC)

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

    assert manifest['source_provider'] == 'GeoNames', 'unexpected city source provider'
    assert manifest['license'] == 'CC-BY-4.0', 'unexpected city dataset license'
    assert manifest['attribution_required'] is True, 'city attribution must be required'
    assert manifest['commercial_use_allowed'] is True, 'city dataset commercial-use flag missing'
    assert manifest['runtime_network_required'] is False, 'city runtime must remain offline'
    assert manifest['source_listing_verified_at_utc'].endswith('Z'), 'source listing verification is not UTC'
    assert manifest['license_verified_at_utc'].endswith('Z'), 'license verification is not UTC'
    assert manifest['source_listing_observed_modified_date'], 'source listing modified date missing'

    required = manifest['required_source_artifacts']
    optional = manifest['optional_enrichment_artifacts']
    assert 'cities500.zip' in required, 'cities500.zip missing from source contract'
    assert 'admin1CodesASCII.txt' in required, 'admin1CodesASCII.txt missing from source contract'
    assert 'countryInfo.txt' in required, 'countryInfo.txt missing from source contract'
    assert 'readme.txt' in required, 'readme.txt missing from source contract'
    assert 'alternateNamesV2.zip' not in required, 'optional aliases became a hard runtime dependency'
    assert 'alternateNamesV2.zip' in optional, 'optional alias enrichment source missing'

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

    assert 'GeoNames' in manifest['attribution_text'], 'GeoNames attribution missing'
    assert 'CC BY 4.0' in manifest['attribution_text'], 'GeoNames license attribution missing'
    assert 'web listing observation alone is not physical artifact evidence' in manifest['integrity_policy'], 'city integrity policy weakened'

    status = manifest['status']
    assert status in {'SOURCE_SELECTED_NOT_BUNDLED', 'BUNDLED_VERIFIED'}, f'unknown city dataset status: {status}'

    if status == 'BUNDLED_VERIFIED':
        assert manifest.get('source_snapshot_date'), 'bundled city snapshot date missing'
        source_artifacts = manifest.get('source_artifacts', {})
        for name in required:
            item = source_artifacts.get(name)
            assert isinstance(item, dict), f'missing source artifact evidence: {name}'
            checksum = item.get('sha256', '')
            assert len(checksum) == 64, f'invalid SHA-256 evidence for source artifact: {name}'
            assert item.get('byte_size', 0) > 0, f'invalid byte-size evidence for source artifact: {name}'

        generated = manifest.get('generated_catalog', {})
        relative_catalog = generated.get('path', '')
        assert relative_catalog == 'assets/data/cities/cities500.catalog.jsonl.gz', 'unexpected generated city catalog path'
        catalog_path = ROOT / relative_catalog
        assert catalog_path.is_file(), f'generated city catalog missing: {relative_catalog}'
        assert catalog_path.stat().st_size == generated.get('byte_size'), 'generated city catalog byte size mismatch'
        assert sha256(catalog_path) == generated.get('sha256'), 'generated city catalog SHA-256 mismatch'
        assert generated.get('unique_stable_ids') is True, 'stable-id uniqueness evidence missing'
        assert generated.get('valid_iana_timezone_ids') is True, 'IANA timezone validation evidence missing'

        record_count = 0
        stable_ids = set()
        with gzip.open(catalog_path, 'rt', encoding='utf-8') as handle:
            for line_number, line in enumerate(handle, start=1):
                if not line.strip():
                    continue
                row = json.loads(line)
                stable_id = str(row.get('stable_id', '')).strip()
                assert stable_id, f'city row {line_number} has empty stable_id'
                assert stable_id not in stable_ids, f'duplicate stable_id in bundled city catalog: {stable_id}'
                stable_ids.add(stable_id)
                latitude = float(row['latitude'])
                longitude = float(row['longitude'])
                assert -90.0 <= latitude <= 90.0, f'city row {line_number} latitude out of range'
                assert -180.0 <= longitude <= 180.0, f'city row {line_number} longitude out of range'
                assert str(row.get('iana_timezone_id', '')).strip(), f'city row {line_number} timezone missing'
                record_count += 1
        assert record_count == generated.get('record_count'), 'generated city catalog record count mismatch'
        assert record_count >= 200000, 'bundled city catalog is unexpectedly small'

        attribution = manifest.get('attribution_asset', {})
        attribution_path = ROOT / attribution.get('path', '')
        assert attribution_path.is_file(), 'bundled GeoNames attribution asset missing'
        assert sha256(attribution_path) == attribution.get('sha256'), 'GeoNames attribution SHA-256 mismatch'
        attribution_text = read(attribution_path)
        assert 'GeoNames' in attribution_text and 'CC BY 4.0' in attribution_text, 'bundled attribution content incomplete'

        assert relative_catalog in pubspec, 'generated city catalog is not declared as a Flutter asset'
        assert attribution.get('path', '') in pubspec, 'GeoNames attribution is not declared as a Flutter asset'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'city catalog contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('city catalog contract OK: offline schema, GeoNames provenance, physical bundled catalog, attribution, SHA-256 and release evidence gates are valid')
