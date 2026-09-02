#!/usr/bin/env python3
"""Bundle the official JPL/NAIF DE440s SPK kernel for RC-1437.

This step proves physical, immutable offline availability only. It deliberately
leaves planetaryEphemeris.proven=false until the application runtime actually
loads the kernel and independent golden-vector tests pass.
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
MANIFEST = ROOT / "requirements/reference_manifests/offline_ephemeris_runtime.json"
ASSET_DIR = ROOT / "assets/data/ephemeris"
ASSET = ASSET_DIR / "de440s.bsp"
EVIDENCE = ROOT / "requirements/evidence/rc1437_de440s_snapshot.json"
SOURCE_URL = "https://naif.jpl.nasa.gov/pub/naif/pds/pds4/lucy/lucy_spice/spice_kernels/spk/de440s.bsp"
LABEL_URL = "https://naif.jpl.nasa.gov/pub/naif/pds/pds4/lucy/lucy_spice/spice_kernels/spk/de440s.xml"
USER_AGENT = "RUHCODE-RC1437-Materializer/1.0 (+offline-release-preparation)"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def download(url: str, path: Path) -> None:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=180) as r, path.open("wb") as out:
        if r.status != 200:
            raise RuntimeError(f"download failed: HTTP {r.status}: {url}")
        shutil.copyfileobj(r, out)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--snapshot-date")
    args = p.parse_args()
    snapshot = args.snapshot_date or dt.datetime.now(dt.timezone.utc).date().isoformat()
    dt.date.fromisoformat(snapshot)

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    rules = manifest.get("runtimeRules", {})
    if rules.get("networkFallback") is not False or rules.get("outOfCoverageFailsClosed") is not True:
        raise RuntimeError("RC-1437 fail-closed runtime policy was weakened")

    with tempfile.TemporaryDirectory(prefix="ruhcode-de440s-") as name:
        tmp = Path(name)
        bsp = tmp / "de440s.bsp"
        label = tmp / "de440s.xml"
        download(SOURCE_URL, bsp)
        download(LABEL_URL, label)
        if bsp.stat().st_size < 20_000_000:
            raise RuntimeError(f"DE440s is unexpectedly small: {bsp.stat().st_size}")
        magic = bsp.read_bytes()[:8]
        if magic != b"DAF/SPK ":
            raise RuntimeError(f"DE440s does not have DAF/SPK magic: {magic!r}")
        label_text = label.read_text(encoding="utf-8")
        if "de440s.bsp" not in label_text:
            raise RuntimeError("PDS label does not identify de440s.bsp")
        ASSET_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(bsp, ASSET)
        label_hash = sha256(label)
        label_size = label.stat().st_size

    digest = sha256(ASSET)
    evidence = {
        "rc": "RC-1437",
        "dataset": "planetaryEphemeris",
        "provider": "JPL/NASA NAIF SPK",
        "solution": "DE440s",
        "source_url": SOURCE_URL,
        "pds_label_url": LABEL_URL,
        "pds_label_sha256": label_hash,
        "pds_label_byte_size": label_size,
        "snapshot_date_utc": snapshot,
        "path": ASSET.relative_to(ROOT).as_posix(),
        "sha256": digest,
        "byte_size": ASSET.stat().st_size,
        "daf_spk_magic_verified": True,
        "runtime_network_required": False,
        "runtime_integration_proven": False,
        "independent_golden_vectors_proven": False,
    }
    EVIDENCE.parent.mkdir(parents=True, exist_ok=True)
    EVIDENCE.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    planet = manifest["planetaryEphemeris"]
    planet.update({
        "provider": "JPL/NASA NAIF SPK",
        "solution": "DE440s",
        "officialCoverage": "1850-2150",
        "sourceUrl": SOURCE_URL,
        "pdsLabelUrl": LABEL_URL,
        "bundled": True,
        "sha256": digest,
        "byteSize": ASSET.stat().st_size,
        "retrievedAtUtc": snapshot + "T00:00:00Z",
        "bundledPath": evidence["path"],
        "evidencePath": EVIDENCE.relative_to(ROOT).as_posix(),
        "proven": False,
        "provenBlocker": "runtime_kernel_loader_and_independent_golden_vectors_not_yet_verified",
    })
    manifest["planetaryEphemeris"] = planet
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(evidence, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
