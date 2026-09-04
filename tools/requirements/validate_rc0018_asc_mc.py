#!/usr/bin/env python3
from __future__ import annotations
import csv, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0018_asc_mc_contract.json'


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId'] == 'RC-0018', 'wrong RC-0018 contract binding')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0018 self-promotion ceiling weakened')

    rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
    row = next((r for r in rows if r['rc_id'] == 'RC-0018'), None)
    require(row is not None, 'RC-0018 missing from requirement matrix')
    require(row['source_text_sha256'] == contract['bindingRequirementSha256'], 'RC-0018 binding SHA drift')

    for rel in contract['requiredRuntimeComponents'] + contract['requiredCompiledTests']:
        path = ROOT / rel
        require(path.is_file() and path.stat().st_size > 0, f'missing RC-0018 evidence: {rel}')

    asc = (ROOT / 'lib/src/calculation_core/western/asc_mc.dart').read_text(encoding='utf-8')
    sidereal = (ROOT / 'lib/src/calculation_core/time/sidereal_time.dart').read_text(encoding='utf-8')
    tests = (ROOT / 'test/calculation_core/western/asc_mc_test.dart').read_text(encoding='utf-8')
    sidereal_tests = (ROOT / 'test/calculation_core/sidereal_time_test.dart').read_text(encoding='utf-8')

    for needle in (
        'AscMcResult',
        'ascendantDegrees',
        'midheavenDegrees',
        'julianDayUt1',
        'julianDayTt',
        'longitudeDegreesEast',
        'latitudeDegreesNorth',
        'SiderealTime.greenwichMeanHours',
        'meanObliquityIau2006',
        '84381.406',
    ):
        require(needle in asc, f'RC-0018 runtime marker missing: {needle}')

    require('DateTime.now()' not in asc, 'RC-0018 ASC/MC must not depend on device clock')
    require('julianDayUt1' in sidereal and 'julianDayTt' in sidereal,
            'RC-0018 sidereal runtime must consume UT1 and TT explicitly')
    require('DateTime.now()' not in sidereal,
            'RC-0018 sidereal runtime must not depend on device clock')

    compact = re.sub(r'\s+', ' ', asc)
    require('math.atan2' in compact, 'RC-0018 must calculate spherical ASC/MC geometry rather than use a lookup')
    require('longitudeDegreesEast < -180.0' in compact and 'longitudeDegreesEast > 180.0' in compact,
            'RC-0018 longitude bounds must be fail-closed')
    require('latitudeDegreesNorth <= -90.0' in compact and 'latitudeDegreesNorth >= 90.0' in compact,
            'RC-0018 exact geographic poles must be fail-closed')

    for marker in ('equator cardinal sidereal angles', 'normalizes negative and >360',
                   'rejects exact geographic poles', 'IAU 2006 J2000 value'):
        require(marker in tests, f'RC-0018 compiled geometry regression missing: {marker}')
    require('USNO approximate formula gives J2000 noon GMST reference' in sidereal_tests,
            'RC-0018 sidereal reference regression missing')
    require('non-finite inputs are rejected' in sidereal_tests,
            'RC-0018 sidereal fail-closed regression missing')

    print('RC-0018 ASC/MC contract: OK')


if __name__ == '__main__':
    main()
