#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = {
    'RC-0038': ('requirements/contracts/rc0038_house_rulers_contract.json', '1217c3c1306df0d45235421d1b0a9d09b6db50d0122cccaecfa7d18153fcfb92'),
    'RC-0039': ('requirements/contracts/rc0039_planet_ruled_signs_contract.json', 'e7f4cda7686550135d25d5d0a593953b2c85ed981d54700aa73d108592e7d1d3'),
    'RC-0040': ('requirements/contracts/rc0040_natural_rulerships_contract.json', '0f06f614a3c603c36728e9edbb41e85f09aba1acd6f0116a05b314611dccd8ee'),
}


def require(condition, message):
    if not condition:
        raise SystemExit(message)


rows = {r['rc_id']: r for r in csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline=''))}
for rc, (path, sha) in EXPECTED.items():
    contract = json.loads((ROOT / path).read_text(encoding='utf-8'))
    require(contract['rcId'] == rc, f'{rc}: contract id mismatch')
    require(contract['bindingRequirementSha256'] == rows[rc]['source_text_sha256'] == sha, f'{rc}: binding SHA mismatch')
    require(contract['promotionCeiling'] == 'TESTED', f'{rc}: promotion ceiling weakened')

source = (ROOT / 'lib/src/calculation_core/western/rulerships.dart').read_text(encoding='utf-8')
test = (ROOT / 'test/calculation_core/western/rulerships_test.dart').read_text(encoding='utf-8')

# Both schemes must explicitly cover every sign rather than deriving one from the other.
for token in [
    'enum WesternRulershipScheme { traditional, modern }',
    'static const Map<TropicalZodiacSign, AstroBody> traditional',
    'static const Map<TropicalZodiacSign, AstroBody> modern',
    'static AstroBody rulerForSign(',
    'static Set<TropicalZodiacSign> signsRuledBy(',
    'static WesternHouseRuler rulerForHouse(',
    'static List<WesternHouseRuler> rulersForAllHouses(',
    'houses.cusp(houseNumber)',
]:
    require(token in source, f'missing rulership runtime token: {token}')
require(source.count('TropicalZodiacSign.') >= 24, 'traditional and modern sign maps must be explicit')
for token in [
    'TropicalZodiacSign.scorpio: AstroBody.mars',
    'TropicalZodiacSign.aquarius: AstroBody.saturn',
    'TropicalZodiacSign.pisces: AstroBody.jupiter',
    'TropicalZodiacSign.scorpio: AstroBody.pluto',
    'TropicalZodiacSign.aquarius: AstroBody.uranus',
    'TropicalZodiacSign.pisces: AstroBody.neptune',
]:
    require(token in source, f'explicit traditional/modern distinction missing: {token}')
for token in [
    'traditional and modern rulership catalogs cover all twelve signs',
    'reports signs ruled by each planet under the selected scheme',
    'derives all twelve house rulers from the actual cusp signs',
    'house ruler lookup fails closed outside houses one through twelve',
    'hasLength(12)',
]:
    require(token in test, f'missing compiled rulership regression token: {token}')
print('RC-0038..RC-0040 Western rulership contracts: PASS')
