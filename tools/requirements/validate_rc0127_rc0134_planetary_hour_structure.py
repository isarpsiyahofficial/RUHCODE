#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0127_rc0134_planetary_hour_structure_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/planetary_hours/planetary_hours.dart"
TEST = ROOT / "test/calculation_core/planetary_hours_rc0127_rc0134_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"

EXPECTED = [f"RC-{n:04d}" for n in range(127, 135)]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0127_RC0134_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")

    require(data.get("schema") == "ruh-code.rc0127-rc0134-planetary-hour-structure.v1", "contract schema drifted")
    require(data.get("requirements") == EXPECTED, "requirement coverage/order drifted")
    require(data.get("production") == "lib/src/calculation_core/planetary_hours/planetary_hours.dart", "production binding drifted")
    require(data.get("regression") == "test/calculation_core/planetary_hours_rc0127_rc0134_test.dart", "regression binding drifted")

    # The binding specification is a numbered list; RC-0127 maps to item 127, etc.
    # Match line starts so a substring such as 1270 cannot satisfy RC-0127.
    for rc in EXPECTED:
        number = int(rc.split("-")[1])
        require(
            re.search(rf"(?m)^\s*{number}\.\s+", spec) is not None,
            f"binding specification no longer contains numbered requirement {number} for {rc}",
        )

    for needle in (
        "SolarEvents.forDate",
        "final sunrise =",
        "final sunset =",
        "final nextSunrise =",
        "_appendTwelve(",
        "final totalMicros = end.difference(start).inMicroseconds",
        "totalMicros * i / 12",
        "totalMicros * (i + 1) / 12",
        "static const List<ClassicalPlanet> chaldeanOrder",
        "firstRulerIndex",
        "offset: 12",
        "List.unmodifiable(slots)",
        "CivilWeekday.monday => ClassicalPlanet.moon",
    ):
        require(needle in source, f"production evidence missing: {needle}")

    for needle in (
        "RC-0127/0128 day arc equals sunset minus sunrise and is split by 12",
        "RC-0129/0130 night arc equals next sunrise minus sunset and is split by 12",
        "RC-0131/0132 first hour uses the civil weekday classical ruler",
        "RC-0133 every subsequent hour advances in Chaldean order",
        "RC-0134 exposes a contiguous ordered 24-slot list",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")

    blockers = " ".join(data.get("dependency_blockers") or [])
    for rc in ("RC-0124", "RC-0125", "RC-0126"):
        require(rc in blockers, f"AKILES dependency blocker {rc} must remain explicit")
    require("golden" in blockers.lower(), "independent AKILES golden evidence blocker was weakened")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle gate drifted")

    print("RC-0127..RC-0134 planetary-hour binding: OK")


if __name__ == "__main__":
    main()
