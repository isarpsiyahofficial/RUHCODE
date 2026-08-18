#!/usr/bin/env python3
"""Validate and score independent astronomy golden datasets.

This runner deliberately does not generate reference values. It only consumes
versioned, attributable external golden records and evaluates supplied actual
values against the per-record tolerance. Missing actual values are reported as
UNVERIFIED rather than silently passing.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import pathlib
import sys
from dataclasses import dataclass


ALLOWED_METRICS = {
    "sun_longitude_deg",
    "moon_longitude_deg",
    "planet_longitude_deg",
    "node_longitude_deg",
    "ascendant_deg",
    "mc_deg",
    "house_cusp_deg",
    "sunrise_seconds",
    "sunset_seconds",
    "planetary_hour_boundary_seconds",
}


@dataclass(frozen=True)
class Result:
    record_id: str
    status: str
    error: float | None
    tolerance: float


def angular_error_deg(actual: float, expected: float) -> float:
    delta = abs((actual - expected) % 360.0)
    return min(delta, 360.0 - delta)


def sha256_file(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def validate_shape(data: dict) -> None:
    required = {"datasetId", "version", "source", "license", "generatedAtUtc", "records"}
    missing = required - data.keys()
    if missing:
        raise ValueError(f"dataset missing keys: {sorted(missing)}")

    source = data["source"]
    for key in ("name", "url", "retrievedAtUtc", "sha256"):
        if not source.get(key):
            raise ValueError(f"source.{key} is required")
    if len(source["sha256"]) != 64 or any(c not in "0123456789abcdef" for c in source["sha256"]):
        raise ValueError("source.sha256 must be lowercase 64-char SHA-256")

    license_info = data["license"]
    if not license_info.get("name"):
        raise ValueError("license.name is required")
    if not isinstance(license_info.get("redistributionAllowed"), bool):
        raise ValueError("license.redistributionAllowed must be boolean")

    ids: set[str] = set()
    for rec in data["records"]:
        for key in ("id", "metric", "instantUtc", "expected", "unit", "tolerance"):
            if key not in rec:
                raise ValueError(f"record missing {key}: {rec}")
        if rec["id"] in ids:
            raise ValueError(f"duplicate record id: {rec['id']}")
        ids.add(rec["id"])
        if rec["metric"] not in ALLOWED_METRICS:
            raise ValueError(f"unsupported metric {rec['metric']}")
        if rec["unit"] not in {"deg", "seconds"}:
            raise ValueError(f"unsupported unit {rec['unit']}")
        if not isinstance(rec["tolerance"], (int, float)) or rec["tolerance"] <= 0:
            raise ValueError(f"invalid tolerance for {rec['id']}")


def score(data: dict) -> list[Result]:
    results: list[Result] = []
    for rec in data["records"]:
        tolerance = float(rec["tolerance"])
        if "actual" not in rec:
            results.append(Result(rec["id"], "UNVERIFIED", None, tolerance))
            continue
        actual = float(rec["actual"])
        expected = float(rec["expected"])
        if not math.isfinite(actual) or not math.isfinite(expected):
            raise ValueError(f"non-finite value in {rec['id']}")
        if rec["unit"] == "deg":
            error = angular_error_deg(actual, expected)
        else:
            error = abs(actual - expected)
        results.append(Result(rec["id"], "PASS" if error <= tolerance else "FAIL", error, tolerance))
    return results


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("dataset", type=pathlib.Path)
    parser.add_argument("--require-actual", action="store_true", help="fail if any record lacks an actual value")
    parser.add_argument("--source-artifact", type=pathlib.Path, help="optional downloaded reference artifact whose SHA must match source.sha256")
    args = parser.parse_args()

    data = json.loads(args.dataset.read_text(encoding="utf-8"))
    validate_shape(data)

    if args.source_artifact:
        actual_sha = sha256_file(args.source_artifact)
        if actual_sha != data["source"]["sha256"]:
            print(f"SOURCE_SHA_MISMATCH expected={data['source']['sha256']} actual={actual_sha}")
            return 2

    results = score(data)
    counts = {status: sum(r.status == status for r in results) for status in ("PASS", "FAIL", "UNVERIFIED")}
    for r in results:
        suffix = "" if r.error is None else f" error={r.error:.12g} tolerance={r.tolerance:.12g}"
        print(f"{r.status} {r.record_id}{suffix}")
    print(f"SUMMARY records={len(results)} pass={counts['PASS']} fail={counts['FAIL']} unverified={counts['UNVERIFIED']}")

    if counts["FAIL"]:
        return 1
    if args.require_actual and counts["UNVERIFIED"]:
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
