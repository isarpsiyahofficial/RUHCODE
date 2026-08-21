from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/pinnacles_challenges.dart"
TEST = ROOT / "test/calculation_core/numerology/pinnacles_challenges_test.dart"
EVIDENCE = ROOT / "evidence/numerology/pinnacles_challenges.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanPinnacleChallengeEngine",
        "pinnacles",
        "challenges",
        "36 - lifePath",
        "firstPeriodEndAgeInclusive",
        "secondPeriodEndAgeInclusive",
        "thirdPeriodEndAgeInclusive",
        "difference == 0",
    ):
        require(token in source, f"pinnacle/challenge source missing token: {token}")

    for token in (
        "four Pinnacles and four Challenges",
        "period boundaries are explicit inclusive ages",
        "zero challenge remains zero",
    ):
        require(token in test, f"pinnacle/challenge test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-PINNACLES-CHALLENGES-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-0179", "RC-0180"):
        require(rc in evidence.get("requirements", []), f"missing requirement {rc}")

    print("pinnacle/challenge structural contract: OK")


if __name__ == "__main__":
    main()
