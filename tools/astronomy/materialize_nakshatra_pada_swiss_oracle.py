#!/usr/bin/env python3
"""Materialize independent Lahiri Moon/Nakshatra/Pada evidence for RC-1436."""
from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
import swisseph as swe

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "evidence/rc1436/nakshatra_pada_swiss_oracle.json"
CASES = (
    ("equinox_1900", 1900, 3, 20, 12.0),
    ("j2000", 2000, 1, 1, 12.0),
    ("istanbul_release_2026", 2026, 9, 10, 12.0),
    ("solstice_2050", 2050, 6, 21, 0.0),
    ("late_range_2100", 2100, 12, 1, 6.0),
)
FLAGS = swe.FLG_MOSEPH | swe.FLG_SIDEREAL | swe.FLG_TRUEPOS | swe.FLG_NONUT

def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def build_evidence() -> dict[str, object]:
    swe.set_sid_mode(swe.SIDM_LAHIRI)
    rows = []
    for case_id, year, month, day, hour in CASES:
        jd_ut = swe.julday(year, month, day, hour)
        jd_tt = jd_ut + swe.deltat(jd_ut)
        values, retflags = swe.calc_ut(jd_ut, swe.MOON, FLAGS)
        longitude = values[0] % 360.0
        ayanamsha = swe.get_ayanamsa_ut(jd_ut)
        span = 360.0 / 27.0
        nak = int(longitude // span)
        within = longitude - nak * span
        pada = int(within // (span / 4.0)) + 1
        rows.append({
            "id": case_id,
            "calendarUtc": {"year": year, "month": month, "day": day, "decimalHour": hour},
            "julianDayUt1": jd_ut,
            "julianDayTt": jd_tt,
            "oracle": {
                "siderealMoonLongitudeDegrees": longitude,
                "lahiriAyanamshaDegrees": ayanamsha,
                "nakshatraIndexZeroBased": nak,
                "padaOneBased": pada,
            },
            "returnFlags": retflags,
        })
    binary = Path(swe.__file__).resolve()
    return {
        "status": "INDEPENDENT_NAKSHATRA_PADA_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": swe.version,
        "providerBinary": {"sha256": _sha256(binary)},
        "method": {
            "moonApi": "swe.calc_ut",
            "ephemerisFlag": "FLG_MOSEPH",
            "siderealMode": "SIDM_LAHIRI",
            "positionFlags": ["FLG_SIDEREAL", "FLG_TRUEPOS", "FLG_NONUT"],
            "coordinateSemantics": "geocentric true-position mean-ecliptic sidereal longitude; analytical Moshier backend independent from packaged DE440s",
        },
        "accuracyBudget": {
            "source": "requirements/reference_manifests/astronomy_accuracy_budgets.json",
            "nakshatraLongitudeMaxAbsErrorDegrees": 0.02,
            "padaLongitudeMaxAbsErrorDegrees": 0.02,
        },
        "coverage": {"supportedDateRangeCases": [1900, 2000, 2026, 2050, 2100]},
        "cases": rows,
    }

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(build_evidence(), indent=2) + "\n", encoding="utf-8")
    print(args.output.resolve())

if __name__ == "__main__":
    main()
