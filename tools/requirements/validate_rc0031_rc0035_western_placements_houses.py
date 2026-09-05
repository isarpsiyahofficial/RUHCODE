#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / 'requirements/requirement_state.csv'
EXPECTED = {
    'RC-0031': ('requirements/contracts/rc0031_all_planet_placements_contract.json', '5c19ed6c1a5de0c5ee9d38f193adbe5eb31f2dbdfb0d36ade169336cca07e254'),
    'RC-0032': ('requirements/contracts/rc0032_planet_signs_contract.json', '2222dd4e72479f0e3b55ffd7d0d5fbc16d241da409d865664b71af8d5830fa76'),
    'RC-0033': ('requirements/contracts/rc0033_planet_degrees_contract.json', 'b16e85bf10f1d43fcad117b661675cf99ddbf2a5bdbc08fcb371ff61364de84d'),
    'RC-0034': ('requirements/contracts/rc0034_planet_houses_contract.json', '460fc27ef21a9bef18eb31c5b56e24ffbfba16116542f57f9b5323ebe8e4fa4b'),
    'RC-0035': ('requirements/contracts/rc0035_twelve_houses_contract.json', '6a762e4e636c89ee6d1896b7231f03511614244e8642eab96e2a619b4d5b70b1'),
}


def require(condition, message):
    if not condition:
        raise SystemExit(message)


rows = {r['rc_id']: r for r in csv.DictReader(MATRIX.open(encoding='utf-8', newline=''))}
for rc, (contract_rel, expected_sha) in EXPECTED.items():
    contract = json.loads((ROOT / contract_rel).read_text(encoding='utf-8'))
    require(contract['rcId'] == rc, f'{rc} contract id mismatch')
    require(contract['bindingRequirementSha256'] == rows[rc]['source_text_sha256'] == expected_sha, f'{rc} binding SHA mismatch')
    require(contract['promotionCeiling'] == 'TESTED', f'{rc} promotion ceiling weakened')

placements = (ROOT / 'lib/src/calculation_core/western/natal_placements.dart').read_text(encoding='utf-8')
houses = (ROOT / 'lib/src/calculation_core/western/equal_house_systems.dart').read_text(encoding='utf-8')
placement_test = (ROOT / 'test/calculation_core/western/natal_placements_test.dart').read_text(encoding='utf-8')
house_test = (ROOT / 'test/calculation_core/western/equal_house_systems_test.dart').read_text(encoding='utf-8')

for token in ['for (final state in states)', 'seenBodies.add(state.body)', 'placements.add(', 'placements.sort(', 'NatalPlacementSet(']:
    require(token in placements, f'RC-0031 missing placement token: {token}')
require('Duplicate ephemeris body' in placements and 'share source/version provenance' in placements, 'RC-0031 fail-closed body/provenance checks missing')
require('rejects duplicate bodies and mixed provenance' in placement_test, 'RC-0031 compiled duplicate/provenance regression missing')

for token in ['enum TropicalZodiacSign', 'final TropicalZodiacSign sign', '(state.longitudeDegrees / 30.0).floor()', 'TropicalZodiacSign.values[signIndex]']:
    require(token in placements, f'RC-0032 missing sign token: {token}')
for token in ['state(AstroBody.sun, 0)', 'state(AstroBody.mercury, 30)', 'state(AstroBody.venus, 359.999999)']:
    require(token in placement_test, f'RC-0032 boundary regression missing: {token}')

for token in ['final double longitudeDegrees', 'final double degreeInSign', 'degreeInSign = state.longitudeDegrees - signIndex * 30.0', 'longitudeDegrees: state.longitudeDegrees']:
    require(token in placements, f'RC-0033 missing degree token: {token}')
require('degreeInSign, closeTo(0, 1e-12)' in placement_test, 'RC-0033 exact degree boundary regression missing')

for token in ['final int houseNumber', 'houseNumber: houses.houseForLongitude(state.longitudeDegrees)']:
    require(token in placements, f'RC-0034 missing house placement token: {token}')
require('houseForLongitude(double longitude)' in houses, 'RC-0034 HouseCusps assignment method missing')
require('houseNumber, 11' in placement_test, 'RC-0034 compiled house assignment regression missing')

for token in ['if (cusps.length != 12)', 'final List<double> cusps', 'double cusp(int houseNumber)', 'RangeError.range(houseNumber, 1, 12', 'List<double>.generate(']:
    require(token in houses, f'RC-0035 missing twelve-house token: {token}')
for token in ['houses.cusp(1)', 'houses.cusp(2)', 'houses.cusp(12)']:
    require(token in house_test, f'RC-0035 compiled cusp regression missing: {token}')

print('RC-0031..RC-0035 Western placement/house contracts: PASS')
