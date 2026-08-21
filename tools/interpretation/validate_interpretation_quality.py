from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/interpretation/interpretation_engine.dart"
TEST = ROOT / "test/interpretation/interpretation_quality_guard_test.dart"
EVIDENCE = ROOT / "evidence/interpretation/quality_guard.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "interpretationVersion",
        "InterpretationQualityException",
        "InterpretationQualityGuard",
        "Unresolved placeholder",
        "Duplicate interpretation ruleId",
        "Duplicate interpretation item",
        "Repeated interpretation sentence",
    ):
        require(token in source, f"interpretation quality source missing token: {token}")

    for token in (
        "accepts versioned unique interpretation bundle",
        "rejects unspecified version and item/rule length mismatch",
        "rejects unresolved placeholders and duplicate rule IDs",
        "rejects duplicate normalized items",
        "rejects repeated sentence beyond configured frequency",
    ):
        require(token in test, f"interpretation quality test missing regression: {token}")

    require(evidence.get("contract_id") == "INTERPRETATION-QUALITY-GUARD-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-1066", "RC-1067", "RC-1073", "RC-1074", "RC-1075", "RC-1076"):
        require(rc in evidence.get("requirements", []), f"missing requirement mapping: {rc}")

    remaining = " ".join(evidence.get("remaining_before_done", []))
    require("RC-1077 and RC-1078" in remaining, "semantic contradiction scope must remain explicit")

    print("interpretation quality structural contract: OK")


if __name__ == "__main__":
    main()
