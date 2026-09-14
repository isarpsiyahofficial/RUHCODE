#!/usr/bin/env python3
"""RC-1436: verify packaged Lahiri data and oracle against pinned Swiss Ephemeris."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import swisseph as swe

ROOT = Path(__file__).resolve().parents[2]
ASSET = ROOT / "assets/data/ayanamsha/lahiri_chitrapaksha_5y.json"
EVIDENCE = ROOT / "evidence/rc1436/lahiri_ayanamsha_swiss_oracle.json"
MAX_REPRO_DRIFT_DEG = 1e-9
MAX_JD_DRIFT_DAY = 2e-8


def _canonical_sha(payload: dict) -> str:
    copy = dict(payload)
    copy.pop("dataSha256", None)
    raw = json.dumps(copy, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(raw).hexdigest()


def _assert_close(label: str, actual: float, expected: float, tolerance: float) -> None:
    if abs(actual - expected) > tolerance:
        raise SystemExit(
            f"{label} drifted: checked-in={actual:.15f} regenerated={expected:.15f} "
            f"delta={abs(actual-expected):.3e} tolerance={tolerance:.3e}"
        )


def main() -> None:
    asset = json.loads(ASSET.read_text(encoding="utf-8"))
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    if asset.get("id") != "lahiri-chitrapaksha":
        raise SystemExit("Unexpected packaged ayanamsha id")
    if asset.get("sourceVersion") != "pyswisseph-2.10.3.2":
        raise SystemExit("Packaged Lahiri source version is not pinned")
    if asset.get("dataSha256") != _canonical_sha(asset):
        raise SystemExit("Packaged Lahiri semantic SHA-256 does not match payload")
    if evidence.get("status") != "INDEPENDENT_LAHIRI_AYANAMSHA_ORACLE_CAPTURED":
        raise SystemExit("Independent Lahiri evidence status is invalid")

    swe.set_sid_mode(swe.SIDM_LAHIRI)

    samples = asset.get("samples", [])
    if len(samples) < 40:
        raise SystemExit("Packaged Lahiri table does not provide required date coverage density")
    for index, row in enumerate(samples):
        jd_tt = float(row["julianDayTt"])
        # Recover UT iteratively because the runtime table is keyed in TT.
        jd_ut = jd_tt
        for _ in range(3):
            jd_ut = jd_tt - swe.deltat(jd_ut)
        regenerated_tt = jd_ut + swe.deltat(jd_ut)
        regenerated = swe.get_ayanamsa_ut(jd_ut)
        _assert_close(f"asset sample {index} TT", jd_tt, regenerated_tt, MAX_JD_DRIFT_DAY)
        _assert_close(f"asset sample {index} ayanamsha", float(row["degrees"]), regenerated, MAX_REPRO_DRIFT_DEG)

    cases = evidence.get("cases", [])
    if len(cases) < 5:
        raise SystemExit("Independent Lahiri oracle requires at least five cases")
    for item in cases:
        jd_tt = float(item["julianDayTt"])
        jd_ut = jd_tt
        for _ in range(3):
            jd_ut = jd_tt - swe.deltat(jd_ut)
        regenerated = swe.get_ayanamsa_ut(jd_ut)
        _assert_close(
            f"oracle {item['id']}",
            float(item["lahiriAyanamshaDegrees"]),
            regenerated,
            MAX_REPRO_DRIFT_DEG,
        )

    print(
        f"verified {len(samples)} packaged Lahiri samples and {len(cases)} independent oracle cases"
    )


if __name__ == "__main__":
    main()
