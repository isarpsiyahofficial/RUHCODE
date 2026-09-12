#!/usr/bin/env python3
"""Materialize the pinned Noto Sans PDF font release assets.

The download source is an immutable upstream commit. Every payload is verified
against its canonical Git blob SHA-1 before it can enter the application asset
bundle. Exact SHA-256 values are then written into PdfFontReleaseManifest.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ASSET_DIR = ROOT / "assets/fonts/pdf"
MANIFEST = ROOT / "lib/src/pdf/pdf_font_release_manifest.dart"
PROVENANCE_JSON = ASSET_DIR / "font_release_provenance.json"

UPSTREAM_REPOSITORY = "notofonts/notofonts.github.io"
UPSTREAM_REVISION = "66c4b351c58f99ace5a6265d329080d74b057909"
RAW_BASE = (
    "https://raw.githubusercontent.com/"
    f"{UPSTREAM_REPOSITORY}/{UPSTREAM_REVISION}/fonts"
)

SOURCES = {
    "NotoSans-Regular.ttf": {
        "url": f"{RAW_BASE}/NotoSans/hinted/ttf/NotoSans-Regular.ttf",
        "blob_sha1": "f27f4ff59562d58480f1cb94194393484b8da9e9",
    },
    "NotoSans-Bold.ttf": {
        "url": f"{RAW_BASE}/NotoSans/hinted/ttf/NotoSans-Bold.ttf",
        "blob_sha1": "aae7546dc1905b228aff70cde8c818b82f3a2bc4",
    },
    "OFL.txt": {
        "url": f"{RAW_BASE}/LICENSE",
        "blob_sha1": "9651ea7d51c39a7778cc327a423fb200350aa948",
    },
}


def git_blob_sha1(payload: bytes) -> str:
    header = f"blob {len(payload)}\0".encode("ascii")
    return hashlib.sha1(header + payload).hexdigest()


def sha256(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def fetch(url: str) -> bytes:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "ruh-code-pdf-font-materializer/1"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def verify_payload(name: str, payload: bytes) -> dict[str, object]:
    source = SOURCES[name]
    actual_blob = git_blob_sha1(payload)
    expected_blob = source["blob_sha1"]
    if actual_blob != expected_blob:
        raise RuntimeError(
            f"{name}: upstream Git blob mismatch: expected {expected_blob}, "
            f"got {actual_blob}"
        )
    return {
        "path": f"assets/fonts/pdf/{name}",
        "bytes": len(payload),
        "gitBlobSha1": actual_blob,
        "sha256": sha256(payload),
        "sourceUrl": source["url"],
    }


def parse_manifest_hashes(text: str) -> tuple[str, str, bool]:
    def value(name: str) -> str:
        match = re.search(
            rf"static const String {name} =\s*'([a-f0-9]*)';", text
        )
        if not match:
            raise RuntimeError(f"manifest field not found: {name}")
        return match.group(1)

    packaged_match = re.search(
        r"static const bool binariesPackaged = (true|false);", text
    )
    if not packaged_match:
        raise RuntimeError("manifest field not found: binariesPackaged")
    return value("regularSha256"), value("boldSha256"), packaged_match.group(1) == "true"


def update_manifest(regular_hash: str, bold_hash: str) -> None:
    if regular_hash == bold_hash:
        raise RuntimeError("Regular and Bold assets unexpectedly have identical SHA-256")
    text = MANIFEST.read_text(encoding="utf-8")
    text, regular_count = re.subn(
        r"static const String regularSha256 = '[a-f0-9]*';",
        f"static const String regularSha256 = '{regular_hash}';",
        text,
    )
    text, bold_count = re.subn(
        r"static const String boldSha256 = '[a-f0-9]*';",
        f"static const String boldSha256 = '{bold_hash}';",
        text,
    )
    text, packaged_count = re.subn(
        r"static const bool binariesPackaged = (?:true|false);",
        "static const bool binariesPackaged = true;",
        text,
    )
    if (regular_count, bold_count, packaged_count) != (1, 1, 1):
        raise RuntimeError("manifest update was not exact; refusing to continue")
    MANIFEST.write_text(text, encoding="utf-8")


def materialize() -> None:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    verified: dict[str, dict[str, object]] = {}
    with tempfile.TemporaryDirectory(prefix="ruh-code-fonts-") as tmp:
        temp_dir = Path(tmp)
        for name, source in SOURCES.items():
            payload = fetch(str(source["url"]))
            evidence = verify_payload(name, payload)
            (temp_dir / name).write_bytes(payload)
            verified[name] = evidence
        for name in SOURCES:
            (ASSET_DIR / name).write_bytes((temp_dir / name).read_bytes())

    regular_hash = str(verified["NotoSans-Regular.ttf"]["sha256"])
    bold_hash = str(verified["NotoSans-Bold.ttf"]["sha256"])
    update_manifest(regular_hash, bold_hash)

    provenance = {
        "schemaVersion": 1,
        "family": "Noto Sans",
        "license": "OFL-1.1",
        "upstreamRepository": f"https://github.com/{UPSTREAM_REPOSITORY}",
        "upstreamRevision": UPSTREAM_REVISION,
        "files": verified,
        "releaseReady": True,
    }
    PROVENANCE_JSON.write_text(
        json.dumps(provenance, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    check()


def check() -> None:
    text = MANIFEST.read_text(encoding="utf-8")
    regular_hash, bold_hash, packaged = parse_manifest_hashes(text)
    if not packaged:
        raise RuntimeError("PdfFontReleaseManifest.binariesPackaged is false")
    if not re.fullmatch(r"[a-f0-9]{64}", regular_hash):
        raise RuntimeError("regularSha256 is not pinned")
    if not re.fullmatch(r"[a-f0-9]{64}", bold_hash):
        raise RuntimeError("boldSha256 is not pinned")
    if regular_hash == bold_hash:
        raise RuntimeError("Regular and Bold SHA-256 values must differ")

    evidence: dict[str, dict[str, object]] = {}
    for name in SOURCES:
        path = ASSET_DIR / name
        if not path.is_file():
            raise RuntimeError(f"missing release asset: {path.relative_to(ROOT)}")
        payload = path.read_bytes()
        evidence[name] = verify_payload(name, payload)

    if evidence["NotoSans-Regular.ttf"]["sha256"] != regular_hash:
        raise RuntimeError("Regular asset SHA-256 does not match release manifest")
    if evidence["NotoSans-Bold.ttf"]["sha256"] != bold_hash:
        raise RuntimeError("Bold asset SHA-256 does not match release manifest")

    if not PROVENANCE_JSON.is_file():
        raise RuntimeError("missing font_release_provenance.json")
    provenance = json.loads(PROVENANCE_JSON.read_text(encoding="utf-8"))
    if provenance.get("upstreamRevision") != UPSTREAM_REVISION:
        raise RuntimeError("provenance upstream revision mismatch")
    if provenance.get("files") != evidence:
        raise RuntimeError("provenance evidence does not match packaged assets")
    if provenance.get("releaseReady") is not True:
        raise RuntimeError("provenance is not releaseReady=true")

    print(
        "Verified PDF fonts: "
        f"regular={regular_hash} bold={bold_hash} revision={UPSTREAM_REVISION}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify already-materialized assets without network access",
    )
    args = parser.parse_args()
    if args.check:
        check()
    else:
        materialize()


if __name__ == "__main__":
    main()
