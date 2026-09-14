#!/usr/bin/env python3
"""Verify regenerated Placidus oracle against committed RC-1436 evidence."""
from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_EXPECTED = ROOT / "evidence/rc1436/placidus_swiss_oracle.json"
HEX64 = re.compile(r"^[0-9a-f]{64}$")


def _load(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def _close(expected: float, actual: float, label: str) -> None:
    if not math.isclose(expected, actual, rel_tol=0.0, abs_tol=1e-10):
        raise SystemExit(f"{label} drift: expected={expected!r} actual={actual!r}")


def verify(expected: dict[str, object], actual: dict[str, object]) -> None:
    for key in ("status", "provider", "providerVersion", "method", "accuracyBudget", "coverage"):
        if expected.get(key) != actual.get(key):
            raise SystemExit(f"Placidus oracle metadata drift at {key}")
    for document, label in ((expected, "expected"), (actual, "actual")):
        binary = document.get("providerBinary")
        if not isinstance(binary, dict) or not HEX64.fullmatch(str(binary.get("sha256", ""))):
            raise SystemExit(f"{label} provider binary SHA-256 missing/invalid")
    expected_cases = expected.get("cases")
    actual_cases = actual.get("cases")
    if not isinstance(expected_cases, list) or not isinstance(actual_cases, list):
        raise SystemExit("Placidus oracle cases must be arrays")
    if len(expected_cases) != len(actual_cases):
        raise SystemExit("Placidus oracle case-count drift")
    actual_by_id = {str(item["id"]): item for item in actual_cases}
    if len(actual_by_id) != len(actual_cases):
        raise SystemExit("Fresh Placidus oracle contains duplicate case IDs")
    scalar_fields = ("julianDayUt1", "julianDayTt", "longitudeDegreesEast", "latitudeDegreesNorth")
    for expected_case in expected_cases:
        case_id = str(expected_case["id"])
        actual_case = actual_by_id.get(case_id)
        if actual_case is None:
            raise SystemExit(f"Fresh Placidus oracle missing case {case_id}")
        for key in ("calendarUtc", "houseSystem"):
            if expected_case.get(key) != actual_case.get(key):
                raise SystemExit(f"{case_id} metadata drift at {key}")
        for key in scalar_fields:
            _close(float(expected_case[key]), float(actual_case[key]), f"{case_id}.{key}")
        expected_oracle = expected_case["oracle"]
        actual_oracle = actual_case["oracle"]
        for key in ("ascendantDegrees", "midheavenDegrees"):
            _close(float(expected_oracle[key]), float(actual_oracle[key]), f"{case_id}.oracle.{key}")
        expected_cusps = expected_oracle["cuspsDegrees"]
        actual_cusps = actual_oracle["cuspsDegrees"]
        if len(expected_cusps) != 12 or len(actual_cusps) != 12:
            raise SystemExit(f"{case_id} must contain exactly 12 cusps")
        for index, (expected_cusp, actual_cusp) in enumerate(zip(expected_cusps, actual_cusps), start=1):
            _close(float(expected_cusp), float(actual_cusp), f"{case_id}.cusp{index}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected", type=Path, default=DEFAULT_EXPECTED)
    parser.add_argument("--actual", type=Path, required=True)
    args = parser.parse_args()
    verify(_load(args.expected.resolve()), _load(args.actual.resolve()))
    print("Placidus independent oracle regeneration is deterministic.")


if __name__ == "__main__":
    main()
