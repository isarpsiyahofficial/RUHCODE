#!/usr/bin/env python3
"""Fail-closed source-readiness validator for RC-1442 clean-checkout releases.

This validator does not claim that a release is signed or device-tested. It verifies
that the repository contains the minimum tracked Android release host and delegates
RC-1437/RC-1439 to their strict validators. It is intended for release-tag/manual
release gates, not for ordinary development pushes while blockers are known.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def exists(path: str) -> bool:
    return (ROOT / path).is_file()


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def run_strict_validator(path: str) -> tuple[bool, str]:
    target = ROOT / path
    if not target.is_file():
        return False, f"missing validator: {path}"
    proc = subprocess.run(
        [sys.executable, str(target)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    return proc.returncode == 0, proc.stdout[-4000:]


def find_android_identity() -> tuple[str | None, str | None, str | None]:
    candidates = [
        "android/app/build.gradle.kts",
        "android/app/build.gradle",
    ]
    for path in candidates:
        if not exists(path):
            continue
        text = read(path)
        ns = re.search(r"\bnamespace\s*(?:=\s*)?[\"']([^\"']+)[\"']", text)
        app = re.search(r"\bapplicationId\s*(?:=\s*)?[\"']([^\"']+)[\"']", text)
        return path, ns.group(1) if ns else None, app.group(1) if app else None
    return None, None, None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-output")
    args = parser.parse_args()

    required_files = [
        "android/settings.gradle.kts",
        "android/gradle.properties",
        "android/app/src/main/AndroidManifest.xml",
        "android/app/src/main/kotlin",
        "pubspec.yaml",
        "pubspec.lock",
    ]

    checks: list[dict[str, object]] = []

    # Files that must be tracked in a reproducible Flutter Android host. The Kotlin
    # source path is a directory, so it is checked separately below.
    for path in required_files[:-3]:
        checks.append({"id": f"tracked:{path}", "ok": exists(path)})
    checks.append({"id": "tracked:android/app/src/main/AndroidManifest.xml", "ok": exists("android/app/src/main/AndroidManifest.xml")})
    checks.append({"id": "tracked:pubspec.yaml", "ok": exists("pubspec.yaml")})
    checks.append({"id": "tracked:pubspec.lock", "ok": exists("pubspec.lock")})

    kotlin_dir = ROOT / "android/app/src/main/kotlin"
    java_dir = ROOT / "android/app/src/main/java"
    activity_files = []
    for base in (kotlin_dir, java_dir):
        if base.is_dir():
            activity_files.extend(base.rglob("MainActivity.*"))
    checks.append({"id": "tracked:MainActivity", "ok": bool(activity_files), "files": [str(p.relative_to(ROOT)) for p in activity_files]})

    gradle_path, namespace, application_id = find_android_identity()
    identity_ok = bool(
        gradle_path
        and namespace
        and application_id
        and namespace == application_id
        and not application_id.startswith("com.example")
    )
    checks.append(
        {
            "id": "android:canonical-identity",
            "ok": identity_ok,
            "gradle": gradle_path,
            "namespace": namespace,
            "applicationId": application_id,
        }
    )

    # Wrapper evidence is required so clean checkout does not depend on a developer
    # workstation's Gradle installation.
    wrapper_files = [
        "android/gradlew",
        "android/gradlew.bat",
        "android/gradle/wrapper/gradle-wrapper.properties",
        "android/gradle/wrapper/gradle-wrapper.jar",
    ]
    for path in wrapper_files:
        checks.append({"id": f"tracked:{path}", "ok": exists(path)})

    pubspec = read("pubspec.yaml") if exists("pubspec.yaml") else ""
    checks.append({"id": "assets:daily-message-tr", "ok": "assets/content/daily_messages/tr/" in pubspec})
    checks.append({"id": "assets:daily-message-en", "ok": "assets/content/daily_messages/en/" in pubspec})

    rc1437_ok, rc1437_out = run_strict_validator("tools/requirements/validate_rc1437_offline_data.py")
    rc1439_ok, rc1439_out = run_strict_validator("tools/requirements/validate_rc1439_reference_images.py")
    checks.append({"id": "strict:RC-1437", "ok": rc1437_ok, "output": rc1437_out})
    checks.append({"id": "strict:RC-1439", "ok": rc1439_ok, "output": rc1439_out})

    failed = [c for c in checks if not c["ok"]]
    result = {
        "requirement": "RC-1442",
        "status": "READY_FOR_SIGNED_BUILD" if not failed else "NOT_READY",
        "claim_scope": "source readiness only; signing, exact artifact reproducibility and real-device verification remain separate evidence",
        "checks": checks,
        "failedCheckIds": [c["id"] for c in failed],
    }

    if args.json_output:
        output = ROOT / args.json_output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
