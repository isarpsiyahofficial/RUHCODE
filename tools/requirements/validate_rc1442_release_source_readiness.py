#!/usr/bin/env python3
"""Fail-closed source-readiness validator for RC-1442 clean-checkout releases."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPECTED_GRADLE_VERSION = "9.1.0"
EXPECTED_GRADLE_DISTRIBUTION_SHA256 = "a17ddd85a26b6a7f5ddb71ff8b05fc5104c0202c6e64782429790c933686c806"
EXPECTED_GRADLE_WRAPPER_SHA256 = "76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3"
EXPECTED_GRADLE_DISTRIBUTION_URL = "https\\://services.gradle.org/distributions/gradle-9.1.0-bin.zip"


def exists(path: str) -> bool:
    return (ROOT / path).is_file()


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def sha256(path: str) -> str | None:
    target = ROOT / path
    if not target.is_file():
        return None
    digest = hashlib.sha256()
    with target.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def any_file(paths: list[str]) -> tuple[bool, str | None]:
    for path in paths:
        if exists(path):
            return True, path
    return False, None


def run_strict_validator(path: str) -> tuple[bool, str]:
    target = ROOT / path
    if not target.is_file():
        return False, f"missing validator: {path}"
    proc = subprocess.run([sys.executable, str(target)], cwd=ROOT, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    return proc.returncode == 0, proc.stdout[-4000:]


def find_android_identity() -> tuple[str | None, str | None, str | None]:
    for path in ["android/app/build.gradle.kts", "android/app/build.gradle"]:
        if not exists(path):
            continue
        text = read(path)
        ns = re.search(r"\bnamespace\s*(?:=\s*)?[\"']([^\"']+)[\"']", text)
        app = re.search(r"\bapplicationId\s*(?:=\s*)?[\"']([^\"']+)[\"']", text)
        return path, ns.group(1) if ns else None, app.group(1) if app else None
    return None, None, None


def validate_gradle_wrapper() -> list[dict[str, object]]:
    wrapper_path = "android/gradle/wrapper/gradle-wrapper.jar"
    properties_path = "android/gradle/wrapper/gradle-wrapper.properties"
    checksum_path = "android/gradle/wrapper/gradle-wrapper.jar.sha256"
    provenance_path = "android/gradle/wrapper/gradle-wrapper.provenance.json"
    actual_wrapper_sha = sha256(wrapper_path)
    properties = read(properties_path) if exists(properties_path) else ""
    checksum_text = read(checksum_path).strip() if exists(checksum_path) else ""
    provenance: dict[str, object] = {}
    provenance_parse_ok = False
    if exists(provenance_path):
        try:
            parsed = json.loads(read(provenance_path))
            if isinstance(parsed, dict):
                provenance = parsed
                provenance_parse_ok = True
        except (json.JSONDecodeError, OSError):
            pass

    expected_checksum_line = f"{EXPECTED_GRADLE_WRAPPER_SHA256}  gradle-wrapper.jar"
    properties_ok = (
        f"distributionUrl={EXPECTED_GRADLE_DISTRIBUTION_URL}" in properties
        and f"distributionSha256Sum={EXPECTED_GRADLE_DISTRIBUTION_SHA256}" in properties
        and "validateDistributionUrl=true" in properties
    )
    provenance_ok = provenance_parse_ok and (
        provenance.get("gradleVersion") == EXPECTED_GRADLE_VERSION
        and provenance.get("distributionUrl") == "https://services.gradle.org/distributions/gradle-9.1.0-bin.zip"
        and provenance.get("distributionSha256") == EXPECTED_GRADLE_DISTRIBUTION_SHA256
        and provenance.get("wrapperJarSha256") == EXPECTED_GRADLE_WRAPPER_SHA256
    )
    return [
        {"id":"gradle:wrapper-jar-official-sha256","ok":actual_wrapper_sha == EXPECTED_GRADLE_WRAPPER_SHA256,
         "expected":EXPECTED_GRADLE_WRAPPER_SHA256,"actual":actual_wrapper_sha},
        {"id":"gradle:wrapper-properties-locked","ok":properties_ok,
         "expectedVersion":EXPECTED_GRADLE_VERSION,"distributionSha256":EXPECTED_GRADLE_DISTRIBUTION_SHA256},
        {"id":"gradle:wrapper-sha256-provenance","ok":checksum_text == expected_checksum_line,
         "expected":expected_checksum_line,"actual":checksum_text or None},
        {"id":"gradle:wrapper-json-provenance","ok":provenance_ok,"provenance":provenance if provenance_parse_ok else None},
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-output")
    args = parser.parse_args()
    checks: list[dict[str, object]] = []

    settings_ok, settings_path = any_file(["android/settings.gradle.kts", "android/settings.gradle"])
    root_gradle_ok, root_gradle_path = any_file(["android/build.gradle.kts", "android/build.gradle"])
    app_gradle_ok, app_gradle_path = any_file(["android/app/build.gradle.kts", "android/app/build.gradle"])
    checks.extend([
        {"id":"tracked:android/settings.gradle","ok":settings_ok,"path":settings_path},
        {"id":"tracked:android/build.gradle","ok":root_gradle_ok,"path":root_gradle_path},
        {"id":"tracked:android/app/build.gradle","ok":app_gradle_ok,"path":app_gradle_path},
        {"id":"tracked:android/gradle.properties","ok":exists("android/gradle.properties")},
        {"id":"tracked:AndroidManifest","ok":exists("android/app/src/main/AndroidManifest.xml")},
        {"id":"tracked:pubspec.yaml","ok":exists("pubspec.yaml")},
        {"id":"tracked:pubspec.lock","ok":exists("pubspec.lock")},
    ])

    activity_files=[]
    for base in (ROOT/"android/app/src/main/kotlin", ROOT/"android/app/src/main/java"):
        if base.is_dir(): activity_files.extend(base.rglob("MainActivity.*"))
    checks.append({"id":"tracked:MainActivity","ok":bool(activity_files),"files":[str(p.relative_to(ROOT)) for p in activity_files]})

    gradle_path, namespace, application_id = find_android_identity()
    identity_ok = bool(gradle_path and namespace and application_id and namespace == application_id and not application_id.startswith("com.example"))
    checks.append({"id":"android:canonical-identity","ok":identity_ok,"gradle":gradle_path,"namespace":namespace,"applicationId":application_id})

    app_gradle_text = read(gradle_path) if gradle_path else ""
    signing_tokens = ["RUH_RELEASE_STORE_FILE","RUH_RELEASE_STORE_PASSWORD","RUH_RELEASE_KEY_ALIAS","RUH_RELEASE_KEY_PASSWORD"]
    signing_source_ok = all(token in app_gradle_text for token in signing_tokens) and 'signingConfigs.getByName("debug")' not in app_gradle_text
    checks.append({"id":"android:production-signing-source","ok":signing_source_ok,
                   "requiredTokens":signing_tokens,
                   "debugSigningForbidden":True})

    for path in ["android/gradlew","android/gradlew.bat","android/gradle/wrapper/gradle-wrapper.properties","android/gradle/wrapper/gradle-wrapper.jar"]:
        checks.append({"id":f"tracked:{path}","ok":exists(path)})
    checks.extend(validate_gradle_wrapper())

    pubspec=read("pubspec.yaml") if exists("pubspec.yaml") else ""
    checks.append({"id":"assets:daily-message-tr","ok":"assets/content/daily_messages/tr/" in pubspec})
    checks.append({"id":"assets:daily-message-en","ok":"assets/content/daily_messages/en/" in pubspec})

    rc1437_ok, rc1437_out = run_strict_validator("tools/requirements/validate_rc1437_offline_data.py")
    rc1439_ok, rc1439_out = run_strict_validator("tools/requirements/validate_rc1439_reference_images.py")
    checks.append({"id":"strict:RC-1437","ok":rc1437_ok,"output":rc1437_out})
    checks.append({"id":"strict:RC-1439","ok":rc1439_ok,"output":rc1439_out})

    failed=[c for c in checks if not c["ok"]]
    result={"requirement":"RC-1442","status":"READY_FOR_SIGNED_BUILD" if not failed else "NOT_READY",
            "claim_scope":"source readiness only; signing credentials, exact artifact reproducibility and real-device verification remain separate evidence",
            "checks":checks,"failedCheckIds":[c["id"] for c in failed]}
    if args.json_output:
        output=ROOT/args.json_output; output.parent.mkdir(parents=True,exist_ok=True)
        output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(result,ensure_ascii=False,indent=2))
    return 0 if not failed else 1

if __name__ == "__main__":
    raise SystemExit(main())
