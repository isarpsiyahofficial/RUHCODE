#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/ephemeris_runtime.json"
SOURCE = ROOT / "lib/src/calculation_core/ephemeris/ephemeris.dart"
TEST = ROOT / "test/calculation_core/ephemeris_contract_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")

    policy = manifest["runtimePolicy"]
    for key in (
        "offlineOnly",
        "ttJulianDayInputRequired",
        "versionedSourceRequired",
        "sha256Required",
        "coverageCheckRequired",
        "networkFallbackForbidden",
        "nearestDateFallbackForbidden",
        "zeroPositionFallbackForbidden",
        "retrogradeDerivedFromSignedLongitudeSpeed",
    ):
        require(policy[key] is True, f"ephemeris runtime policy weakened: {key}")

    for needle in (
        "abstract interface class EphemerisProvider",
        "final class EphemerisCoverage",
        "final class EclipticState",
        "checksumSha256",
        "requireContains",
        "longitudeSpeedDegreesPerDay",
        "ApparentMotion.retrograde",
        "ApparentMotion.stationary",
        "throw RangeError",
        "throw StateError",
    ):
        require(needle in source, f"ephemeris source contract missing: {needle}")

    for needle in (
        "coverage rejects invalid provenance and digest",
        "coverage rejects out-of-range TT requests",
        "direct stationary retrograde are derived from signed longitude speed",
        "sample provenance is mandatory",
    ):
        require(needle in test, f"ephemeris test contract missing: {needle}")

    require(
        manifest["pendingRuntimeDataset"]["status"] == "NOT_DONE",
        "ephemeris dataset must not be falsely marked done",
    )
    print("ephemeris contract: OK")


if __name__ == "__main__":
    main()
