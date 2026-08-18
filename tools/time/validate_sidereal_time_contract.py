#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/sidereal_time.json"
SOURCE = ROOT / "lib/src/calculation_core/time/sidereal_time.dart"
TEST = ROOT / "test/calculation_core/sidereal_time_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")

    require(manifest["reference"]["authority"] == "USNO Astronomical Applications", "USNO reference missing")
    require(manifest["inputs"] == ["JD_UT1", "JD_TT"], "sidereal inputs must remain explicit")
    require(manifest["policy"]["utcIsNotUt1"] is True, "UTC/UT1 separation policy weakened")

    for needle in (
        "required double julianDayUt1",
        "required double julianDayTt",
        "6.697375",
        "0.065707485828",
        "1.0027379",
        "0.0854103",
        "0.0000258",
        "normalizeHours",
    ):
        require(needle in source, f"sidereal source contract missing: {needle}")

    for needle in (
        "J2000 noon GMST reference",
        "J2000 previous midnight reference",
        "normalization stays in zero inclusive to 24 exclusive range",
        "non-finite inputs are rejected",
    ):
        require(needle in test, f"sidereal test contract missing: {needle}")

    print("sidereal-time contract: OK")


if __name__ == "__main__":
    main()
