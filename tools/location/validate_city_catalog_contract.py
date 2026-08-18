from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/data/location/city_catalog.dart'
TEST = ROOT / 'test/data/city_catalog_test.dart'
MANIFEST = ROOT / 'requirements/data_manifests/cities.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    tests = read(TEST)
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

    assert manifest['source_provider'] == 'GeoNames'
    assert manifest['license'] == 'CC-BY-4.0'
    assert manifest['attribution_required'] is True
    assert manifest['runtime_network_required'] is False
    assert 'cities500.zip' in manifest['source_artifacts']
    assert 'alternateNamesV2.zip' in manifest['source_artifacts']
    assert manifest['status'] == 'SOURCE_SELECTED_NOT_BUNDLED'
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'city catalog contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('city catalog contract OK: offline schema, alias search, disambiguation and licensed source contract present')
