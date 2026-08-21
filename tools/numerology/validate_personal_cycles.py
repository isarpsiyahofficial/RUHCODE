from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/personal_cycles.dart"
REDUCTION_SOURCE = ROOT / "lib/src/calculation_core/numerology/personal_day.dart"
KARMIC_SOURCE = ROOT / "lib/src/calculation_core/numerology/karmic_debt.dart"
TEST = ROOT / "test/calculation_core/numerology/personal_cycles_test.dart"
KARMIC_TEST = ROOT / "test/calculation_core/numerology/karmic_debt_test.dart"
EVIDENCE = ROOT / "evidence/numerology/personal_cycles.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    reduction_source = REDUCTION_SOURCE.read_text(encoding="utf-8")
    karmic_source = KARMIC_SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    karmic_test = KARMIC_TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "PythagoreanPersonalCycleEngine",
        "PythagoreanPersonalCycleResult",
        "PersonalCycleReductionPolicy",
        "PythagoreanPersonalDayEngine.calculate",
        "personalYearTrace",
        "personalMonthTrace",
        "personalDayTrace",
    ):
        require(token in source, f"personal cycle source missing required token: {token}")

    for token in (
        "PersonalCycleReductionTrace",
        "traceReduction",
        "observedCompounds",
        "personal_cycle.personal_year",
        "personal_cycle.personal_month",
        "personal_cycle.personal_day",
    ):
        require(token in reduction_source, f"personal cycle reduction source missing token: {token}")

    require("observationsFromPersonalCycles" in karmic_source, "Karmic Debt cycle adapter missing")

    for token in (
        "public cycle API remains in parity with DailySnapshot adapter",
        "different calendar years cannot collapse",
        "preserves exact compound reduction traces for cycle provenance",
        "preserveMasterNumbers",
    ):
        require(token in test, f"personal cycle test missing regression: {token}")

    require("builds cycle debt only from an observed cycle compound" in karmic_test, "cycle Karmic Debt provenance regression missing")
    require("<int>[13, 4]" in karmic_test, "canonical 13/4 cycle provenance fixture missing")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-PERSONAL-CYCLES-V2", "unexpected contract id")
    require(evidence.get("engine_version") == "2", "unexpected engine version")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-0174", "RC-0362", "RC-0364", "RC-0365", "RC-0366"):
        require(rc in evidence.get("requirements", []), f"missing requirement mapping: {rc}")

    invariants = " ".join(evidence.get("invariants", []))
    require("preserve exact source/intermediate reduction traces" in invariants, "trace invariant missing")
    require("never reverse-inferred" in invariants, "reverse-inference prohibition missing")

    print("personal cycle structural contract: OK")


if __name__ == "__main__":
    main()
