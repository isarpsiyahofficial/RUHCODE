#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/solar_events.json"
SOURCE = ROOT / "lib/src/calculation_core/solar/solar_events.dart"
TEST = ROOT / "test/calculation_core/solar_events_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")

    policy = manifest["runtimePolicy"]
    require(policy["offlineOnly"] is True, "solar core must remain offline")
    require(policy["longitudeConvention"] == "east-positive", "longitude convention changed")
    require(policy["timezoneAppliedOutsideSolarCore"] is True, "timezone leaked into solar core")
    require(policy["polarDayNightMustBeExplicit"] is True, "polar state requirement missing")
    require(policy["fakeEventTimesForbidden"] is True, "fake polar event times must remain forbidden")
    require(
        abs(policy["apparentSunriseZenithDegrees"] - 90.83333333333333) < 1e-12,
        "apparent sunrise zenith changed",
    )

    for needle in (
        "enum SolarDayState",
        "polarDay",
        "polarNight",
        "apparentSunriseZenithDegrees",
        "sunriseUtcMinutes",
        "solarNoonUtcMinutes",
        "sunsetUtcMinutes",
        "throw RangeError",
    ):
        require(needle in source, f"solar source contract missing: {needle}")

    for needle in (
        "NOAA New York 2026-08-01 sunrise agrees within one minute",
        "northern polar summer is represented explicitly instead of fake times",
        "northern polar winter is represented explicitly instead of fake times",
        "coordinate ranges are strict",
    ):
        require(needle in test, f"solar test contract missing: {needle}")

    golden = manifest["reference"]["goldenCase"]
    require(golden["expectedUtcMinutes"] == 593, "NOAA golden sunrise changed")
    require(golden["toleranceMinutes"] == 1, "NOAA regression tolerance changed")
    require(manifest["limitations"]["finalAccuracyBudgetStillRequired"] is True, "final accuracy gate falsely closed")
    print("solar-events contract: OK")


if __name__ == "__main__":
    main()
