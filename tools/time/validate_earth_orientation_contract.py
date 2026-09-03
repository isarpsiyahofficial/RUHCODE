#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/earth_orientation.json"
SOURCE = ROOT / "lib/src/calculation_core/time/earth_orientation.dart"
BUNDLED_SOURCE = ROOT / "lib/src/calculation_core/time/bundled_earth_orientation.dart"
CAPABILITY_SOURCE = ROOT / "lib/src/calculation_core/time/earth_orientation_capability_policy.dart"
ASSET_LOADER = ROOT / "lib/src/calculation_core/time/iers_finals2000a_asset_loader.dart"
TEST = ROOT / "test/calculation_core/earth_orientation_test.dart"
BUNDLED_TEST = ROOT / "test/calculation_core/bundled_earth_orientation_test.dart"
CAPABILITY_TEST = ROOT / "test/calculation_core/earth_orientation_capability_policy_test.dart"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    required_paths = (
        MANIFEST,
        SOURCE,
        BUNDLED_SOURCE,
        CAPABILITY_SOURCE,
        ASSET_LOADER,
        TEST,
        BUNDLED_TEST,
        CAPABILITY_TEST,
    )
    for path in required_paths:
        require(path.exists(), f"missing earth-orientation contract file: {path.relative_to(ROOT)}")

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    source = SOURCE.read_text(encoding="utf-8")
    bundled_source = BUNDLED_SOURCE.read_text(encoding="utf-8")
    capability_source = CAPABILITY_SOURCE.read_text(encoding="utf-8")
    asset_loader = ASSET_LOADER.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    bundled_test = BUNDLED_TEST.read_text(encoding="utf-8")
    capability_test = CAPABILITY_TEST.read_text(encoding="utf-8")

    policy = manifest["runtimePolicy"]
    require(policy["ut1MinusUtcRequired"] is True, "UT1-UTC requirement weakened")
    require(policy["utcMustNotSilentlySubstituteForUt1"] is True, "UTC substitution must remain forbidden")
    require(policy["offlineVersionedProviderRequired"] is True, "offline EOP provider requirement missing")
    require(
        policy["outOfCoverageBehavior"] == "FAIL_CLOSED_OUTSIDE_PUBLISHED_EOP_COVERAGE",
        "published EOP coverage must remain fail-closed",
    )
    require(policy["absoluteUt1MinusUtcLimitSeconds"] == 0.9, "UT1 steering limit changed")
    require(policy["extrapolationAllowed"] is False, "EOP extrapolation must remain forbidden")
    require(policy["nearestNeighbourFallbackAllowed"] is False, "nearest-neighbour EOP fallback forbidden")
    require(policy["fabricatedFutureEopAllowed"] is False, "fabricated future EOP must remain forbidden")

    product_range = manifest["productDateRange"]
    require(product_range["startUtcInclusive"] == "1890-01-01T00:00:00Z", "product start date changed")
    require(product_range["endUtcExclusive"] == "2111-01-01T00:00:00Z", "product end date changed")

    runtime_data = manifest["runtimeData"]
    require(runtime_data["status"] == "BUNDLED_VERIFIED_SUBGATE", "physical EOP subgate not verified")
    require(runtime_data["fullRc1437Done"] is False, "runtime EOP subgate must not imply full RC-1437 DONE")
    require(runtime_data["networkDependencyAllowedInCalculationCore"] is False, "runtime EOP must remain offline")
    asset = ROOT / runtime_data["assetPath"]
    require(asset.exists(), f"missing physical IERS asset: {asset.relative_to(ROOT)}")
    payload = asset.read_bytes()
    require(len(payload) == runtime_data["byteSize"], "IERS asset byte size mismatch")
    require(hashlib.sha256(payload).hexdigest() == runtime_data["sha256"], "IERS asset SHA-256 mismatch")
    require(runtime_data["sha256"] in asset_loader, "asset loader checksum diverges from manifest")

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
        "productStartUtc = DateTime.utc(1890, 1, 1)",
        "productEndExclusiveUtc = DateTime.utc(2111, 1, 1)",
        "EOP_OUTSIDE_PUBLISHED_COVERAGE",
        "OUTSIDE_PRODUCT_DATE_RANGE",
        "EarthOrientationUnavailableException",
        "provider.sampleAt(utcInstant)",
    ):
        require(needle in capability_source, f"EOP capability policy missing: {needle}")

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

    for needle in (
        "product range is exactly 1890 through 2110",
        "valid product date outside EOP coverage fails closed explicitly",
        "outside product range is distinguished from missing EOP coverage",
        "non-UTC instants are rejected",
    ):
        require(needle in capability_test, f"EOP capability test contract missing: {needle}")

    print("earth-orientation contract: OK")


if __name__ == "__main__":
    main()
