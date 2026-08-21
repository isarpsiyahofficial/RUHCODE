from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/karmic_debt.dart"
TEST = ROOT / "test/calculation_core/numerology/karmic_debt_test.dart"
EVIDENCE = ROOT / "evidence/numerology/karmic_debt.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanKarmicDebtEngine",
        "KarmicDebtObservation",
        "KarmicDebtFinding",
        "13: 4",
        "14: 5",
        "16: 7",
        "19: 1",
        "provenance",
        "singleDigit",
    ):
        require(token in source, f"Karmic Debt source missing token: {token}")

    for token in (
        "detects only canonical compounds with exact provenance",
        "reduced value alone never invents a Karmic Debt compound",
        "rejects mismatched compound and reduced values",
        "rejects duplicate metric observations",
        "requires non-empty provenance",
    ):
        require(token in test, f"Karmic Debt test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-KARMIC-DEBT-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    require("RC-0174" in evidence.get("requirements", []), "missing RC-0174")
    require("RC-0362" in evidence.get("requirements", []), "missing RC-0362")

    policy_text = json.dumps(evidence.get("policy", {}), ensure_ascii=False)
    require("reduced value alone never implies" in policy_text, "evidence must forbid reverse inference")

    print("Karmic Debt structural contract: OK")


if __name__ == "__main__":
    main()
