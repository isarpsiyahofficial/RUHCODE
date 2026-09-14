#!/usr/bin/env python3
"""Fail closed when regenerated RC-1436 Nakshatra/Pada evidence drifts."""
from __future__ import annotations
import argparse, json, math, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = ROOT / "evidence/rc1436/nakshatra_pada_swiss_oracle.json"
SHA256 = re.compile(r"^[0-9a-f]{64}$")

def _compare(expected, actual, path="root"):
    if path.endswith("providerBinary.sha256"):
        if not isinstance(expected, str) or not isinstance(actual, str) or not SHA256.fullmatch(expected) or not SHA256.fullmatch(actual):
            raise SystemExit(f"{path}: both provider binaries must carry valid SHA-256 provenance")
        return
    if isinstance(expected, bool) or isinstance(actual, bool):
        if expected != actual:
            raise SystemExit(f"{path}: {actual!r} != {expected!r}")
        return
    if isinstance(expected, (int, float)) and isinstance(actual, (int, float)):
        if not math.isclose(float(expected), float(actual), rel_tol=0.0, abs_tol=1e-9):
            raise SystemExit(f"{path}: {actual!r} != {expected!r}")
        return
    if isinstance(expected, dict) and isinstance(actual, dict):
        if set(expected) != set(actual):
            raise SystemExit(f"{path}: object keys drifted")
        for key in expected:
            _compare(expected[key], actual[key], f"{path}.{key}")
        return
    if isinstance(expected, list) and isinstance(actual, list):
        if len(expected) != len(actual):
            raise SystemExit(f"{path}: list length drifted")
        for index, (left, right) in enumerate(zip(expected, actual)):
            _compare(left, right, f"{path}[{index}]")
        return
    if expected != actual:
        raise SystemExit(f"{path}: {actual!r} != {expected!r}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--actual", type=Path, required=True)
    args = parser.parse_args()
    expected = json.loads(EXPECTED.read_text(encoding="utf-8"))
    actual = json.loads(args.actual.read_text(encoding="utf-8"))
    _compare(expected, actual)
    print("RC-1436 Nakshatra/Pada independent oracle evidence is reproducible.")

if __name__ == "__main__":
    main()
