#!/usr/bin/env python3
"""Fail closed on drift in committed RC-1436 solar-event oracle evidence."""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import Any


def _compare(expected: Any, actual: Any, path: str = "$") -> None:
    if isinstance(expected, dict):
        if not isinstance(actual, dict) or set(expected) != set(actual):
            raise SystemExit(f"{path}: object keys drifted")
        for key in expected:
            _compare(expected[key], actual[key], f"{path}.{key}")
        return
    if isinstance(expected, list):
        if not isinstance(actual, list) or len(expected) != len(actual):
            raise SystemExit(f"{path}: list shape drifted")
        for index, value in enumerate(expected):
            _compare(value, actual[index], f"{path}[{index}]")
        return
    if isinstance(expected, (int, float)) and not isinstance(expected, bool):
        if not isinstance(actual, (int, float)) or isinstance(actual, bool):
            raise SystemExit(f"{path}: numeric type drifted")
        if not math.isclose(float(expected), float(actual), rel_tol=0.0, abs_tol=1e-9):
            raise SystemExit(f"{path}: numeric drift {expected!r} != {actual!r}")
        return
    if expected != actual:
        raise SystemExit(f"{path}: value drift {expected!r} != {actual!r}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected", required=True)
    parser.add_argument("--actual", required=True)
    args = parser.parse_args()
    expected = json.loads(Path(args.expected).read_text(encoding="utf-8"))
    actual = json.loads(Path(args.actual).read_text(encoding="utf-8"))
    _compare(expected, actual)
    print("solar-event oracle evidence reproducible")


if __name__ == "__main__":
    main()
