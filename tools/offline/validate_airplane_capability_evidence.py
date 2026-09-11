#!/usr/bin/env python3
"""Validate partial Android airplane-mode capability evidence fail-closed.

This evidence is intentionally weaker than the exact release APK proof required
by RC-1362..RC-1374. It records production calculation code exercised on an
Android emulator/device while radios are disabled, but it MUST NOT be promoted
to VERIFIED/DONE because flutter integration_test builds a test artifact rather
than exercising the exact release APK and because five non-calculation flows are
still absent.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
TEST_TARGET = "integration_test/offline_calculation_capabilities_test.dart"
EXERCISED = [
    "westernChart",
    "vedic",
    "numerology",
    "bazi",
    "planetaryHours",
]
REMAINING = [
    "records",
    "pdfExport",
    "csvExport",
    "csvRestore",
    "professionalClientManagement",
]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"RC1363_RC1372_CAPABILITY_EVIDENCE_FAIL: {message}")


def validate(payload: dict, expected_commit: str | None) -> None:
    require(payload.get("schemaVersion") == 1, "schemaVersion must be 1")
    require(
        payload.get("evidenceScope") == "device-calculation-smoke",
        "scope must be device-calculation-smoke",
    )

    commit = payload.get("commitSha", "")
    require(
        isinstance(commit, str) and COMMIT_RE.fullmatch(commit) is not None,
        "invalid commitSha",
    )
    if expected_commit is not None:
        require(commit == expected_commit, "manifest commitSha does not match checkout")

    require(payload.get("releaseArtifact") is False, "partial harness is not release APK evidence")
    require(payload.get("testTarget") == TEST_TARGET, "unexpected integration test target")

    device = payload.get("device")
    require(isinstance(device, dict), "device metadata is required")
    require(device.get("kind") in {"emulator", "physical"}, "invalid device.kind")
    require(bool(str(device.get("serial", "")).strip()), "device serial is required")
    require(bool(str(device.get("model", "")).strip()), "device model is required")
    require(bool(str(device.get("apiLevel", "")).strip()), "device API level is required")

    network = payload.get("networkState")
    require(isinstance(network, dict), "networkState is required")
    require(network.get("airplaneModeEnabled") is True, "airplane mode was not proven enabled")
    require(network.get("wifiDisabled") is True, "Wi-Fi disabled state was not proven")
    require(network.get("mobileDataDisabled") is True, "mobile-data disabled state was not proven")

    require(payload.get("testCommandSucceeded") is True, "integration test command did not succeed")
    require(payload.get("exercisedCapabilities") == EXERCISED, "unexpected exercised capability set")
    require(payload.get("remainingCapabilities") == REMAINING, "remaining capability set drifted")
    require(
        payload.get("endToEndCapabilitiesComplete") is False,
        "partial calculation evidence must remain incomplete",
    )
    require(payload.get("verifiableAsDone") is False, "partial evidence must not claim DONE")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--expected-commit")
    args = parser.parse_args()

    require(args.manifest.is_file(), f"missing manifest: {args.manifest}")
    payload = json.loads(args.manifest.read_text(encoding="utf-8"))
    require(isinstance(payload, dict), "manifest root must be an object")
    validate(payload, args.expected_commit)
    print("RC1363_RC1367_DEVICE_CALCULATION_EVIDENCE_OK")


if __name__ == "__main__":
    main()
