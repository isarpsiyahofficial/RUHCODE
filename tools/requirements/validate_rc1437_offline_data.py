#!/usr/bin/env python3
"""RC-1437 offline dataset release-readiness validator.

This validator is intentionally fail-closed in release mode. It never treats
source-selection manifests as proof that a physical runtime dataset is bundled.
Use --allow-incomplete only for progress/audit runs; release CI must omit it.
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TIMEZONE = ROOT / "requirements/data_manifests/timezone.json"
CITIES = ROOT / "requirements/data_manifests/cities.json"
CITY_EVIDENCE = ROOT / "requirements/evidence/rc1437_city_snapshot.json"
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


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_city_bundle(cities: dict, pubspec: str, blockers: list[str], verified: list[str]) -> None:
    if cities.get("runtime_network_required") is False:
        verified.append("city manifest forbids runtime network dependency")
    else:
        blockers.append("city manifest permits/requires runtime network")

    if cities.get("status") != "BUNDLED_VERIFIED":
        blockers.append(f"city dataset status is {cities.get('status')!r}, not BUNDLED_VERIFIED")

    evidence_policy = cities.get("release_evidence_required", {})
    for key in ("source_artifact_sha256", "generated_catalog_sha256"):
        if evidence_policy.get(key) is not True:
            blockers.append(f"city manifest does not require {key}")

    if not CITY_EVIDENCE.is_file():
        blockers.append("physical city evidence JSON is missing")
        return
    evidence = load_json(CITY_EVIDENCE)
    if evidence.get("rc") != "RC-1437" or evidence.get("dataset_id") != cities.get("dataset_id"):
        blockers.append("city evidence identity does not match RC-1437 city manifest")
    if evidence.get("runtime_network_required") is not False:
        blockers.append("city evidence does not prove offline runtime policy")
    if evidence.get("snapshot_date_utc") != cities.get("source_snapshot_date"):
        blockers.append("city evidence snapshot date does not match manifest")

    manifest_sources = cities.get("source_artifacts", {})
    evidence_sources = evidence.get("source_artifacts", {})
    required_sources = cities.get("required_source_artifacts", [])
    if not required_sources:
        blockers.append("city manifest has no required source artifacts")
    for name in required_sources:
        manifest_row = manifest_sources.get(name, {})
        evidence_row = evidence_sources.get(name, {})
        manifest_sha = manifest_row.get("sha256")
        evidence_sha = evidence_row.get("sha256")
        size = manifest_row.get("byte_size")
        if not sha_ok(manifest_sha) or evidence_sha != manifest_sha:
            blockers.append(f"city source artifact {name} lacks matching SHA-256 evidence")
        if not isinstance(size, int) or size <= 0 or evidence_row.get("byte_size") != size:
            blockers.append(f"city source artifact {name} lacks matching byte-size evidence")

    generated = cities.get("generated_catalog", {})
    evidence_generated = evidence.get("generated_catalog", {})
    relative_path = generated.get("path")
    if not isinstance(relative_path, str) or not relative_path:
        blockers.append("city generated catalog path is missing")
        return
    catalog = ROOT / relative_path
    if not catalog.is_file() or catalog.stat().st_size <= 0:
        blockers.append(f"physical city catalog is missing/empty: {relative_path}")
        return
    expected_sha = generated.get("sha256")
    actual_sha = file_sha256(catalog)
    if not sha_ok(expected_sha) or actual_sha != expected_sha:
        blockers.append("physical city catalog SHA-256 does not match manifest")
    if evidence_generated.get("sha256") != expected_sha or evidence_generated.get("path") != relative_path:
        blockers.append("city evidence generated-catalog identity/hash does not match manifest")
    byte_size = generated.get("byte_size")
    if not isinstance(byte_size, int) or byte_size <= 0 or catalog.stat().st_size != byte_size:
        blockers.append("physical city catalog byte size does not match manifest")
    if evidence_generated.get("byte_size") != byte_size:
        blockers.append("city evidence catalog byte size does not match manifest")
    expected_count = generated.get("record_count")
    if not isinstance(expected_count, int) or expected_count <= 0 or evidence_generated.get("record_count") != expected_count:
        blockers.append("city catalog record count evidence is missing or inconsistent")

    if generated.get("unique_stable_ids") is not True or evidence_generated.get("unique_stable_ids") is not True:
        blockers.append("city catalog unique stable-ID evidence is not asserted")
    if generated.get("valid_iana_timezone_ids") is not True or evidence_generated.get("valid_iana_timezone_ids") is not True:
        blockers.append("city catalog IANA timezone evidence is not asserted")

    attribution = cities.get("attribution_asset", {})
    evidence_attribution = evidence.get("attribution", {})
    attribution_path = attribution.get("path")
    if not isinstance(attribution_path, str) or not attribution_path:
        blockers.append("city attribution asset path is missing")
    else:
        physical_attribution = ROOT / attribution_path
        if not physical_attribution.is_file() or physical_attribution.stat().st_size <= 0:
            blockers.append("physical GeoNames attribution asset is missing")
        else:
            attribution_sha = attribution.get("sha256")
            if not sha_ok(attribution_sha) or file_sha256(physical_attribution) != attribution_sha:
                blockers.append("physical GeoNames attribution SHA-256 does not match manifest")
            if evidence_attribution.get("sha256") != attribution_sha or evidence_attribution.get("path") != attribution_path:
                blockers.append("city evidence attribution path/hash does not match manifest")
            required_text = str(cities.get("attribution_text", "")).strip()
            if not required_text or required_text not in physical_attribution.read_text(encoding="utf-8"):
                blockers.append("physical GeoNames attribution text is incomplete")
    if attribution.get("license") != cities.get("license") or evidence_attribution.get("license") != cities.get("license"):
        blockers.append("city attribution license does not match manifest license")

    if "assets/data/cities/" not in pubspec:
        blockers.append("pubspec.yaml does not bundle assets/data/cities/")

    # Validate physical gzip readability and exact record count. This deliberately
    # avoids trusting a generated metadata count by itself.
    observed_count = 0
    seen_ids: set[str] = set()
    try:
        with gzip.open(catalog, "rt", encoding="utf-8") as handle:
            for line_number, line in enumerate(handle, start=1):
                row = json.loads(line)
                stable_id = row.get("stable_id")
                timezone_id = row.get("iana_timezone_id")
                if not isinstance(stable_id, str) or not stable_id:
                    blockers.append(f"city catalog row {line_number} has no stable_id")
                    break
                if stable_id in seen_ids:
                    blockers.append(f"city catalog duplicate stable_id found: {stable_id}")
                    break
                seen_ids.add(stable_id)
                if not isinstance(timezone_id, str) or not timezone_id:
                    blockers.append(f"city catalog row {line_number} has no IANA timezone ID")
                    break
                latitude = row.get("latitude")
                longitude = row.get("longitude")
                if not isinstance(latitude, (int, float)) or not -90 <= latitude <= 90:
                    blockers.append(f"city catalog row {line_number} has invalid latitude")
                    break
                if not isinstance(longitude, (int, float)) or not -180 <= longitude <= 180:
                    blockers.append(f"city catalog row {line_number} has invalid longitude")
                    break
                observed_count += 1
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        blockers.append(f"physical city catalog cannot be parsed: {exc}")
    if isinstance(expected_count, int) and observed_count != expected_count:
        blockers.append(f"physical city catalog record count mismatch: {observed_count} != {expected_count}")

    city_specific_blockers = [
        item for item in blockers
        if item.startswith("city ")
        or item.startswith("physical city")
        or item.startswith("physical GeoNames")
        or item.startswith("pubspec.yaml does not bundle assets/data/cities/")
    ]
    if not city_specific_blockers:
        verified.append(
            f"physical offline city catalog verified: {observed_count} records, sha256={actual_sha}"
        )


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

    verify_city_bundle(cities, pubspec, blockers, verified)

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

    payload = {
        "rc": "RC-1437",
        "ready": not blockers,
        "verified": verified,
        "blockers": blockers,
        "inputs": {
            "timezone_manifest_sha256": hashlib.sha256(TIMEZONE.read_bytes()).hexdigest(),
            "cities_manifest_sha256": hashlib.sha256(CITIES.read_bytes()).hexdigest(),
            "city_evidence_sha256": hashlib.sha256(CITY_EVIDENCE.read_bytes()).hexdigest() if CITY_EVIDENCE.is_file() else None,
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
