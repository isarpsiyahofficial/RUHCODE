#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0142_rc0148_bazi_four_pillars_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/bazi/bazi_four_pillars.dart"
TEST = ROOT / "test/calculation_core/bazi_four_pillars_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0142_RC0148_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")

    require(data.get("schema") == "ruh-code.rc0142-rc0148-bazi-four-pillars.v1", "contract schema drifted")
    expected = [f"RC-{i:04d}" for i in range(142, 149)]
    require(data.get("requirements") == expected, "requirement binding drifted")
    for number in range(142, 149):
        require(re.search(rf"(?m)^\s*{number}\.\s+", spec) is not None, f"binding specification no longer contains numbered requirement {number}")

    require("chinese_zodiac.dart" not in source, "BaZi must not depend on simple Chinese-zodiac implementation")
    for needle in (
        "enum BaziHeavenlyStem",
        "enum BaziEarthlyBranch",
        "enum BaziPillarKind { year, month, day, hour }",
        "abstract interface class BaziFourPillarsProvider",
        "yearCycleIndex",
        "monthCycleIndex",
        "dayCycleIndex",
        "hourCycleIndex",
        "stem: stems[cycleIndex % 10]",
        "branch: branches[cycleIndex % 12]",
        "sourceId",
        "version",
        "conventionId",
    ):
        require(needle in source, f"production evidence missing: {needle}")

    for needle in (
        "RC-0142 BaZi remains a distinct Four Pillars domain",
        "RC-0143..RC-0146 assemble Year Month Day Hour pillars independently",
        "RC-0147 and RC-0148 map cycle indices to canonical stems and branches",
        "BaZi provenance and convention are mandatory",
        "BaZi core rejects non-UTC birth instants",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")

    blockers = " ".join(data.get("dependency_blockers") or [])
    for phrase in ("production BaZi calendar provider", "solar-term", "golden", "TR/EN", "Free/PRO"):
        require(phrase in blockers, f"required blocker weakened: {phrase}")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle drifted")

    print("RC-0142..RC-0148 BaZi Four Pillars binding: OK")


if __name__ == "__main__":
    main()
