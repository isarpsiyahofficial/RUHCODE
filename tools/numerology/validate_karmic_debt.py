from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/karmic_debt.dart"
PROFILE_SOURCE = ROOT / "lib/src/calculation_core/numerology/pythagorean_profile.dart"
TEST = ROOT / "test/calculation_core/numerology/karmic_debt_test.dart"
EVIDENCE = ROOT / "evidence/numerology/karmic_debt.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    profile_source = PROFILE_SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanKarmicDebtEngine",
        "KarmicDebtObservation",
        "KarmicDebtFinding",
        "observationsFromProfile",
        "PythagoreanReductionTrace",
        "13: 4",
        "14: 5",
        "16: 7",
        "19: 1",
        "provenance",
        "singleDigit",
    ):
        require(token in source, f"Karmic Debt source missing token: {token}")

    require("PythagoreanReductionTrace" in profile_source, "Profile engine must preserve reduction traces")
    require("observedCompounds" in profile_source, "Profile trace must expose observed compounds")

    for token in (
        "detects only canonical compounds with exact provenance",
        "builds observations only from compounds actually seen upstream",
        "reduced value alone never invents a Karmic Debt compound",
        "rejects mismatched compound and reduced values",
        "rejects duplicate metric observations",
        "requires non-empty provenance",
    ):
        require(token in test, f"Karmic Debt test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-KARMIC-DEBT-V2", "unexpected contract id")
    require(evidence.get("engine_version") == "2", "unexpected engine version")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    require("RC-0174" in evidence.get("requirements", []), "missing RC-0174")
    require("RC-0362" in evidence.get("requirements", []), "missing RC-0362")

    policy_text = json.dumps(evidence.get("policy", {}), ensure_ascii=False)
    require("reduced value alone never implies" in policy_text, "evidence must forbid reverse inference")
    require("observationsFromProfile" in policy_text, "evidence must describe the profile provenance adapter")

    remaining = " ".join(evidence.get("remaining_before_done", []))
    require("Personal Year/Month/Day" in remaining, "cycle-provenance follow-up must remain explicit")

    print("Karmic Debt structural contract: OK")


if __name__ == "__main__":
    main()
