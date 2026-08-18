#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/planetary_hours_runtime.json"
SOURCE = ROOT / "lib/src/calculation_core/planetary_hours/planetary_hours.dart"
TEST = ROOT / "test/calculation_core/planetary_hours_test.dart"
DAILY_FACTOR = ROOT / "lib/src/calculation_core/daily/planetary_hour_factor.dart"
DAILY_FACTOR_TEST = ROOT / "test/calculation_core/planetary_hour_daily_factor_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    daily_factor = DAILY_FACTOR.read_text(encoding="utf-8")
    daily_factor_test = DAILY_FACTOR_TEST.read_text(encoding="utf-8")
    policy = manifest["runtimePolicy"]

    require(policy["offlineOnly"] is True, "planetary hours must remain offline")
    require(policy["daySegments"] == 12 and policy["nightSegments"] == 12, "12+12 subdivision changed")
    require(policy["weekdayRulerDerivedFromCivilCalendar"] is True, "weekday ruler must be calculated")
    require(policy["polarFakeTimesForbidden"] is True, "polar fake-time prohibition weakened")
    require(policy["chaldeanOrder"] == ["saturn", "jupiter", "mars", "sun", "venus", "mercury", "moon"], "Chaldean order changed")

    for needle in (
        "enum ClassicalPlanet",
        "chaldeanOrder",
        "CivilWeekday.monday => ClassicalPlanet.moon",
        "CivilWeekday.tuesday => ClassicalPlanet.mars",
        "SolarEvents.forDate",
        "nextDate = date.addDays(1)",
        "slots: const []",
        "not fabricated",
    ):
        require(needle in source, f"planetary-hours source contract missing: {needle}")

    for needle in (
        "Monday starts with Moon and follows Chaldean sequence",
        "day and night are each divided into exactly twelve contiguous slots",
        "weekday ruler advances naturally to the next civil date",
        "polar boundaries return unavailable instead of fabricated planetary hours",
    ):
        require(needle in test, f"planetary-hours test contract missing: {needle}")

    for needle in (
        "identity.civilDate.addDays(-1)",
        "DailyFactorKind.planetaryHour",
        "sourceEngineId: engineId",
        "result.date.isoKey",
        "slot.startUtc.toIso8601String()",
    ):
        require(needle in daily_factor, f"DailySnapshot planetary-hour binding missing: {needle}")

    for needle in (
        "daytime DailySnapshot factor comes from real planetary-hour slots",
        "before sunrise checks previous planetary day instead of civil-midnight reset",
        "non-UTC query instant is rejected",
    ):
        require(needle in daily_factor_test, f"DailySnapshot planetary-hour test missing: {needle}")

    require(manifest["validation"]["akilesPhysical6400GoldenDataset"] == "NOT_DONE", "AKILES golden dataset must not be falsely marked done")
    print("planetary-hours contract: OK")


if __name__ == "__main__":
    main()
