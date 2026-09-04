#!/usr/bin/env python3
from __future__ import annotations
import csv, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0021_real_moon_phase_contract.json'


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId'] == 'RC-0021', 'wrong RC-0021 contract binding')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0021 self-promotion ceiling weakened')

    rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
    row = next((r for r in rows if r['rc_id'] == 'RC-0021'), None)
    require(row is not None, 'RC-0021 missing from requirement matrix')
    require(row['source_text_sha256'] == contract['bindingRequirementSha256'], 'RC-0021 binding SHA drift')

    for rel in contract['requiredRuntimeComponents'] + contract['requiredCompiledTests']:
        path = ROOT / rel
        require(path.is_file() and path.stat().st_size > 0, f'missing RC-0021 evidence: {rel}')

    runtime = (ROOT / 'lib/src/calculation_core/lunar/moon_phase.dart').read_text(encoding='utf-8')
    provider = (ROOT / 'lib/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart').read_text(encoding='utf-8')
    physical_test = (ROOT / 'test/calculation_core/rc0021_real_moon_phase_test.dart').read_text(encoding='utf-8')

    for marker in (
        'ephemeris.stateAt(body: AstroBody.sun, jdTt: jdTt)',
        'ephemeris.stateAt(body: AstroBody.moon, jdTt: jdTt)',
        'moon.longitudeDegrees - sun.longitudeDegrees',
        '(1.0 - math.cos(radians)) / 2.0',
        '_requireMatchingSample(sun, moon, jdTt)',
        'Moon phase cannot mix ephemeris source/version provenance.',
    ):
        require(marker in runtime, f'RC-0021 runtime marker missing: {marker}')

    for marker in (
        'NASA/JPL DE440s',
        'AstroBody.sun: 10',
        'AstroBody.moon: 301',
        'loadPackaged',
    ):
        require(marker in provider, f'RC-0021 physical provider marker missing: {marker}')

    for marker in (
        'De440sEphemerisProvider.loadPackaged()',
        "expect(result.sourceId, 'NASA/JPL DE440s')",
        'MoonPhaseName.newMoon',
        'MoonPhaseName.fullMoon',
    ):
        require(marker in physical_test, f'RC-0021 physical compiled test marker missing: {marker}')

    require('DateTime.now()' not in runtime, 'RC-0021 Moon phase runtime must not depend on device clock')
    print('RC-0021 real astronomical Moon phase contract: OK')


if __name__ == '__main__':
    main()
