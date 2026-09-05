#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = {
    'RC-0041': ('requirements/contracts/rc0041_planet_aspects_contract.json', 'f007ec243fb2173dcb14fc03bf0ac4d3f217c99a46ce9960f383e19abef48520'),
    'RC-0042': ('requirements/contracts/rc0042_conjunction_contract.json', '00f1c522f620d71814442781d144d57af02a6180d56a3e467ca8b5e53b3043cf'),
    'RC-0043': ('requirements/contracts/rc0043_opposition_contract.json', '92145cd4da524ae6fa463a3fde5637dbc2af458e4741ea8c0cd00584f284136c'),
    'RC-0044': ('requirements/contracts/rc0044_trine_contract.json', '9c9ae25a291f96670c7c6e49f916f766a6e1c196b6e0c69c718c6447681be87e'),
    'RC-0045': ('requirements/contracts/rc0045_square_contract.json', '3d29f3b4de666f498bfad2be237b20b481ccc3582d3e41a06854b62b366b751d'),
    'RC-0046': ('requirements/contracts/rc0046_sextile_contract.json', 'f9dd006709de55a25dc423921b8036d1b0f2d58e0530fe68acb00587b2bfa74d'),
    'RC-0047': ('requirements/contracts/rc0047_quincunx_contract.json', '01f0f663ea1f0ef150ce39b20d2f05af7d5a332dc8e5d74ed1ecd261037ccc23'),
    'RC-0048': ('requirements/contracts/rc0048_aspect_orbs_contract.json', 'bd69be589e93d5d47f175daaf371c6a46c423cb46bd67498904375dd8a7d6369'),
    'RC-0049': ('requirements/contracts/rc0049_body_aspect_orbs_contract.json', '72cf1cf4c8f4c792dfb05aa72f0f399ab7be01f1b0cc4336fc85ebecb40b9ecb'),
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

source = (ROOT / 'lib/src/calculation_core/western/natal_aspects.dart').read_text(encoding='utf-8')
test = (ROOT / 'test/calculation_core/western/natal_aspects_test.dart').read_text(encoding='utf-8')

for token in [
    'conjunction(0)', 'sextile(60)', 'square(90)', 'trine(120)', 'quincunx(150)', 'opposition(180)',
    'final Map<MajorAspect, double> maximumOrbDegrees;',
    'final Map<AstroBody, Map<MajorAspect, double>> bodyAspectOverrides;',
    'double forBodies(MajorAspect aspect, AstroBody bodyA, AstroBody bodyB)',
    'final separation = _shortestSeparation(a.longitudeDegrees, b.longitudeDegrees)',
    'final allowedOrb = policy.forBodies(aspect, a.body, b.body)',
    'if (orb <= allowedOrb && orb < bestOrb)',
]:
    require(token in source, f'missing aspect runtime token: {token}')

for token in [
    'MajorAspect.conjunction: 8.0', 'MajorAspect.sextile: 5.0', 'MajorAspect.square: 7.0',
    'MajorAspect.trine: 7.0', 'MajorAspect.quincunx: 3.0', 'MajorAspect.opposition: 8.0',
]:
    require(token in source, f'missing explicit default orb token: {token}')

for token in [
    'detects conjunction sextile square trine quincunx and opposition',
    'containsAll(MajorAspect.values)',
    'planet and aspect specific orb overrides change detection deterministically',
    'MajorAspect.quincunx: 1',
    'throwsStateError',
]:
    require(token in test, f'missing compiled aspect regression token: {token}')

print('RC-0041..RC-0049 Western aspect contracts: PASS')
