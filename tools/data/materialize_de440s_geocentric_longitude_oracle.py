#!/usr/bin/env python3
"""Materialize independent geocentric ECLIPJ2000 longitude evidence.

Production Ruh Code evaluates the packaged DE440s kernel with its own Dart
DAF/SPK reader. This oracle intentionally uses NAIF CSPICE through SpiceyPy,
reads the exact packaged kernel independently, converts TT Julian dates to ET
with CSPICE, and asks SPICE for geometric Earth-observed states directly in
its built-in ECLIPJ2000 frame.
"""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

import spiceypy as spice

ROOT = Path(__file__).resolve().parents[2]
KERNEL = ROOT / "assets/data/ephemeris/de440s.bsp"
OUTPUT = ROOT / "evidence/rc1436/de440s_geocentric_longitude_spice_oracle.json"

# Match the physical targets intentionally exposed by De440sEphemerisProvider.
TARGETS = (
    ("sun", 10),
    ("moon", 301),
    ("mercury", 1),
    ("venus", 2),
    ("mars", 4),
    ("jupiter", 5),
    ("saturn", 6),
    ("uranus", 7),
    ("neptune", 8),
    ("pluto", 9),
)

# TT Julian dates distributed through supported DE440s coverage. The dates are
# deliberately multi-century rather than a single modern-year sample.
EPOCHS = (
    ("1900-01-01", 2415020.5),
    ("2000-01-01T12", 2451545.0),
    ("2026-01-01", 2461041.5),
    ("2050-01-01", 2469807.5),
    ("2100-01-01", 2488069.5),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def normalize_degrees(value: float) -> float:
    result = value % 360.0
    return result + 360.0 if result < 0.0 else result


def main() -> None:
    if not KERNEL.is_file() or KERNEL.stat().st_size < 1_000_000:
        raise SystemExit(f"packaged DE440s kernel is missing or implausibly small: {KERNEL}")

    kernel_sha = sha256(KERNEL)
    spice.furnsh(str(KERNEL))
    try:
        cases = []
        for epoch_id, jd_tt in EPOCHS:
            # UNITIM provides an oracle-side TT/JDTDT -> ET conversion instead
            # of copying Ruh Code's low-order TT->TDB approximation.
            et = float(spice.unitim(jd_tt, "JDTDT", "ET"))
            for body, target in TARGETS:
                state, light_time = spice.spkgeo(target, et, "ECLIPJ2000", 399)
                if not math.isfinite(light_time) or light_time < 0.0:
                    raise RuntimeError(f"invalid geometric light time for {body}@{epoch_id}")
                x, y, z = (float(state[0]), float(state[1]), float(state[2]))
                if not all(math.isfinite(v) for v in (x, y, z)) or x == y == z == 0.0:
                    raise RuntimeError(f"invalid state for {body}@{epoch_id}")
                longitude = normalize_degrees(math.degrees(math.atan2(y, x)))
                cases.append(
                    {
                        "id": f"{body}-{epoch_id}",
                        "body": body,
                        "targetNaifId": target,
                        "observerNaifId": 399,
                        "jdTt": jd_tt,
                        "etSecondsFromJ2000": et,
                        "referenceFrame": "ECLIPJ2000",
                        "corrections": "NONE (geometric)",
                        "longitudeDegrees": longitude,
                    }
                )
    finally:
        spice.kclear()

    expected_count = len(TARGETS) * len(EPOCHS)
    if len(cases) != expected_count:
        raise RuntimeError(f"expected {expected_count} cases, got {len(cases)}")

    payload = {
        "status": "INDEPENDENT_DE440S_GEOCENTRIC_LONGITUDE_ORACLE_CAPTURED",
        "provider": "NAIF CSPICE via SpiceyPy",
        "purpose": "Independent geocentric ECLIPJ2000 longitude oracle for the packaged DE440s production runtime.",
        "kernel": {
            "path": "assets/data/ephemeris/de440s.bsp",
            "sha256": kernel_sha,
            "sizeBytes": KERNEL.stat().st_size,
        },
        "oracle": {
            "spiceypyVersion": getattr(spice, "__version__", "unknown"),
            "stateApi": "spkgeo",
            "timeApi": "unitim(JDTDT -> ET)",
            "referenceFrame": "ECLIPJ2000",
            "observerNaifId": 399,
            "aberrationCorrection": "NONE (geometric)",
        },
        "coverage": {
            "bodyCount": len(TARGETS),
            "epochCount": len(EPOCHS),
            "caseCount": expected_count,
            "firstJdTt": EPOCHS[0][1],
            "lastJdTt": EPOCHS[-1][1],
        },
        "cases": cases,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(
        f"wrote {OUTPUT.relative_to(ROOT)} with {len(cases)} cases; "
        f"kernel sha256={kernel_sha}"
    )


if __name__ == "__main__":
    main()
