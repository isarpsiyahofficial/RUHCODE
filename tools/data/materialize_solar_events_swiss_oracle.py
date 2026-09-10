#!/usr/bin/env python3
"""Materialize independent Swiss Ephemeris sunrise/sunset evidence for RC-1436.

Production SolarEvents contains its own NOAA/Meeus implementation and has no
Swiss Ephemeris dependency. This script is CI/evidence tooling only.
"""
from __future__ import annotations

import datetime as dt
import hashlib
import json
from pathlib import Path

import swisseph as swe

OUT = Path("evidence/rc1436/solar_events_swiss_oracle.json")
BUDGET = Path("requirements/reference_manifests/astronomy_accuracy_budgets.json")

CASES = [
    ("istanbul_2026", 2026, 9, 10, 41.0082, 28.9784, 180),
    ("new_york_2000", 2000, 6, 21, 40.7128, -74.0060, -240),
    ("sydney_2050", 2050, 12, 1, -33.8688, 151.2093, 660),
    ("reykjavik_1900", 1900, 4, 15, 64.1466, -21.9426, 0),
    ("quito_2100", 2100, 3, 20, -0.1807, -78.4678, -300),
]


def _provider_binary_sha256() -> str:
    binary = Path(swe.__file__)
    return hashlib.sha256(binary.read_bytes()).hexdigest()


def _julian_day_to_utc_datetime(jd: float) -> dt.datetime:
    year, month, day, decimal_hour = swe.revjul(jd, swe.GREG_CAL)
    micros = round(decimal_hour * 3600 * 1_000_000)
    return dt.datetime(year, month, day) + dt.timedelta(microseconds=micros)


def _event_for_civil_date(
    *,
    year: int,
    month: int,
    day: int,
    latitude: float,
    longitude: float,
    utc_offset_minutes: int,
    event_flag: int,
) -> float:
    jd_midnight = swe.julday(year, month, day, 0.0, swe.GREG_CAL)
    start = jd_midnight - 1.5
    target = (year, month, day)
    for _ in range(5):
        result, times = swe.rise_trans(
            start,
            swe.SUN,
            event_flag,
            (longitude, latitude, 0.0),
            0.0,
            0.0,
            swe.FLG_MOSEPH,
        )
        if result != 0:
            raise RuntimeError(
                f"No solar event for {target} at lat={latitude}, lon={longitude}"
            )
        event_jd = times[0]
        local = _julian_day_to_utc_datetime(event_jd) + dt.timedelta(
            minutes=utc_offset_minutes
        )
        if (local.year, local.month, local.day) == target:
            return event_jd
        start = event_jd + 1e-5
    raise RuntimeError(f"Could not select event belonging to civil date {target}")


def main() -> None:
    budget = json.loads(BUDGET.read_text(encoding="utf-8"))
    time_budget = budget["budgets"]["sunriseSunsetMaxAbsErrorSeconds"]
    cases = []
    for case_id, year, month, day, lat, lon, offset in CASES:
        jd_midnight = swe.julday(year, month, day, 0.0, swe.GREG_CAL)
        sunrise = _event_for_civil_date(
            year=year,
            month=month,
            day=day,
            latitude=lat,
            longitude=lon,
            utc_offset_minutes=offset,
            event_flag=swe.CALC_RISE,
        )
        sunset = _event_for_civil_date(
            year=year,
            month=month,
            day=day,
            latitude=lat,
            longitude=lon,
            utc_offset_minutes=offset,
            event_flag=swe.CALC_SET,
        )
        cases.append(
            {
                "id": case_id,
                "civilDate": {"year": year, "month": month, "day": day},
                "latitudeDegreesNorth": lat,
                "longitudeDegreesEast": lon,
                "utcOffsetMinutesForCivilDateSelection": offset,
                "julianDayUtcMidnight": jd_midnight,
                "oracle": {
                    "sunriseJulianDayUt": sunrise,
                    "sunsetJulianDayUt": sunset,
                    "sunriseUtcMinutesFromCivilDateMidnight": (
                        sunrise - jd_midnight
                    )
                    * 1440.0,
                    "sunsetUtcMinutesFromCivilDateMidnight": (sunset - jd_midnight)
                    * 1440.0,
                },
            }
        )

    payload = {
        "status": "INDEPENDENT_SOLAR_EVENTS_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": swe.version,
        "providerBinary": {"sha256": _provider_binary_sha256()},
        "method": {
            "riseSetApi": "swe.rise_trans",
            "body": "SUN",
            "ephemerisFlag": "FLG_MOSEPH",
            "atmosphere": {"pressureMbar": 0.0, "temperatureC": 0.0},
            "eventSelection": (
                "Independent oracle events are selected by explicit fixed UTC "
                "offset so the event belongs to the requested civil date; the "
                "production solar algorithm is not consulted."
            ),
            "independence": (
                "Production SolarEvents uses an internal NOAA/Meeus "
                "implementation and does not import or execute Swiss Ephemeris."
            ),
        },
        "accuracyBudget": {
            "source": str(BUDGET),
            "sunriseSunsetMaxAbsErrorSeconds": time_budget,
        },
        "coverage": {
            "crossLatitude": True,
            "crossLongitude": True,
            "crossHemisphere": True,
            "crossTimezone": True,
            "highLatitudeNonPolar": True,
            "supportedDateRangeCases": [1900, 2000, 2026, 2050, 2100],
        },
        "cases": cases,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
