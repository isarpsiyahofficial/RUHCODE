#!/usr/bin/env python3
"""Fail-closed validator for RC-1362..RC-1374 airplane-mode runtime evidence.

This validator deliberately distinguishes release APK startup evidence from the
full end-to-end capability proof required before RC-1362..RC-1374 may be
VERIFIED/DONE. A startup smoke manifest must never claim that the ten offline
core capabilities were exercised end to end.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
PACKAGE_NAME = "com.ruhcode.ruh_code"
ARTIFACT_PATH = "build/app/outputs/flutter-apk/app-release.apk"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC1362_RC1374_EVIDENCE_FAIL: {message}")


def validate(payload: dict, expected_commit: str | None) -> None:
    require(payload.get("schemaVersion") == 1, "schemaVersion must be 1")
    require(payload.get("evidenceScope") == "startup-smoke", "scope must be startup-smoke")

    commit = payload.get("commitSha", "")
    require(isinstance(commit, str) and COMMIT_RE.fullmatch(commit) is not None, "invalid commitSha")
    if expected_commit is not None:
        require(commit == expected_commit, "manifest commitSha does not match checked-out commit")

    require(payload.get("releaseArtifact") is True, "releaseArtifact must be true")
    require(payload.get("artifactPath") == ARTIFACT_PATH, "unexpected release artifact path")
    apk_sha = payload.get("apkSha256", "")
    require(isinstance(apk_sha, str) and SHA256_RE.fullmatch(apk_sha) is not None, "invalid APK SHA-256")

    device = payload.get("device")
    require(isinstance(device, dict), "device metadata is required")
    require(device.get("kind") in {"emulator", "physical"}, "device.kind must be emulator or physical")
    require(bool(str(device.get("serial", "")).strip()), "device serial is required")
    require(bool(str(device.get("model", "")).strip()), "device model is required")
    require(bool(str(device.get("apiLevel", "")).strip()), "device API level is required")

    network = payload.get("networkState")
    require(isinstance(network, dict), "networkState is required")
    require(network.get("airplaneModeEnabled") is True, "airplane mode was not proven enabled")
    require(network.get("wifiDisabled") is True, "Wi-Fi disabled state was not proven")
    require(network.get("mobileDataDisabled") is True, "mobile-data disabled state was not proven")

    app = payload.get("app")
    require(isinstance(app, dict), "app metadata is required")
    require(app.get("package") == PACKAGE_NAME, "unexpected Android package")
    pid = app.get("pid")
    require(isinstance(pid, int) and pid > 0, "positive running PID is required")
    require(app.get("crashDetected") is False, "release process crashed during airplane-mode smoke")

    exercised = payload.get("exercisedCapabilities")
    require(exercised == [], "startup smoke must not claim unexercised end-to-end capabilities")
    require(
        payload.get("endToEndCapabilitiesComplete") is False,
        "startup smoke must remain incomplete until production capability instrumentation exists",
    )
    require(payload.get("verifiableAsDone") is False, "startup smoke must not claim DONE eligibility")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--expected-commit")
    args = parser.parse_args()

    require(args.manifest.is_file(), f"missing manifest: {args.manifest}")
    payload = json.loads(args.manifest.read_text(encoding="utf-8"))
    require(isinstance(payload, dict), "manifest root must be an object")
    validate(payload, args.expected_commit)
    print("RC1362_RC1374_STARTUP_EVIDENCE_OK")


if __name__ == "__main__":
    main()
