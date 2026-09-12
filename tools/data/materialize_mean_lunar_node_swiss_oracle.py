#!/usr/bin/env python3
"""Materialize independent mean lunar ascending-node evidence for RC-1436."""
from __future__ import annotations

import json
import math
from pathlib import Path

import swisseph as swe

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "evidence/rc1436/mean_lunar_node_swiss_oracle.json"
EPOCHS = (
    ("1900-01-01", 2415020.5),
    ("2000-01-01T12", 2451545.0),
    ("2026-01-01", 2461041.5),
    ("2050-01-01", 2469807.5),
    ("2100-01-01", 2488069.5),
)
FLAGS = swe.FLG_MOSEPH | swe.FLG_TRUEPOS | swe.FLG_NONUT


def main() -> None:
    cases = []
    for case_id, jd_tt in EPOCHS:
        result, returned_flags = swe.calc(jd_tt, swe.MEAN_NODE, FLAGS)
        longitude = float(result[0]) % 360.0
        if not math.isfinite(longitude):
            raise RuntimeError(f"non-finite mean-node longitude for {case_id}")
        cases.append(
            {
                "id": case_id,
                "jdTt": jd_tt,
                "longitudeDegrees": longitude,
                "returnedFlags": int(returned_flags),
            }
        )

    payload = {
        "status": "INDEPENDENT_MEAN_LUNAR_NODE_ORACLE_CAPTURED",
        "provider": "Swiss Ephemeris via pyswisseph",
        "providerVersion": getattr(swe, "version", "unknown"),
        "body": "MEAN_NODE",
        "timeScale": "TT",
        "reference": "geocentric mean ascending lunar node, mean ecliptic/equinox of date",
        "requestedFlags": int(FLAGS),
        "coverage": {
            "caseCount": len(cases),
            "firstJdTt": EPOCHS[0][1],
            "lastJdTt": EPOCHS[-1][1],
        },
        "cases": cases,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)} with {len(cases)} mean-node cases")


if __name__ == "__main__":
    main()
