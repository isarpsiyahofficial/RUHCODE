#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0135_planetary_hour_guidance_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/planetary_hours/planetary_hour_guidance.dart"
TEST = ROOT / "test/calculation_core/planetary_hour_guidance_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0135_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")

    require(data.get("schema") == "ruh-code.rc0135-planetary-hour-guidance.v1", "contract schema drifted")
    require(data.get("requirements") == ["RC-0135"], "requirement binding drifted")
    require(re.search(r"(?m)^\s*135\.\s+", spec) is not None, "binding specification no longer contains numbered requirement 135 for RC-0135")

    required_fields = [
        "planet", "startUtc", "endUtc", "quality", "interpretation",
        "proAction", "doNot", "mantra", "sourceId", "version",
    ]
    require(data.get("required_fields") == required_fields, "required field set/order drifted")
    for field in required_fields:
        require(f"final {'ClassicalPlanet' if field == 'planet' else 'DateTime' if field in ('startUtc', 'endUtc') else 'String'} {field};" in source,
                f"production field missing: {field}")

    for needle in (
        "ClassicalPlanet.values.where",
        "duplicate guidance rule",
        "must not be empty",
        "hours.slots.length != 24",
        "slot.startUtc.isBefore(slot.endUtc)",
        "List.unmodifiable(items)",
    ):
        require(needle in source, f"fail-closed production evidence missing: {needle}")

    for needle in (
        "RC-0135 requires a complete seven-planet guidance catalog",
        "RC-0135 rejects empty editorial/provenance fields",
        "RC-0135 binds every hour to planet/time/guidance/provenance fields",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")

    blockers = " ".join(data.get("dependency_blockers") or [])
    require("TR/EN" in blockers, "authoritative TR/EN editorial blocker was weakened")
    require("AKILES" in blockers, "AKILES provenance blocker was weakened")
    require("Free/PRO" in blockers, "Free/PRO product blocker was weakened")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle drifted")

    print("RC-0135 planetary-hour guidance binding: OK")


if __name__ == "__main__":
    main()
