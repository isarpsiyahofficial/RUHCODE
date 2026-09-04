#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0011_rc0012_location_identity_contract.json'
CORE = ROOT / 'lib/src/data/location/city_catalog.dart'
TEST = ROOT / 'test/data/city_catalog_test.dart'
CITY_VALIDATOR = ROOT / 'tools/location/validate_city_catalog_contract.py'
MANIFEST = ROOT / 'requirements/data_manifests/cities.json'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f'RC-0011/0012 FAIL: {message}')


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    core = CORE.read_text(encoding='utf-8')
    tests = TEST.read_text(encoding='utf-8')
    city_validator = CITY_VALIDATOR.read_text(encoding='utf-8')
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))

    require(set(contract['binding_requirements']) == {'RC-0011', 'RC-0012'}, 'binding requirement set drifted')

    # RC-0011: city identity, coordinates and timezone must be separate mandatory values.
    constructor = core.split('final class CitySearchResult', 1)[0]
    for marker in (
        'required this.id',
        'required this.countryCode',
        'required this.countryName',
        'required this.latitude',
        'required this.longitude',
        'required this.ianaTimeZoneId',
        'final double latitude',
        'final double longitude',
        'final String ianaTimeZoneId',
    ):
        require(marker in constructor, f'city coordinate/timezone identity marker missing: {marker}')
    require("record.latitude < -90 || record.latitude > 90" in core, 'latitude validation missing')
    require("record.longitude < -180 || record.longitude > 180" in core, 'longitude validation missing')
    require("record.ianaTimeZoneId.trim().isEmpty" in core, 'timezone non-empty validation missing')
    require("valid_iana_timezone_ids" in city_validator, 'physical city dataset IANA validation gate missing')
    require(manifest.get('release_evidence_required', {}).get('valid_iana_timezone_ids') is True, 'manifest does not require IANA-id evidence')

    # RC-0012: same-name cities cannot be collapsed; identity and disambiguation remain visible.
    require("String get disambiguationLabel" in core, 'visible disambiguation label missing')
    require("return '$name, $region, $countryName'" in core, 'admin/country disambiguation weakened')
    require("return a.city.id.compareTo(b.city.id)" in core, 'deterministic stable-id tie break missing')
    for marker in (
        "id: 'us-springfield-il'",
        "id: 'us-springfield-ma'",
        "adminArea: 'Illinois'",
        "adminArea: 'Massachusetts'",
        "ianaTimeZoneId: 'America/Chicago'",
        "ianaTimeZoneId: 'America/New_York'",
        "same-name cities remain separate and visibly disambiguated",
        "expect(results, hasLength(2))",
    ):
        require(marker in tests, f'same-name city regression evidence missing: {marker}')

    print('RC-0011/RC-0012 PASS: independent coordinate/timezone fields and same-name city identity/disambiguation contracts are present.')


if __name__ == '__main__':
    main()
