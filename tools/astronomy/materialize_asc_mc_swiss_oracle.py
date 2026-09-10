#!/usr/bin/env python3
"""Materialize an independent ASC/MC oracle for RC-1436.

This is evidence tooling only. It is intentionally independent from the Dart
production geometry and is not a runtime dependency of Ruh Code.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import swisseph as swe

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "evidence/rc1436/asc_mc_swiss_oracle.json"

CASES = (
    ("istanbul_2026", 2026, 9, 10, 5.0, 28.9784, 41.0082),
    ("new_york_2000", 2000, 1, 1, 12.0, -74.0060, 40.7128),
    ("sydney_2050", 2050, 6, 21, 0.0, 151.2093, -33.8688),
    ("reykjavik_1900", 1900, 3, 20, 18.0, -21.9426, 64.1466),
    ("quito_2100", 2100, 12, 1, 6.0, -78.4678, -0.1807),
)


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_evidence() -> dict[str, object]:
    provider_binary = Path(swe.__file__).resolve()
    cases: list[dict[str, object]] = []

    for case_id, year, month, day, decimal_hour, longitude, latitude in CASES:
        julian_day_ut1 = swe.julday(year, month, day, decimal_hour)
        julian_day_tt = julian_day_ut1 + swe.deltat(julian_day_ut1)
        _cusps, ascmc = swe.houses_ex(
            julian_day_ut1,
            latitude,
            longitude,
            b"P",
            swe.FLG_MOSEPH,
        )
        cases.append(
            {
                "id": case_id,
                "calendarUtc": {
                    "year": year,
                    "month": month,
                    "day": day,
                    "decimalHour": decimal_hour,
                },
                "julianDayUt1": julian_day_ut1,
                "julianDayTt": julian_day_tt,
                "longitudeDegreesEast": longitude,
                "latitudeDegreesNorth": latitude,
                "houseSystem": "Placidus",
                "oracle": {
                    "ascendantDegrees": ascmc[0],
                    "midheavenDegrees": ascmc[1],
                },
            }
        )

    return {
        "status": "INDEPENDENT_ASC_MC_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": swe.version,
        "providerBinary": {
            "sha256": _sha256(provider_binary),
        },
        "method": {
            "housesApi": "swe.houses_ex",
            "ephemerisFlag": "FLG_MOSEPH",
            "houseSystem": "P",
            "timeScaleNote": (
                "julianDayUt1 is passed to the independent houses oracle; "
                "julianDayTt is derived independently with swe.deltat for the "
                "production API input."
            ),
        },
        "accuracyBudget": {
            "source": "requirements/reference_manifests/astronomy_accuracy_budgets.json",
            "ascendantLongitudeMaxAbsErrorDegrees": 0.05,
            "mcLongitudeMaxAbsErrorDegrees": 0.05,
        },
        "coverage": {
            "crossLatitude": True,
            "crossLongitude": True,
            "crossHemisphere": True,
            "supportedDateRangeCases": [1900, 2000, 2026, 2050, 2100],
        },
        "cases": cases,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(build_evidence(), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(output)


if __name__ == "__main__":
    main()
