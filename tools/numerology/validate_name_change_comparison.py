from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/name_change_comparison.dart"
PROFILE = ROOT / "lib/src/calculation_core/numerology/pythagorean_profile.dart"
TEST = ROOT / "test/calculation_core/numerology/name_change_comparison_test.dart"
EVIDENCE = ROOT / "evidence/numerology/name_change_comparison.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    profile = PROFILE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanNameChangeComparisonEngine",
        "NumerologyNameMetric.expression",
        "NumerologyNameMetric.soulUrge",
        "NumerologyNameMetric.personality",
        "NumerologyNameMetric.maturity",
        "exact same birth date",
        "same reduction policy",
        "two different normalized names",
        "changedMetricCount",
    ):
        require(token in source, f"name-change source missing token: {token}")

    require("PythagoreanNameNormalizer" in profile, "name comparison must rely on canonical profile normalization")

    for token in (
        "compares only name-dependent metrics and preserves birth identity",
        "changed flag is transparent and no synthetic score is produced",
        "rejects different birth dates",
        "rejects mixed reduction policies and identical normalized names",
    ):
        require(token in test, f"name-change test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-NAME-CHANGE-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    require(evidence.get("todo_scope") == "Faz 14 — İsim değişikliği karşılaştırma desteği", "TODO mapping missing")

    invariants = " ".join(evidence.get("invariants", []))
    require("Life Path and Birthday remain unchanged" in invariants, "birth-derived invariant missing")
    require("no synthetic improvement" in invariants, "synthetic scoring prohibition missing")

    print("numerology name-change comparison structural contract: OK")


if __name__ == "__main__":
    main()
