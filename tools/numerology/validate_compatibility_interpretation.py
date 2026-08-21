from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/interpretation/numerology_compatibility_interpretation.dart"
CALCULATION = ROOT / "lib/src/calculation_core/numerology/compatibility.dart"
TEST = ROOT / "test/interpretation/numerology_compatibility_interpretation_test.dart"
EVIDENCE = ROOT / "evidence/numerology/compatibility_interpretation.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    calculation = CALCULATION.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "NumerologyCompatibilityInterpretationKey",
        "NumerologyCompatibilityContentEntry",
        "NumerologyCompatibilityCatalog",
        "PythagoreanCompatibilityInterpretationEngine",
        "localeTag != 'tr' && localeTag != 'en'",
        "Compatibility catalog must contain exactly match+difference content",
        "Compatibility content cannot contain unresolved placeholders",
        "sourceRuleIds",
    ):
        require(token in source, f"compatibility interpretation source missing token: {token}")

    require("hidden percentage" in calculation, "calculation layer must explicitly reject hidden compatibility scoring")

    for token in (
        "TR and EN content stay separate from calculation values",
        "catalog rejects missing metric/state coverage",
        "content rejects blank locale text and unresolved placeholders",
        "unsupported locale never silently falls back",
    ):
        require(token in test, f"compatibility interpretation test missing regression: {token}")

    require(evidence.get("contract_id") == "NUM-PYTHAGOREAN-COMPATIBILITY-CONTENT-V1", "unexpected contract id")
    require(evidence.get("done") is False, "source-level content evidence must not claim DONE")
    for rc in ("RC-0181", "RC-0369", "RC-0412", "RC-0414", "RC-0415", "RC-0418", "RC-1073", "RC-1074"):
        require(rc in evidence.get("requirements", []), f"missing requirement mapping: {rc}")

    invariants = " ".join(evidence.get("invariants", []))
    require("separate layers" in invariants, "calculation/content separation invariant missing")
    require("unsupported locale tags fail closed" in invariants, "locale fail-closed invariant missing")
    require("No hidden percentage" in invariants, "hidden scoring prohibition missing")

    remaining = " ".join(evidence.get("remaining_before_done", []))
    require("Production editorial TR and EN" in remaining, "production editorial blocker must remain explicit")

    print("numerology compatibility interpretation structural contract: OK")


if __name__ == "__main__":
    main()
