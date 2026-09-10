#!/usr/bin/env python3
"""Materialize independent Swiss Ephemeris Placidus cusp evidence for RC-1436.

The production runtime contains its own Placidus implementation and has no
Swiss Ephemeris dependency. This script is CI/evidence tooling only.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

import swisseph as swe

OUT = Path("evidence/rc1436/placidus_swiss_oracle.json")
BUDGET = Path("requirements/reference_manifests/astronomy_accuracy_budgets.json")

CASES = [
    ("istanbul_2026", 2026, 9, 10, 5.0, 41.0082, 28.9784),
    ("new_york_2000", 2000, 1, 1, 12.0, 40.7128, -74.0060),
    ("sydney_2050", 2050, 6, 21, 0.0, -33.8688, 151.2093),
    ("reykjavik_1900", 1900, 3, 20, 18.0, 64.1466, -21.9426),
    ("quito_2100", 2100, 12, 1, 6.0, -0.1807, -78.4678),
]


def _provider_binary_sha256() -> str:
    binary = Path(swe.__file__)
    return hashlib.sha256(binary.read_bytes()).hexdigest()


def main() -> None:
    budget = json.loads(BUDGET.read_text(encoding="utf-8"))
    cusp_budget = budget["budgets"]["houseCuspLongitudeMaxAbsErrorDegrees"]
    cases = []
    for case_id, year, month, day, hour, lat, lon in CASES:
        jd_ut1 = swe.julday(year, month, day, hour, swe.GREG_CAL)
        jd_tt = jd_ut1 + swe.deltat(jd_ut1)
        cusps, ascmc = swe.houses_ex(jd_ut1, lat, lon, b"P", swe.FLG_MOSEPH)
        if len(cusps) != 12:
            raise RuntimeError(f"{case_id}: expected 12 Placidus cusps, got {len(cusps)}")
        cases.append({
            "id": case_id,
            "calendarUtc": {"year": year, "month": month, "day": day, "decimalHour": hour},
            "julianDayUt1": jd_ut1,
            "julianDayTt": jd_tt,
            "longitudeDegreesEast": lon,
            "latitudeDegreesNorth": lat,
            "houseSystem": "Placidus",
            "oracle": {
                "cuspsDegrees": list(cusps),
                "ascendantDegrees": ascmc[0],
                "midheavenDegrees": ascmc[1],
            },
        })

    payload = {
        "status": "INDEPENDENT_PLACIDUS_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": swe.version,
        "providerBinary": {"sha256": _provider_binary_sha256()},
        "method": {
            "housesApi": "swe.houses_ex",
            "ephemerisFlag": "FLG_MOSEPH",
            "houseSystem": "P",
            "independence": "Production Placidus solver does not import or execute Swiss Ephemeris.",
            "timeScaleNote": "julianDayUt1 is passed to the independent house oracle; julianDayTt is derived independently with swe.deltat for the production ASC/MC input.",
        },
        "accuracyBudget": {
            "source": str(BUDGET),
            "houseCuspLongitudeMaxAbsErrorDegrees": cusp_budget,
        },
        "coverage": {
            "crossLatitude": True,
            "crossLongitude": True,
            "crossHemisphere": True,
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
