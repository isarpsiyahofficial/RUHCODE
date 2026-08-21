#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/calculation_core/numerology/pythagorean_snapshot.dart"
TEST = ROOT / "test/calculation_core/numerology/pythagorean_snapshot_test.dart"
EVIDENCE = ROOT / "evidence/numerology/pythagorean_snapshot.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(SOURCE.exists(), "Missing Pythagorean snapshot source")
    require(TEST.exists(), "Missing Pythagorean snapshot tests")
    require(EVIDENCE.exists(), "Missing Pythagorean snapshot evidence")

    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    required_source_tokens = [
        "PythagoreanProfileEngine.calculate",
        "PythagoreanExtendedNameEngine.calculate",
        "PythagoreanPinnacleChallengeEngine.calculate",
        "PythagoreanPersonalCycleEngine.calculate",
        "PythagoreanKarmicDebtEngine.observationsFromProfile",
        "PythagoreanKarmicDebtEngine.observationsFromPersonalCycles",
        "targetDate != null",
        "Life Path drift detected",
        "name normalization drift detected",
    ]
    for token in required_source_tokens:
        require(token in source, f"Snapshot source missing contract token: {token}")

    required_test_tokens = [
        "assembles one consistent static snapshot",
        "exact requested target date",
        "retain upstream compound provenance",
        "stay unchanged when only target date changes",
        "CivilDate(2026, 8, 16)",
        "CivilDate(2027, 8, 16)",
    ]
    for token in required_test_tokens:
        require(token in test, f"Snapshot tests missing contract case: {token}")

    require(evidence.get("done") is False, "Source-level snapshot must not claim DONE")
    require(
        evidence.get("engine") == "numerology.pythagorean.snapshot",
        "Unexpected snapshot engine id",
    )
    invariants = evidence.get("invariants", [])
    require(len(invariants) >= 5, "Snapshot evidence needs explicit invariants")
    blockers = evidence.get("notProvenYet", [])
    require(bool(blockers), "Snapshot evidence must retain unresolved proof blockers")

    print("Pythagorean snapshot contract: OK")


if __name__ == "__main__":
    main()
