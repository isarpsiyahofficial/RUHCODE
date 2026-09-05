#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path('.')
CONTRACT = ROOT / 'requirements/contracts/rc0036_rc0050_western_binding_contract.json'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def numbered_spec() -> dict[int, str]:
    result: dict[int, str] = {}
    for line in SPEC.read_text(encoding='utf-8').splitlines():
        match = re.match(r'^(\d+)\.\s+(.*)$', line.strip())
        if match:
            result[int(match.group(1))] = match.group(2).strip()
    return result


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    spec = numbered_spec()
    tested = contract['tested_requirements']
    for rc_id, text in tested.items():
        number = int(rc_id.split('-')[1])
        require(spec.get(number) == text, f'{rc_id} contract text does not match binding specification')

    rulerships = (ROOT / 'lib/src/calculation_core/western/rulerships.dart').read_text(encoding='utf-8')
    aspects = (ROOT / 'lib/src/calculation_core/western/natal_aspects.dart').read_text(encoding='utf-8')
    distribution = (ROOT / 'lib/src/calculation_core/western/natal_distribution.dart').read_text(encoding='utf-8')
    dignities = (ROOT / 'lib/src/calculation_core/western/essential_dignities.dart').read_text(encoding='utf-8')

    # RC-0036: all twelve actual cusps can resolve to a ruler under an explicit scheme.
    for token in ['rulerForHouse', 'rulersForAllHouses', 'houses.cusp(houseNumber)', 'WesternRulershipScheme']:
        require(token in rulerships, f'RC-0036 missing runtime token: {token}')
    require('for (var house = 1; house <= 12; house++)' in rulerships, 'RC-0036 must resolve all 12 houses')

    # RC-0037..0041 exact major aspects.
    exact = {
        'conjunction': '0',
        'opposition': '180',
        'square': '90',
        'trine': '120',
        'sextile': '60',
    }
    for name, angle in exact.items():
        require(re.search(rf'\b{name}\s*\(\s*{angle}(?:\.0)?\s*\)', aspects) is not None,
                f'Missing exact {name}({angle}) aspect binding')
    require('_shortestSeparation' in aspects, 'Aspect detection must use normalized shortest separation')

    # RC-0043: orb policy is data/configuration, validated and injectable into build().
    for token in ['final class AspectOrbPolicy', 'maximumOrbDegrees', 'bodyAspectOverrides', 'orbPolicy', 'policy.validate()']:
        require(token in aspects, f'RC-0043 missing managed orb capability: {token}')
    require('const {' in aspects and 'MajorAspect.conjunction' in aspects, 'RC-0043 must expose a complete default policy')

    # RC-0045 / RC-0047: complete element and modality distributions.
    for token in ['enum WesternElement { fire, earth, air, water }', 'elementWeights', 'elementPercent']:
        require(token in distribution, f'RC-0045 missing element distribution capability: {token}')
    for token in ['enum WesternModality { cardinal, fixed, mutable }', 'modalityWeights', 'modalityPercent']:
        require(token in distribution, f'RC-0047 missing modality distribution capability: {token}')
    for sign in ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']:
        require(f'TropicalZodiacSign.{sign}' in distribution, f'Distribution mapping incomplete: {sign}')

    # RC-0050: classical domicile/exaltation/detriment/fall support.
    for token in ['domicile', 'exaltation', 'detriment', 'fall', '_domiciles', '_exaltations', '_opposite']:
        require(token in dignities, f'RC-0050 missing classical dignity capability: {token}')
    for body in ['sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter', 'saturn']:
        require(f'AstroBody.{body}' in dignities, f'RC-0050 classical dignity table missing {body}')

    # Guard against another shifted-semantic promotion.
    not_promoted = set(contract['intentionally_not_promoted'])
    require(not_promoted == {'RC-0042', 'RC-0044', 'RC-0046', 'RC-0048', 'RC-0049'},
            'Intentional non-promotion set changed; review exact binding semantics before editing')

    print('Exact RC-0036..RC-0050 Western binding validator passed.')


if __name__ == '__main__':
    main()
