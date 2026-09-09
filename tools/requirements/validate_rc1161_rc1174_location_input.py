from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1161_rc1174_location_input_contract.json'
CATALOG = ROOT / 'lib/src/data/location/city_catalog.dart'
POLICY = ROOT / 'lib/src/data/location/location_input_policy.dart'
TEST = ROOT / 'test/data/location_input_rc1161_rc1174_test.dart'
CITY_TEST = ROOT / 'test/data/city_catalog_test.dart'
MANIFEST = ROOT / 'requirements/data_manifests/cities.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    catalog = read(CATALOG)
    policy = read(POLICY)
    test = read(TEST)
    city_test = read(CITY_TEST)
    manifest = json.loads(read(MANIFEST))

    expected = [f'RC-{i:04d}' for i in range(1161, 1175)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        '_prefixBuckets',
        '_normalizedCandidates',
        'normalizeCitySearchText',
        'disambiguationLabel',
        'aliases',
        'ianaTimeZoneId',
    ):
        assert token in catalog, f'missing indexed city-search token: {token}'

    for token in (
        'SupportedInputLocale',
        'BirthTimePrecision',
        'unknown',
        'RecentLocationStore',
        'gpsRequiredForBirthPlace => false',
        'manualCitySelectionAvailable => true',
        'shouldOfferManualFallback',
    ):
        assert token in policy, f'missing location-input policy token: {token}'

    for token in (
        '100k indexed city records',
        "catalog.search('Istanbul')",
        "catalog.search('İstanbul')",
        "catalog.search('Constantinople')",
        'Springfield, Illinois, United States',
        'Springfield, Massachusetts, United States',
        'GPS denial always leaves manual city selection usable',
        'Doğum saati bilinmiyor',
        'Birth time unknown',
    ):
        assert token in test, f'missing RC1161-RC1174 regression token: {token}'

    assert 'same-name cities remain separate and visibly disambiguated' in city_test
    assert manifest.get('runtime_network_required') is False, 'city search became network-dependent'
    generated = manifest.get('generated_catalog', {})
    if manifest.get('status') == 'BUNDLED_VERIFIED':
        assert generated.get('record_count', 0) >= 100000, 'bundled city catalog too small for RC1164 evidence'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1161_RC1174_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1161_RC1174_OK')
