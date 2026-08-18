#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/time_scales.json"
SOURCE = ROOT / "lib/src/calculation_core/time/time_scales.dart"
TEST = ROOT / "test/calculation_core/time_scales_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")

    require(manifest["runtimePolicy"]["ttMinusTaiSeconds"] == 32.184, "TT-TAI contract changed")
    built_in = manifest["builtInLeapSecondKnowledge"]
    require(built_in["latestTaiMinusUtcSeconds"] == 37, "unexpected latest TAI-UTC value")
    require(built_in["segmentCount"] == 28, "leap-second segment count changed")
    require(built_in["validUntilUtcExclusive"] == "2027-07-01T00:00:00Z", "coverage horizon changed")

    for needle in (
        "ttMinusTaiSeconds = 32.184",
        "DateTime.utc(1972, 1, 1)",
        "DateTime.utc(2017, 1, 1)",
        "DateTime.utc(2027, 7, 1)",
        "taiMinusUtcSeconds: 37",
        "throw RangeError",
    ):
        require(needle in source, f"time-scale source missing required contract: {needle}")

    for needle in (
        "USNO J2000 UTC instant maps to JD 2451545.0 TT",
        "pre-1972 UTC is rejected",
        "future UTC beyond known Bulletin C horizon is rejected",
        "TT is exactly TAI plus 32.184 seconds",
    ):
        require(needle in test, f"time-scale test missing required case: {needle}")

    authorities = {item["authority"] for item in manifest["references"]}
    require({"IAU SOFA", "USNO Astronomical Applications", "IERS Earth Orientation Center"} <= authorities,
            "authoritative time-scale references incomplete")

    print("time-scale contract: OK")


if __name__ == "__main__":
    main()
