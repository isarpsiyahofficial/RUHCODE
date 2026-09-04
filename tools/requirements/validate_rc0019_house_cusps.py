#!/usr/bin/env python3
from __future__ import annotations
import csv, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0019_house_cusps_contract.json'


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId'] == 'RC-0019', 'wrong RC-0019 contract binding')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0019 self-promotion ceiling weakened')

    rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
    row = next((r for r in rows if r['rc_id'] == 'RC-0019'), None)
    require(row is not None, 'RC-0019 missing from requirement matrix')
    require(row['source_text_sha256'] == contract['bindingRequirementSha256'], 'RC-0019 binding SHA drift')

    for rel in contract['requiredRuntimeComponents'] + contract['requiredCompiledTests']:
        path = ROOT / rel
        require(path.is_file() and path.stat().st_size > 0, f'missing RC-0019 evidence: {rel}')

    placidus = (ROOT / 'lib/src/calculation_core/western/placidus_houses.dart').read_text(encoding='utf-8')
    porphyry = (ROOT / 'lib/src/calculation_core/western/porphyry_houses.dart').read_text(encoding='utf-8')
    tests = (ROOT / 'test/calculation_core/western/placidus_houses_test.dart').read_text(encoding='utf-8')

    for needle in (
        'Expected 12 house cusps',
        'PlacidusHouses',
        '_solvePoleHeightCusp',
        'maxIterations = 100',
        'convergenceDegrees = 1e-10',
        'angles.ascendantDegrees',
        'angles.midheavenDegrees',
        'PlacidusFallbackPolicy.none',
        'PlacidusFallbackPolicy.explicitPorphyry',
        "effectiveSystem: 'UNAVAILABLE'",
        "effectiveSystem: 'PORPHYRY'",
        '_isOrderedHouseCycle',
    ):
        require(needle in placidus, f'RC-0019 Placidus runtime marker missing: {needle}')

    compact = re.sub(r'\s+', ' ', placidus)
    require('for (var iteration = 1; iteration <= maxIterations; iteration++)' in compact,
            'RC-0019 must solve intermediate Placidus cusps iteratively')
    require('math.asin' in compact and 'math.atan' in compact,
            'RC-0019 must use spherical geometry rather than fixed cusp lookup values')
    require('DateTime.now()' not in placidus and 'DateTime.now()' not in porphyry,
            'RC-0019 house cusps must not depend on device clock')

    for marker in (
        'converges for ordinary latitude and preserves angular/opposite cusps',
        'exact cusp belongs to the house beginning at that cusp',
        'polar-circle geometry is unavailable without explicit fallback',
        'Porphyry fallback is explicit and visible in metadata',
        'invalid latitude is rejected instead of silently normalized',
    ):
        require(marker in tests, f'RC-0019 compiled regression missing: {marker}')

    require('PorphyryHouses.calculate' in placidus,
            'RC-0019 explicit fallback must route through a separately identified Porphyry implementation')
    print('RC-0019 real house cusp contract: OK')


if __name__ == '__main__':
    main()
