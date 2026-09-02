#!/usr/bin/env python3
"""Validate RC-1439 physical reference-image release evidence."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "requirements/reference_manifests/rc1439_reference_images.json"
SHA_RE = re.compile(r"^[0-9a-f]{64}$")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-incomplete", action="store_true")
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()

    blockers: list[str] = []
    verified: list[str] = []

    if not MANIFEST.is_file():
        blockers.append("RC-1439 reference-image manifest is missing")
        data: dict = {}
    else:
        data = json.loads(MANIFEST.read_text(encoding="utf-8"))

    if data.get("requirement") != "RC-1439":
        blockers.append("manifest requirement must be RC-1439")

    policy = data.get("policy") if isinstance(data.get("policy"), dict) else {}
    required_true = (
        "physicalAssetsRequired",
        "screenIdRequired",
        "sha256Required",
        "fileNameRequired",
        "missingAssetBlocksRelease",
        "checksumMismatchBlocksRelease",
    )
    for key in required_true:
        if policy.get(key) is not True:
            blockers.append(f"policy {key} must be true")
    if policy.get("generatedPlaceholderAccepted") is not False:
        blockers.append("generatedPlaceholderAccepted must be false")

    images = data.get("images")
    if not isinstance(images, list) or not images:
        blockers.append("no physical reference-image entries are registered")
        images = []

    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    for index, item in enumerate(images):
        prefix = f"images[{index}]"
        if not isinstance(item, dict):
            blockers.append(f"{prefix} must be an object")
            continue
        screen_id = item.get("screenId")
        rel = item.get("path")
        expected_sha = item.get("sha256")
        file_name = item.get("fileName")
        if not isinstance(screen_id, str) or not screen_id.strip():
            blockers.append(f"{prefix}.screenId is missing")
        elif screen_id in seen_ids:
            blockers.append(f"duplicate screenId: {screen_id}")
        else:
            seen_ids.add(screen_id)
        if not isinstance(rel, str) or not rel.strip():
            blockers.append(f"{prefix}.path is missing")
            continue
        if rel in seen_paths:
            blockers.append(f"duplicate path: {rel}")
        seen_paths.add(rel)
        path = (ROOT / rel).resolve()
        try:
            path.relative_to(ROOT.resolve())
        except ValueError:
            blockers.append(f"{prefix}.path escapes repository root: {rel}")
            continue
        if not path.is_file():
            blockers.append(f"physical reference image missing: {rel}")
            continue
        if not isinstance(file_name, str) or file_name != path.name:
            blockers.append(f"{prefix}.fileName does not match path basename")
        if not isinstance(expected_sha, str) or not SHA_RE.fullmatch(expected_sha):
            blockers.append(f"{prefix}.sha256 is invalid")
            continue
        actual_sha = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual_sha != expected_sha:
            blockers.append(f"checksum mismatch: {rel}")
        else:
            verified.append(f"{screen_id}: {rel} sha256 verified")

    if images and not blockers and data.get("status") == "BUNDLED_VERIFIED":
        verified.append("manifest status BUNDLED_VERIFIED")
    elif images and data.get("status") != "BUNDLED_VERIFIED":
        blockers.append("manifest status is not BUNDLED_VERIFIED")

    payload = {
        "rc": "RC-1439",
        "ready": not blockers,
        "registeredImageCount": len(images),
        "verified": verified,
        "blockers": blockers,
    }
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload, indent=2))
    return 0 if (not blockers or args.allow_incomplete) else 1


if __name__ == "__main__":
    sys.exit(main())
