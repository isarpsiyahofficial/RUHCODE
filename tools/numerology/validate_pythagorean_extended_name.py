from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/pythagorean_extended_name.dart"
TEST = ROOT / "test/calculation_core/numerology/pythagorean_extended_name_test.dart"
EVIDENCE = ROOT / "evidence/numerology/pythagorean_extended_name.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanExtendedNameEngine",
        "balance",
        "karmicLessons",
        "hiddenPassions",
        "valueFrequencies",
        "PythagoreanNameNormalizer.normalize",
    ):
        require(token in source, f"extended-name source missing token: {token}")

    for token in (
        "Balance, Karmic Lessons and Hidden Passion",
        "unsupported characters are rejected",
        "frequency map always covers",
    ):
        require(token in test, f"extended-name test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-EXTENDED-NAME-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-0172", "RC-0173", "RC-0175"):
        require(rc in evidence.get("requirements", []), f"missing requirement {rc}")
    require(
        "Karmic Debt remains a separate unfinished requirement" in " ".join(evidence.get("remaining_before_done", [])),
        "evidence must not imply Karmic Debt completion",
    )

    print("extended Pythagorean name structural contract: OK")


if __name__ == "__main__":
    main()
