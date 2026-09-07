#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0137_rc0141_chinese_zodiac_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/chinese/chinese_zodiac.dart"
TEST = ROOT / "test/calculation_core/chinese_zodiac_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0137_RC0141_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")

    require(data.get("schema") == "ruh-code.rc0137-rc0141-chinese-zodiac.v1", "contract schema drifted")
    expected = [f"RC-{i:04d}" for i in range(137, 142)]
    require(data.get("requirements") == expected, "requirement binding drifted")
    for number in range(137, 142):
        require(re.search(rf"(?m)^\s*{number}\.\s+", spec) is not None, f"binding specification no longer contains numbered requirement {number}")

    for needle in (
        "enum ChineseZodiacAnimal",
        "ChineseZodiacAnimal.rat",
        "ChineseZodiacAnimal.pig",
        "enum ChineseElement",
        "enum YinYang",
        "enum HeavenlyStem",
        "abstract interface class ChineseCalendarYearProvider",
        "ChineseCalendarYearResolution resolveYear(DateTime instantUtc)",
        "sexagenaryCycleIndex",
        "birthInstantUtc.isBefore(resolved.startUtc)",
        "!birthInstantUtc.isBefore(resolved.nextStartUtc)",
        "final stemIndex = cycle % 10",
        "final branchIndex = cycle % 12",
        "stemIndex.isEven ? YinYang.yang : YinYang.yin",
        "sourceId",
        "version",
    ):
        require(needle in source, f"production evidence missing: {needle}")

    for needle in (
        "RC-0137 exposes the canonical twelve-animal branch order",
        "RC-0138..RC-0140 derive animal, element and Yin/Yang from the resolved cycle",
        "RC-0141 keeps a pre-Chinese-New-Year birth in the preceding cycle year",
        "RC-0141 changes cycle exactly at the provider year boundary",
        "fails closed when provider interval misses the instant",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")

    blockers = " ".join(data.get("dependency_blockers") or [])
    require("authoritative Chinese New Year" in blockers, "Chinese New Year provider blocker was weakened")
    require("golden" in blockers, "independent golden-vector blocker was weakened")
    require("TR/EN" in blockers, "TR/EN product blocker was weakened")
    require("Free/PRO" in blockers, "Free/PRO product blocker was weakened")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle drifted")

    print("RC-0137..RC-0141 Chinese zodiac binding: OK")


if __name__ == "__main__":
    main()
