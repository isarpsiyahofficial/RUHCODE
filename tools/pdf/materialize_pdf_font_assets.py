#!/usr/bin/env python3
"""Materialize the pinned Noto Sans PDF font release assets.

The download source is an immutable upstream commit. Every payload is verified
against its canonical Git blob SHA-1 before it can enter the application asset
bundle. Exact SHA-256 values are then written into PdfFontReleaseManifest.
The offline --check mode never trusts the network and re-verifies packaged bytes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import tempfile
import time
import urllib.error
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


def fetch(url: str, *, attempts: int = 4) -> bytes:
    """Fetch immutable upstream bytes with bounded transient-network retries.

    Retry handling never weakens integrity: callers still verify every successful
    payload against the pinned Git blob SHA-1 before writing anything to assets.
    HTTP 4xx errors are treated as non-transient and fail immediately.
    """
    last_error: Exception | None = None
    for attempt in range(1, attempts + 1):
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "ruh-code-pdf-font-materializer/1"},
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except urllib.error.HTTPError as exc:
            if 400 <= exc.code < 500:
                raise
            last_error = exc
        except (urllib.error.URLError, ConnectionError, TimeoutError) as exc:
            last_error = exc

        if attempt < attempts:
            time.sleep(min(2 ** (attempt - 1), 4))

    assert last_error is not None
    raise RuntimeError(
        f"failed to fetch immutable PDF font source after {attempts} attempts: {url}"
    ) from last_error


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
            rf"static const String {name}\s*=\s*'([a-f0-9]*)';", text
        )
        if not match:
            raise RuntimeError(f"manifest field not found: {name}")
        return match.group(1)

    packaged_match = re.search(
        r"static const bool binariesPackaged\s*=\s*(true|false);", text
    )
