#!/usr/bin/env python3
"""Materialize an official JPL Horizons geometric state-vector golden.

This tool is intentionally networked and is not used by normal runtime code. It
captures the exact request, API signature, raw result SHA-256 and parsed state so
the offline DE440s evaluator can later be tested without contacting Horizons.
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

BASE_QUERY = {
    "format": "json",
    "COMMAND": "'399'",       # Earth
    "OBJ_DATA": "'NO'",
    "MAKE_EPHEM": "'YES'",
    "EPHEM_TYPE": "'VECTORS'",
    "CENTER": "'@0'",         # Solar-system barycenter
    "TLIST": "'2451545.0'",   # J2000 epoch
    "TLIST_TYPE": "'JD'",
    "TIME_TYPE": "'TDB'",
    "REF_SYSTEM": "'ICRF'",
    "REF_PLANE": "'FRAME'",
    "VEC_TABLE": "'2'",      # x,y,z,vx,vy,vz
    "VEC_CORR": "'NONE'",     # geometric, no aberration correction
    "OUT_UNITS": "'KM-S'",
    "CSV_FORMAT": "'YES'",
}

_FLOAT = re.compile(r"[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[Ee][+-]?\d+)?")


def _fetch(query: dict[str, str]) -> tuple[bytes, str]:
    encoded = urllib.parse.urlencode(query, safe="'@")
    url = f"{API_URL}?{encoded}"
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "RUHCODE-RC1436-golden-materializer/1"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        if response.status != 200:
            raise RuntimeError(f"Horizons HTTP {response.status}")
        return response.read(), url


def _parse(payload: bytes) -> tuple[dict, list[float], str]:
    root = json.loads(payload)
    signature = root.get("signature")
    if not isinstance(signature, dict):
        raise RuntimeError("Horizons response has no signature object")
    if signature.get("source") != EXPECTED_API_SOURCE:
        raise RuntimeError(f"unexpected Horizons signature source: {signature!r}")
    version = signature.get("version")
    if not isinstance(version, str) or not version:
        raise RuntimeError("Horizons signature version is missing")

    result = root.get("result")
    if not isinstance(result, str):
        raise RuntimeError("Horizons response has no textual result")
    if "$$SOE" not in result or "$$EOE" not in result:
        raise RuntimeError("Horizons result has no $$SOE/$$EOE data section")
    section = result.split("$$SOE", 1)[1].split("$$EOE", 1)[0]
    data_lines = [line.strip() for line in section.splitlines() if line.strip()]
    if len(data_lines) != 1:
        raise RuntimeError(f"expected exactly one Horizons vector row, got {len(data_lines)}")

    row = data_lines[0]
    values = [float(token) for token in _FLOAT.findall(row)]
    # CSV vector rows include JD followed by calendar date fields and state values;
    # the six state values are always the final six numbers for VEC_TABLE=2.
    if len(values) < 7:
        raise RuntimeError(f"could not parse Horizons vector row: {row!r}")
    state = values[-6:]
    if not all(math.isfinite(v) for v in state):
        raise RuntimeError("Horizons returned a non-finite state")
    if sum(abs(v) for v in state[:3]) == 0:
        raise RuntimeError("Horizons returned a forbidden all-zero position")
    return signature, state, row


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="evidence/rc1436/jpl_horizons_earth_ssb_j2000.json",
    )
    args = parser.parse_args()

    payload, request_url = _fetch(dict(BASE_QUERY))
    signature, state, raw_row = _parse(payload)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    evidence = {
        "schemaVersion": 1,
        "status": "OFFICIAL_GOLDEN_CAPTURED",
        "source": {
            "provider": "NASA/JPL Horizons API",
            "endpoint": API_URL,
            "apiSignature": signature,
            "requestUrl": request_url,
            "query": BASE_QUERY,
            "rawResponseSha256": hashlib.sha256(payload).hexdigest(),
            "capturedAtUtc": datetime.now(timezone.utc).isoformat(),
        },
        "vector": {
            "targetNaifId": 399,
            "centerNaifId": 0,
            "epoch": {"jdTdb": 2451545.0, "etSecondsFromJ2000": 0.0},
            "referenceSystem": "ICRF",
            "referencePlane": "FRAME",
            "corrections": "NONE",
            "units": "KM-S",
            "xKm": state[0],
            "yKm": state[1],
            "zKm": state[2],
            "vxKmPerSecond": state[3],
            "vyKmPerSecond": state[4],
            "vzKmPerSecond": state[5],
            "rawCsvRow": raw_row,
        },
        "provenanceRule": (
            "Do not edit numeric vector fields manually. Regenerate from the exact "
            "official query with this materializer and review the raw response SHA."
        ),
    }
    output.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {output}")
    print(f"raw response sha256={evidence['source']['rawResponseSha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
