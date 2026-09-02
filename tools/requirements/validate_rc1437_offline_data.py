#!/usr/bin/env python3
"""RC-1437 offline dataset release-readiness validator.

This validator is intentionally fail-closed in release mode. It never treats
source-selection manifests as proof that a physical runtime dataset is bundled.
Use --allow-incomplete only for progress/audit runs; release CI must omit it.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TIMEZONE = ROOT / "requirements/data_manifests/timezone.json"
CITIES = ROOT / "requirements/data_manifests/cities.json"
EPHEMERIS = ROOT / "requirements/reference_manifests/offline_ephemeris_runtime.json"
PUBSPEC = ROOT / "pubspec.yaml"
LOCK = ROOT / "pubspec.lock"

SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"{path}: root must be an object")
    return value


def sha_ok(value: object) -> bool:
    return isinstance(value, str) and bool(SHA256_RE.fullmatch(value))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--allow-incomplete",
        action="store_true",
        help="report blockers but return success; never use for a release gate",
    )
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()

    blockers: list[str] = []
    verified: list[str] = []

    for required in (TIMEZONE, CITIES, EPHEMERIS, PUBSPEC):
        if not required.is_file():
            blockers.append(f"missing required contract/file: {required.relative_to(ROOT)}")

    if blockers:
        payload = {"rc": "RC-1437", "ready": False, "verified": verified, "blockers": blockers}
        if args.json_output:
            args.json_output.parent.mkdir(parents=True, exist_ok=True)
            args.json_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(payload, indent=2))
        return 0 if args.allow_incomplete else 1

    timezone = load_json(TIMEZONE)
    cities = load_json(CITIES)
    ephemeris = load_json(EPHEMERIS)
    pubspec = PUBSPEC.read_text(encoding="utf-8")

    if timezone.get("offline") is True:
        verified.append("timezone manifest declares offline runtime")
    else:
        blockers.append("timezone manifest is not offline")

    package = timezone.get("runtime_package")
    version = timezone.get("runtime_package_version")
    if isinstance(package, str) and isinstance(version, str) and re.search(
        rf"(?m)^\s*{re.escape(package)}:\s*\^{re.escape(version)}\s*$", pubspec
    ):
        verified.append(f"timezone dependency version declared: {package} {version}")
    else:
        blockers.append("timezone runtime package/version does not match pubspec.yaml")

    if not LOCK.is_file():
        blockers.append("pubspec.lock is not tracked; exact timezone dependency cannot be release-pinned")
    else:
        verified.append("pubspec.lock is tracked")

    if cities.get("runtime_network_required") is False:
        verified.append("city manifest forbids runtime network dependency")
    else:
        blockers.append("city manifest permits/requires runtime network")

    if cities.get("status") != "BUNDLED_VERIFIED":
        blockers.append(f"city dataset status is {cities.get('status')!r}, not BUNDLED_VERIFIED")
    for key in ("source_artifact_sha256", "generated_catalog_sha256"):
        evidence = cities.get("release_evidence_required", {})
        if evidence.get(key) is not True:
            blockers.append(f"city manifest does not require {key}")

    planet = ephemeris.get("planetaryEphemeris", {})
    if planet.get("bundled") is not True:
        blockers.append("planetary ephemeris is not bundled")
    if planet.get("proven") is not True:
        blockers.append("planetary ephemeris is not proven")
    if not sha_ok(planet.get("sha256")):
        blockers.append("planetary ephemeris has no valid SHA-256")
    if not isinstance(planet.get("byteSize"), int) or planet.get("byteSize", 0) <= 0:
        blockers.append("planetary ephemeris byteSize is not recorded")

    eop = ephemeris.get("earthOrientation", {})
    if eop.get("bundled") is not True:
        blockers.append("earth-orientation dataset is not bundled")
    if eop.get("proven") is not True:
        blockers.append("earth-orientation dataset is not proven")
    if not sha_ok(eop.get("sha256")):
        blockers.append("earth-orientation dataset has no valid SHA-256")

    rules = ephemeris.get("runtimeRules", {})
    required_false = ("networkFallback", "nearestDateFallback", "zeroStateFallback")
    required_true = (
        "corruptionFailsClosed",
        "outOfCoverageFailsClosed",
        "independentGoldenEvidenceRequired",
        "cleanCheckoutReproducibilityRequired",
    )
    for key in required_false:
        if rules.get(key) is not False:
            blockers.append(f"ephemeris runtime rule {key} must be false")
    for key in required_true:
        if rules.get(key) is not True:
            blockers.append(f"ephemeris runtime rule {key} must be true")
    if all(rules.get(k) is False for k in required_false) and all(
        rules.get(k) is True for k in required_true
    ):
        verified.append("offline ephemeris fail-closed runtime policy is intact")

    # A physical release must expose non-message runtime datasets through Flutter
    # assets or a locked dependency. Source-selection documents alone are never
    # accepted as bundling evidence.
    if "assets/" not in pubspec:
        blockers.append("Flutter assets section is missing")
    if "ephemer" not in pubspec.lower():
        blockers.append("pubspec.yaml does not declare a physical ephemeris runtime asset")
    if "cities" not in pubspec.lower():
        blockers.append("pubspec.yaml does not declare a physical city runtime asset")

    payload = {
        "rc": "RC-1437",
        "ready": not blockers,
        "verified": verified,
        "blockers": blockers,
        "inputs": {
            "timezone_manifest_sha256": hashlib.sha256(TIMEZONE.read_bytes()).hexdigest(),
            "cities_manifest_sha256": hashlib.sha256(CITIES.read_bytes()).hexdigest(),
            "ephemeris_manifest_sha256": hashlib.sha256(EPHEMERIS.read_bytes()).hexdigest(),
        },
    }
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload, indent=2))
    return 0 if (not blockers or args.allow_incomplete) else 1


if __name__ == "__main__":
    sys.exit(main())
