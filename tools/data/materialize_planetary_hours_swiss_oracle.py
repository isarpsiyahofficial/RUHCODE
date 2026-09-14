#!/usr/bin/env python3
"""Materialize independent planetary-hour boundary evidence for RC-1436."""
from __future__ import annotations

import datetime as dt
import hashlib
import json
from pathlib import Path

import swisseph as swe

OUT = Path("evidence/rc1436/planetary_hours_swiss_oracle.json")
BUDGET = Path("requirements/reference_manifests/astronomy_accuracy_budgets.json")
CASES = [
    ("istanbul_2026", 2026, 9, 10, 41.0082, 28.9784, 180),
    ("new_york_2000", 2000, 6, 21, 40.7128, -74.0060, -240),
    ("sydney_2050", 2050, 12, 1, -33.8688, 151.2093, 660),
    ("reykjavik_1900", 1900, 4, 15, 64.1466, -21.9426, 0),
    ("quito_2100", 2100, 3, 20, -0.1807, -78.4678, -300),
]


def _jd_to_datetime(jd: float) -> dt.datetime:
    year, month, day, hour = swe.revjul(jd, swe.GREG_CAL)
    return dt.datetime(year, month, day) + dt.timedelta(seconds=hour * 3600.0)


def _event(year: int, month: int, day: int, lat: float, lon: float, offset: int, flag: int) -> float:
    target = (year, month, day)
    start = swe.julday(year, month, day, 0.0, swe.GREG_CAL) - 1.5
    for _ in range(6):
        result, times = swe.rise_trans(
            start, swe.SUN, flag, (lon, lat, 0.0), 0.0, 0.0, swe.FLG_MOSEPH
        )
        if result != 0:
            raise RuntimeError(f"No solar event for {target} at {lat},{lon}")
        event_jd = times[0]
        local = _jd_to_datetime(event_jd) + dt.timedelta(minutes=offset)
        if (local.year, local.month, local.day) == target:
            return event_jd
        start = event_jd + 1e-5
    raise RuntimeError(f"Could not select solar event for civil date {target}")


def main() -> None:
    budget = json.loads(BUDGET.read_text(encoding="utf-8"))
    boundary_budget = budget["budgets"]["planetaryHourBoundaryMaxAbsErrorSeconds"]
    cases = []
    for case_id, year, month, day, lat, lon, offset in CASES:
        base = swe.julday(year, month, day, 0.0, swe.GREG_CAL)
        sunrise = _event(year, month, day, lat, lon, offset, swe.CALC_RISE)
        sunset = _event(year, month, day, lat, lon, offset, swe.CALC_SET)
        following = dt.date(year, month, day) + dt.timedelta(days=1)
        next_sunrise = _event(
            following.year, following.month, following.day, lat, lon, offset, swe.CALC_RISE
        )
        if not sunrise < sunset < next_sunrise:
            raise RuntimeError(f"Non-increasing independent anchors for {case_id}")
        boundaries = [sunrise + (sunset - sunrise) * k / 12.0 for k in range(13)]
        boundaries += [sunset + (next_sunrise - sunset) * k / 12.0 for k in range(1, 13)]
        cases.append(
            {
                "id": case_id,
                "civilDate": {"year": year, "month": month, "day": day},
                "latitudeDegreesNorth": lat,
                "longitudeDegreesEast": lon,
                "utcOffsetMinutesForCivilDateSelection": offset,
                "oracle": {
                    "sunriseJulianDayUt": sunrise,
                    "sunsetJulianDayUt": sunset,
                    "nextSunriseJulianDayUt": next_sunrise,
                    "boundaryUtcMinutesFromCivilDateMidnight": [
                        (value - base) * 1440.0 for value in boundaries
                    ],
                },
            }
        )

    binary = Path(swe.__file__)
    payload = {
        "status": "INDEPENDENT_PLANETARY_HOUR_BOUNDARY_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": swe.version,
        "providerBinary": {"sha256": hashlib.sha256(binary.read_bytes()).hexdigest()},
        "method": {
            "riseSetApi": "swe.rise_trans",
            "body": "SUN",
            "ephemerisFlag": "FLG_MOSEPH",
            "boundaryDefinition": "13 daylight boundaries divide independent sunrise-to-sunset into 12 equal temporal hours; 12 following boundaries divide sunset-to-next-sunrise into 12 equal temporal hours, for 25 unique boundaries total.",
            "independence": "Swiss Ephemeris supplies all three solar anchors; production PlanetaryHours and SolarEvents are not imported or executed by the oracle materializer.",
        },
        "accuracyBudget": {
            "source": str(BUDGET),
            "planetaryHourBoundaryMaxAbsErrorSeconds": boundary_budget,
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
    OUT.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
