#!/usr/bin/env python3
"""Materialize a multi-epoch/multi-body official NASA/JPL Horizons golden set.

This is a networked evidence-generation tool, never runtime code.  It expands
RC-1436/RC-1437 coverage beyond a single Earth/J2000 state while preserving an
exact per-vector query, API signature and raw-response SHA-256.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

API_URL = "https://ssd.jpl.nasa.gov/api/horizons.api"
EXPECTED_API_SOURCE = "NASA/JPL Horizons API"
J2000_JD_TDB = 2451545.0
SECONDS_PER_DAY = 86400.0

# Deliberately spans the supported product era and more than one SPK body graph.
CASES = (
    {"id": "earth_1900", "targetNaifId": 399, "jdTdb": 2415020.5},
    {"id": "earth_j2000", "targetNaifId": 399, "jdTdb": 2451545.0},
    {"id": "earth_2100", "targetNaifId": 399, "jdTdb": 2488069.5},
    {"id": "sun_j2000", "targetNaifId": 10, "jdTdb": 2451545.0},
    {"id": "moon_j2000", "targetNaifId": 301, "jdTdb": 2451545.0},
)

_FLOAT = re.compile(r"[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[Ee][+-]?\d+)?")


def _query(target: int, jd_tdb: float) -> dict[str, str]:
    return {
        "format": "json",
        "COMMAND": f"'{target}'",
        "OBJ_DATA": "'NO'",
        "MAKE_EPHEM": "'YES'",
        "EPHEM_TYPE": "'VECTORS'",
        "CENTER": "'@0'",
        "TLIST": f"'{jd_tdb:.1f}'",
        "TLIST_TYPE": "'JD'",
        "TIME_TYPE": "'TDB'",
        "REF_SYSTEM": "'ICRF'",
        "REF_PLANE": "'FRAME'",
        "VEC_TABLE": "'2'",
        "VEC_CORR": "'NONE'",
        "OUT_UNITS": "'KM-S'",
        "CSV_FORMAT": "'YES'",
    }


def _fetch(query: dict[str, str]) -> tuple[bytes, str]:
    encoded = urllib.parse.urlencode(query, safe="'@")
    url = f"{API_URL}?{encoded}"
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "RUHCODE-RC1436-coverage-materializer/1"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        if response.status != 200:
            raise RuntimeError(f"Horizons HTTP {response.status}")
        return response.read(), url


def _parse(payload: bytes) -> tuple[dict, list[float], str]:
    root = json.loads(payload)
    signature = root.get("signature")
    if not isinstance(signature, dict) or signature.get("source") != EXPECTED_API_SOURCE:
        raise RuntimeError(f"unexpected Horizons signature: {signature!r}")
    if not isinstance(signature.get("version"), str) or not signature["version"]:
        raise RuntimeError("Horizons signature version is missing")

    result = root.get("result")
    if not isinstance(result, str) or "$$SOE" not in result or "$$EOE" not in result:
        raise RuntimeError("Horizons result has no vector data section")
    section = result.split("$$SOE", 1)[1].split("$$EOE", 1)[0]
    rows = [line.strip() for line in section.splitlines() if line.strip()]
    if len(rows) != 1:
        raise RuntimeError(f"expected one Horizons vector row, got {len(rows)}")

    values = [float(token) for token in _FLOAT.findall(rows[0])]
    if len(values) < 7:
        raise RuntimeError(f"could not parse Horizons vector row: {rows[0]!r}")
    state = values[-6:]
    if not all(math.isfinite(value) for value in state):
        raise RuntimeError("Horizons returned a non-finite state")
    if sum(abs(value) for value in state[:3]) == 0:
        raise RuntimeError("Horizons returned a forbidden all-zero position")
    return signature, state, rows[0]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="evidence/rc1436/jpl_horizons_de440s_coverage.json",
    )
    args = parser.parse_args()

    captured = []
    for case in CASES:
        target = int(case["targetNaifId"])
        jd_tdb = float(case["jdTdb"])
        query = _query(target, jd_tdb)
        payload, request_url = _fetch(query)
        signature, state, raw_row = _parse(payload)
        captured.append(
            {
                "id": case["id"],
                "targetNaifId": target,
                "centerNaifId": 0,
                "epoch": {
                    "jdTdb": jd_tdb,
                    "etSecondsFromJ2000": (jd_tdb - J2000_JD_TDB) * SECONDS_PER_DAY,
                },
                "referenceSystem": "ICRF",
                "referencePlane": "FRAME",
                "corrections": "NONE",
                "units": "KM-S",
                "state": {
                    "xKm": state[0],
                    "yKm": state[1],
                    "zKm": state[2],
                    "vxKmPerSecond": state[3],
                    "vyKmPerSecond": state[4],
                    "vzKmPerSecond": state[5],
                },
                "source": {
                    "apiSignature": signature,
                    "requestUrl": request_url,
                    "query": query,
                    "rawResponseSha256": hashlib.sha256(payload).hexdigest(),
                    "rawCsvRow": raw_row,
                },
            }
        )

    evidence = {
        "schemaVersion": 1,
        "status": "OFFICIAL_GOLDEN_COVERAGE_CAPTURED",
        "provider": "NASA/JPL Horizons API",
        "endpoint": API_URL,
        "capturedAtUtc": datetime.now(timezone.utc).isoformat(),
        "observerNaifId": 0,
        "coverageIntent": {
            "epochs": ["1900", "J2000", "2100"],
            "bodies": ["Earth", "Sun", "Moon"],
            "rule": "Every vector must independently pass the repository SPK state tolerance contract.",
        },
        "vectors": captured,
        "provenanceRule": (
            "Do not edit numeric vector fields manually. Regenerate all vectors from "
            "the exact official queries with this materializer."
        ),
    }
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {output} with {len(captured)} official vectors")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
