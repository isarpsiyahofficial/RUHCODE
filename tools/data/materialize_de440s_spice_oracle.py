#!/usr/bin/env python3
"""Materialize an independent NAIF SPICE oracle for the packaged DE440s kernel.

The production application contains its own DAF/SPK Type-2 reader. This tool
intentionally does not import or reuse any production evaluator code. It asks
NAIF CSPICE, through the thin SpiceyPy binding, to evaluate the exact packaged
kernel and records deterministic target/epoch states for CI comparison.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

import spiceypy as spice

ROOT = Path(__file__).resolve().parents[2]
KERNEL = ROOT / "assets/data/ephemeris/de440s.bsp"
OUTPUT = ROOT / "evidence/rc1436/de440s_naif_spice_oracle.json"

CASES = (
    ("earth-j1900", 399, 2415020.5),
    ("earth-j2000", 399, 2451545.0),
    ("earth-j2100", 399, 2488069.5),
    ("sun-j2000", 10, 2451545.0),
    ("moon-j2000", 301, 2451545.0),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    if not KERNEL.is_file() or KERNEL.stat().st_size < 1_000_000:
        raise SystemExit(f"packaged DE440s kernel is missing or implausibly small: {KERNEL}")

    kernel_sha = sha256(KERNEL)
    spice.furnsh(str(KERNEL))
    try:
        vectors = []
        for case_id, target, jd_tdb in CASES:
            et = (jd_tdb - 2451545.0) * 86400.0
            state, light_time = spice.spkgeo(target, et, "J2000", 0)
            if light_time < 0:
                raise RuntimeError(f"negative geometric light time for {case_id}")
            vectors.append(
                {
                    "id": case_id,
                    "targetNaifId": target,
                    "observerNaifId": 0,
                    "epoch": {
                        "jdTdb": jd_tdb,
                        "etSecondsFromJ2000": et,
                    },
                    "frame": "J2000",
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
                }
            )
    finally:
        spice.kclear()

    payload = {
        "status": "INDEPENDENT_DE440S_ORACLE_CAPTURED",
        "provider": "NAIF CSPICE via SpiceyPy",
        "purpose": "Independent reader oracle for Ruh Code's packaged DE440s SPK; production Dart DAF/SPK evaluator is not reused.",
        "kernel": {
            "path": "assets/data/ephemeris/de440s.bsp",
            "sha256": kernel_sha,
            "sizeBytes": KERNEL.stat().st_size,
        },
        "oracle": {
            "spiceypyVersion": getattr(spice, "__version__", "unknown"),
            "api": "spkgeo",
            "referenceFrame": "J2000",
            "aberrationCorrection": "NONE (geometric state)",
        },
        "vectors": vectors,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)} with {len(vectors)} vectors; kernel sha256={kernel_sha}")


if __name__ == "__main__":
    main()
