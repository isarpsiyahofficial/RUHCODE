#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements/contracts/rc0149_rc0153_bazi_derived_analysis_contract.json"
SOURCE = ROOT / "lib/src/calculation_core/bazi/bazi_derived_analysis.dart"
TEST = ROOT / "test/calculation_core/bazi_derived_analysis_test.dart"
SPEC = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC0149_RC0153_FAIL: {message}")


def main() -> None:
    data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    spec = SPEC.read_text(encoding="utf-8")
    require(data.get("schema") == "ruh-code.rc0149-rc0153-bazi-derived-analysis.v1", "contract schema drifted")
    require(data.get("requirements") == [f"RC-{i:04d}" for i in range(149, 154)], "requirement binding drifted")
    for number in range(149, 154):
        require(re.search(rf"(?m)^\s*{number}\.\s+", spec) is not None, f"binding spec missing numbered requirement {number}")
    for needle in (
        "abstract final class BaziHiddenStems",
        "BaziEarthlyBranch.zi:",
        "BaziEarthlyBranch.hai:",
        "visible-plus-hidden-occurrences-v1",
        "final dayMaster = chart.day.stem",
        "enum BaziTenGod",
        "BaziTenGod.friend",
        "BaziTenGod.directResource",
        "tenGodFor",
    ):
        require(needle in source, f"production evidence missing: {needle}")
    for needle in (
        "RC-0149 maps all twelve Earthly Branches to Hidden Stem membership",
        "RC-0150 calculates explicit Five Elements occurrence distribution",
        "RC-0151 calculates Yin Yang balance",
        "RC-0152 identifies Day Master",
        "RC-0153 maps all ten Day-Master relationships for Jia",
    ):
        require(needle in test, f"compiled regression evidence missing: {needle}")
    blockers = " ".join(data.get("dependency_blockers") or [])
    for phrase in ("authoritative production BaZi calendar provider", "structural count", "RC-0154", "TR/EN", "Free/PRO"):
        require(phrase in blockers, f"required blocker weakened: {phrase}")
    require(data.get("lifecycle") == "TESTED_ONLY_WHEN_DEDICATED_GATE_PASSES", "lifecycle drifted")
    print("RC-0149..RC-0153 BaZi derived-analysis binding: OK")


if __name__ == "__main__":
    main()
