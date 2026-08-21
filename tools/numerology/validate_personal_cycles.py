from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/personal_cycles.dart"
TEST = ROOT / "test/calculation_core/numerology/personal_cycles_test.dart"
EVIDENCE = ROOT / "evidence/numerology/personal_cycles.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanPersonalCycleEngine",
        "PythagoreanPersonalCycleResult",
        "PersonalCycleReductionPolicy",
        "PythagoreanPersonalDayEngine.calculate",
        "personalYear",
        "personalMonth",
        "personalDay",
    ):
        require(token in source, f"personal cycle source missing required token: {token}")

    for token in (
        "public cycle API remains in parity with DailySnapshot adapter",
        "different calendar years cannot collapse",
        "preserveMasterNumbers",
    ):
        require(token in test, f"personal cycle test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-PERSONAL-CYCLES-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    require("RC-0364" in evidence.get("requirements", []), "Personal Year RC missing")
    require("RC-0365" in evidence.get("requirements", []), "Personal Month RC missing")
    require("RC-0366" in evidence.get("requirements", []), "Personal Day RC missing")

    print("personal cycle structural contract: OK")


if __name__ == "__main__":
    main()
