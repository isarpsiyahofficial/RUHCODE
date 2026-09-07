#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0136_planetary_hour_weekday_guidance_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/planetary_hours/planetary_hour_guidance.dart"
TEST = ROOT / "test/calculation_core/planetary_hour_weekday_guidance_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0136_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")

    require(data.get("schema") == "ruh-code.rc0136-planetary-hour-weekday-guidance.v1", "contract schema drifted")
    require(data.get("requirements") == ["RC-0136"], "requirement binding drifted")
    require(re.search(r"(?m)^\s*136\.\s+", spec) is not None, "binding specification no longer contains numbered requirement 136 for RC-0136")
    require(data.get("required_dimensions") == ["weekday", "planet"], "dimension binding drifted")
    require(data.get("required_combinations") == 49, "7x7 coverage requirement drifted")

    for needle in (
        "final CivilWeekday weekday;",
        "final ClassicalPlanet planet;",
        "PlanetaryHourWeekdayGuidanceCatalog",
        "for (final weekday in CivilWeekday.values)",
        "for (final planet in ClassicalPlanet.values)",
        "weekday guidance catalog must cover all 7x7 day/planet combinations",
        "interpretations.length < 2",
        "must not repeat one identical interpretation across all seven days",
        "catalog.forWeekdayPlanet(weekday, slot.ruler)",
        "List.unmodifiable(items)",
    ):
        require(needle in source, f"production evidence missing: {needle}")

    for needle in (
        "RC-0136 requires complete 7x7 weekday and planet coverage",
        "RC-0136 rejects one identical interpretation for a planet across all weekdays",
        "RC-0136 binds the active civil weekday and planet to every rendered hour item",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")

    blockers = " ".join(data.get("dependency_blockers") or [])
    require("TR/EN" in blockers, "authoritative TR/EN catalog blocker was weakened")
    require("AKILES" in blockers, "AKILES provenance blocker was weakened")
    require("Free/PRO" in blockers, "Free/PRO product blocker was weakened")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle drifted")

    print("RC-0136 weekday-specific planetary-hour guidance binding: OK")


if __name__ == "__main__":
    main()
