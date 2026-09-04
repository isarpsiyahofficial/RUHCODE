#!/usr/bin/env python3
from __future__ import annotations
import csv, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0020_solar_events_contract.json'


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId'] == 'RC-0020', 'wrong RC-0020 contract binding')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0020 self-promotion ceiling weakened')

    rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
    row = next((r for r in rows if r['rc_id'] == 'RC-0020'), None)
    require(row is not None, 'RC-0020 missing from requirement matrix')
    require(row['source_text_sha256'] == contract['bindingRequirementSha256'], 'RC-0020 binding SHA drift')

    for rel in contract['requiredRuntimeComponents'] + contract['requiredCompiledTests']:
        path = ROOT / rel
        require(path.is_file() and path.stat().st_size > 0, f'missing RC-0020 evidence: {rel}')

    runtime = (ROOT / 'lib/src/calculation_core/solar/solar_events.dart').read_text(encoding='utf-8')
    tests = (ROOT / 'test/calculation_core/solar_events_test.dart').read_text(encoding='utf-8')

    for marker in (
        'apparentSunriseZenithDegrees = 90.83333333333333',
        'required CivilDate date',
        'required double latitudeDegrees',
        'required double longitudeDegrees',
        'JulianDay.fromCivilDate(date)',
        '_equationOfTimeMinutes',
        '_sunDeclination',
        'SolarDayState.polarDay',
        'SolarDayState.polarNight',
        'Latitude must be within [-90, 90]',
        'Longitude must be within [-180, 180]',
    ):
        require(marker in runtime, f'RC-0020 runtime marker missing: {marker}')

    require('DateTime.now()' not in runtime, 'RC-0020 solar astronomy must not depend on device clock')
    # Comments may correctly document that localization belongs to a higher layer.
    # Fail only on concrete timezone/local-clock APIs inside the astronomy runtime.
    for forbidden in (
        'TZDateTime',
        'getLocation(',
        'initializeTimeZones(',
        '.toLocal()',
        'timeZoneOffset',
        "package:timezone/",
        "package:flutter_timezone/",
    ):
        require(forbidden not in runtime,
                f'RC-0020 astronomy layer must not silently localize timezone/DST: {forbidden}')

    for marker in (
        'NOAA New York 2026-08-01 sunrise agrees within one minute',
        'normal day preserves sunrise < noon < sunset in UTC timeline',
        'northern polar summer is represented explicitly instead of fake times',
        'northern polar winter is represented explicitly instead of fake times',
        'coordinate ranges are strict',
    ):
        require(marker in tests, f'RC-0020 compiled regression missing: {marker}')

    print('RC-0020 real solar events contract: OK')


if __name__ == '__main__':
    main()
