#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "evidence" / "astronomy" / "western_porphyry_houses.json"
SOURCE = ROOT / "lib" / "src" / "calculation_core" / "western" / "porphyry_houses.dart"
TEST = ROOT / "test" / "calculation_core" / "western" / "porphyry_houses_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    require(MANIFEST.is_file(), f"missing manifest: {MANIFEST}")
    require(SOURCE.is_file(), f"missing source: {SOURCE}")
    require(TEST.is_file(), f"missing test: {TEST}")

    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    require(data.get("contract") == "western_porphyry_houses", "wrong contract id")
    require(data.get("version") == 1, "unexpected contract version")

    requirements = set(data.get("requirements", []))
    for rc in {"RC-0060", "RC-0061", "RC-0262", "RC-0268", "RC-1436"}:
        require(rc in requirements, f"missing requirement mapping: {rc}")

    rules = "\n".join(data.get("hard_rules", [])).lower()
    for phrase in (
        "asc is cusp 1",
        "mc is cusp 10",
        "three equal ecliptic arcs",
        "exact cusp longitude",
        "fallback",
        "never silent",
    ):
        require(phrase in rules, f"missing hard rule phrase: {phrase}")

    accuracy = data.get("accuracy", {})
    require(accuracy.get("upstream_angle_budget_degrees") == 0.05, "wrong upstream angle budget")
    require(accuracy.get("independent_end_to_end_golden_proven") is False,
            "golden proof must remain false until real independent evidence exists")
    require(data.get("status") == "SOURCE_LEVEL_ONLY", "status must remain SOURCE_LEVEL_ONLY")

    source = SOURCE.read_text(encoding="utf-8")
    require("class PorphyryHouses" in source, "PorphyryHouses API missing")
    require("q1 / 3.0" in source and "q4 / 3.0" in source, "quadrant trisection missing")
    require("fallback" in source.lower(), "explicit fallback warning missing from source comments")

    tests = TEST.read_text(encoding="utf-8")
    for phrase in (
        "preserves ASC/IC/DSC/MC as angular cusps",
        "divides each quadrant into three equal ecliptic arcs",
        "assigns an exact cusp to that cusp house",
        "rejects invalid and degenerate angular geometry",
    ):
        require(phrase in tests, f"missing required test: {phrase}")

    print("western Porphyry house contract: OK")


if __name__ == "__main__":
    main()
