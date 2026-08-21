from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/compatibility.dart"
TEST = ROOT / "test/calculation_core/numerology/compatibility_test.dart"
EVIDENCE = ROOT / "evidence/numerology/compatibility.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanCompatibilityEngine",
        "lifePath",
        "expression",
        "soulUrge",
        "personality",
        "birthday",
        "maturity",
        "absoluteDifference",
        "exactMatchCount",
        "same reduction policy",
    ):
        require(token in source, f"compatibility source missing token: {token}")

    for token in (
        "without hidden scoring",
        "identical profiles produce six exact matches",
        "different reduction policies",
    ):
        require(token in test, f"compatibility test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-COMPATIBILITY-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-0181", "RC-0369"):
        require(rc in evidence.get("requirements", []), f"missing requirement {rc}")

    score_semantics = evidence.get("policy", {}).get("score_semantics", "")
    require("No synthetic percentage" in score_semantics, "hidden compatibility score must be forbidden")

    print("numerology compatibility structural contract: OK")


if __name__ == "__main__":
    main()
