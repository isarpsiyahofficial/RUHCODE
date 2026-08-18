#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/earth_orientation.json"
SOURCE = ROOT / "lib/src/calculation_core/time/earth_orientation.dart"
BUNDLED_SOURCE = ROOT / "lib/src/calculation_core/time/bundled_earth_orientation.dart"
TEST = ROOT / "test/calculation_core/earth_orientation_test.dart"
BUNDLED_TEST = ROOT / "test/calculation_core/bundled_earth_orientation_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (MANIFEST, SOURCE, BUNDLED_SOURCE, TEST, BUNDLED_TEST):
        require(path.exists(), f"missing earth-orientation contract file: {path.relative_to(ROOT)}")

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    bundled_source = BUNDLED_SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    bundled_test = BUNDLED_TEST.read_text(encoding="utf-8")

    policy = manifest["runtimePolicy"]
    require(policy["ut1MinusUtcRequired"] is True, "UT1-UTC requirement weakened")
    require(policy["utcMustNotSilentlySubstituteForUt1"] is True, "UTC substitution must remain forbidden")
    require(policy["offlineVersionedProviderRequired"] is True, "offline EOP provider requirement missing")
    require(policy["absoluteUt1MinusUtcLimitSeconds"] == 0.9, "UT1 steering limit changed")

    for needle in (
        "abstract interface class EarthOrientationProvider",
        "ut1MinusUtcSeconds",
        "sourceId",
        "dataVersion",
        "jdUt1",
        "jdTt",
        "throw StateError",
        "throw RangeError",
    ):
        require(needle in source, f"earth-orientation source contract missing: {needle}")

    for needle in (
        "EarthOrientationDatasetMetadata",
        "checksumSha256",
        "BundledEarthOrientationProvider",
        "maximumGap",
        "outside packaged EOP coverage",
        "interpolated",
    ):
        require(needle in bundled_source, f"bundled EOP loader contract missing: {needle}")

    for needle in (
        "UT1 Julian Day is derived from explicit UT1-UTC sample",
        "TT and UT1 remain separate values",
        "out-of-bound UT1-UTC is rejected",
        "mismatched EOP sample timestamp is rejected",
    ):
        require(needle in test, f"earth-orientation test contract missing: {needle}")

    for needle in (
        "interpolates UT1-UTC deterministically",
        "rejects extrapolation beyond packaged coverage",
        "rejects oversized dataset gaps",
    ):
        require(needle in bundled_test, f"bundled EOP test contract missing: {needle}")

    require(manifest["pendingRuntimeData"]["status"] == "NOT_DONE", "runtime EOP data must not be falsely marked done")
    print("earth-orientation contract: OK")


if __name__ == "__main__":
    main()
