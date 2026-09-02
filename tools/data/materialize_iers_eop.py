#!/usr/bin/env python3
"""Materialize the official IERS finals2000A Earth-orientation product for RC-1437.

This is controlled release-preparation tooling. It downloads the authoritative
ASCII product, validates basic format/coverage, records SHA-256 and byte size,
and bundles the unmodified source for offline use. It never fabricates EOP
outside the source coverage and does not introduce runtime network fallback.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import shutil
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "requirements/reference_manifests/offline_ephemeris_runtime.json"
ASSET_DIR = ROOT / "assets/data/eop"
ASSET_PATH = ASSET_DIR / "finals2000A.all"
EVIDENCE_PATH = ROOT / "requirements/evidence/rc1437_iers_eop_snapshot.json"
SOURCE_URL = "https://datacenter.iers.org/products/eop/rapid/standard/finals2000A.all"
USER_AGENT = "RUHCODE-RC1437-Materializer/1.0 (+offline-release-preparation)"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download(destination: Path) -> None:
    request = urllib.request.Request(SOURCE_URL, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=120) as response, destination.open("wb") as out:
        if response.status != 200:
            raise RuntimeError(f"IERS download failed: HTTP {response.status}")
        shutil.copyfileobj(response, out)
    if destination.stat().st_size < 100_000:
        raise RuntimeError("IERS finals2000A.all is unexpectedly small")


def inspect_ascii(path: Path) -> dict:
    line_count = 0
    mjd_values: list[float] = []
    with path.open("rt", encoding="ascii", errors="strict") as handle:
        for line_number, line in enumerate(handle, start=1):
            if not line.strip():
                continue
            if len(line.rstrip("\n")) < 15:
                raise RuntimeError(f"IERS row {line_number} is unexpectedly short")
            # finals2000A fixed-width format: MJD occupies columns 8-15 (1-based).
            raw_mjd = line[7:15].strip()
            try:
                mjd = float(raw_mjd)
            except ValueError as exc:
                raise RuntimeError(f"IERS row {line_number} has invalid MJD {raw_mjd!r}") from exc
            mjd_values.append(mjd)
            line_count += 1
    if line_count < 10_000:
        raise RuntimeError(f"IERS product has too few rows: {line_count}")
    if any(b <= a for a, b in zip(mjd_values, mjd_values[1:])):
        raise RuntimeError("IERS MJD sequence is not strictly increasing")
    return {
        "line_count": line_count,
        "mjd_start": mjd_values[0],
        "mjd_end": mjd_values[-1],
        "strictly_increasing_mjd": True,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot-date", help="UTC snapshot date (YYYY-MM-DD); defaults to today")
    args = parser.parse_args()
    snapshot_date = args.snapshot_date or dt.datetime.now(dt.timezone.utc).date().isoformat()
    dt.date.fromisoformat(snapshot_date)

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    earth = manifest.get("earthOrientation")
    if not isinstance(earth, dict):
        raise RuntimeError("offline ephemeris manifest lacks earthOrientation object")
    if earth.get("primaryProduct") != "finals2000A.all":
        raise RuntimeError("earthOrientation primaryProduct changed; review source selection first")
    rules = manifest.get("runtimeRules", {})
    if rules.get("networkFallback") is not False or rules.get("nearestDateFallback") is not False:
        raise RuntimeError("RC-1437 fail-closed runtime rules were weakened")
    if earth.get("fabricatedFutureEopForbidden") is not True:
        raise RuntimeError("fabricated future EOP must remain forbidden")

    with tempfile.TemporaryDirectory(prefix="ruhcode-iers-") as tmp_name:
        downloaded = Path(tmp_name) / "finals2000A.all"
        download(downloaded)
        inspection = inspect_ascii(downloaded)
        ASSET_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(downloaded, ASSET_PATH)

    digest = sha256_file(ASSET_PATH)
    byte_size = ASSET_PATH.stat().st_size
    evidence = {
        "rc": "RC-1437",
        "dataset": "earthOrientation",
        "authority": "IERS",
        "product": "finals2000A.all",
        "source_url": SOURCE_URL,
        "snapshot_date_utc": snapshot_date,
        "path": ASSET_PATH.relative_to(ROOT).as_posix(),
        "sha256": digest,
        "byte_size": byte_size,
        **inspection,
        "runtime_network_required": False,
        "fabricated_future_eop": False,
    }
    EVIDENCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    EVIDENCE_PATH.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    earth["sourceUrl"] = SOURCE_URL
    earth["bundled"] = True
    earth["sha256"] = digest
    earth["byteSize"] = byte_size
    earth["retrievedAtUtc"] = snapshot_date + "T00:00:00Z"
    earth["proven"] = True
    earth["bundledPath"] = evidence["path"]
    earth["evidencePath"] = EVIDENCE_PATH.relative_to(ROOT).as_posix()
    earth["mjdStart"] = inspection["mjd_start"]
    earth["mjdEnd"] = inspection["mjd_end"]
    earth["lineCount"] = inspection["line_count"]
    manifest["earthOrientation"] = earth
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(evidence, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
