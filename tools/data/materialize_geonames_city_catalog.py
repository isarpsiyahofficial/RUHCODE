#!/usr/bin/env python3
"""Materialize the RC-1437 offline GeoNames city catalog.

Downloads the exact source artifacts selected by requirements/data_manifests/cities.json,
records their SHA-256 digests, validates the source rows, and emits a deterministic
GZip-compressed JSONL runtime catalog plus attribution/evidence. No runtime network
fallback is introduced: this script is release-preparation tooling only.
"""
from __future__ import annotations

import argparse
import datetime as dt
import gzip
import hashlib
import io
import json
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_PATH = ROOT / "requirements/data_manifests/cities.json"
ASSET_DIR = ROOT / "assets/data/cities"
CATALOG_PATH = ASSET_DIR / "cities500.catalog.jsonl.gz"
ATTRIBUTION_PATH = ASSET_DIR / "ATTRIBUTION.txt"
EVIDENCE_PATH = ROOT / "requirements/evidence/rc1437_city_snapshot.json"
BASE_URL = "https://download.geonames.org/export/dump/"
REQUIRED = ("cities500.zip", "admin1CodesASCII.txt", "countryInfo.txt", "readme.txt")
USER_AGENT = "RUHCODE-RC1437-Materializer/1.0 (+offline-release-preparation)"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download(name: str, destination: Path) -> None:
    request = urllib.request.Request(BASE_URL + name, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=120) as response, destination.open("wb") as out:
        if response.status != 200:
            raise RuntimeError(f"GeoNames download failed for {name}: HTTP {response.status}")
        shutil.copyfileobj(response, out)
    if destination.stat().st_size == 0:
        raise RuntimeError(f"GeoNames artifact is empty: {name}")


def load_country_names(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw or raw.startswith("#"):
            continue
        columns = raw.split("\t")
        if len(columns) < 5:
            raise RuntimeError("Malformed GeoNames countryInfo.txt row")
        result[columns[0]] = columns[4]
    if not result:
        raise RuntimeError("GeoNames countryInfo.txt yielded no countries")
    return result


def load_admin1(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw:
            continue
        columns = raw.split("\t")
        if len(columns) < 2:
            raise RuntimeError("Malformed GeoNames admin1CodesASCII.txt row")
        result[columns[0]] = columns[1]
    if not result:
        raise RuntimeError("GeoNames admin1CodesASCII.txt yielded no regions")
    return result


def normalized_aliases(name: str, ascii_name: str, raw_aliases: str) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in (name, ascii_name, *raw_aliases.split(",")):
        value = value.strip()
        key = value.casefold()
        if not value or key in seen:
            continue
        seen.add(key)
        result.append(value)
    return result


def build_catalog(cities_zip: Path, countries: dict[str, str], admin1: dict[str, str]) -> tuple[int, str]:
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    seen_ids: set[str] = set()
    record_count = 0
    invalid_timezones: set[str] = set()

    buffer = io.BytesIO()
    with gzip.GzipFile(filename="", mode="wb", fileobj=buffer, compresslevel=9, mtime=0) as gz:
        with zipfile.ZipFile(cities_zip) as archive:
            members = [name for name in archive.namelist() if name.endswith("cities500.txt")]
            if len(members) != 1:
                raise RuntimeError(f"Expected one cities500.txt in archive, found {members!r}")
            with archive.open(members[0]) as source:
                for line_number, raw in enumerate(io.TextIOWrapper(source, encoding="utf-8"), start=1):
                    columns = raw.rstrip("\n").split("\t")
                    if len(columns) < 18:
                        raise RuntimeError(f"Malformed cities500 row {line_number}: {len(columns)} columns")
                    stable_id = columns[0]
                    if stable_id in seen_ids:
                        raise RuntimeError(f"Duplicate GeoNames stable_id {stable_id}")
                    seen_ids.add(stable_id)
                    country_code = columns[8]
                    if country_code not in countries:
                        raise RuntimeError(f"Unknown country code {country_code!r} at row {line_number}")
                    timezone_id = columns[17]
                    try:
                        ZoneInfo(timezone_id)
                    except ZoneInfoNotFoundError:
                        invalid_timezones.add(timezone_id)
                    latitude = float(columns[4])
                    longitude = float(columns[5])
                    if not -90.0 <= latitude <= 90.0 or not -180.0 <= longitude <= 180.0:
                        raise RuntimeError(f"Invalid coordinates at row {line_number}")
                    admin_key = f"{country_code}.{columns[10]}" if columns[10] else ""
                    record = {
                        "stable_id": stable_id,
                        "canonical_name": columns[1],
                        "country_code": country_code,
                        "country_name": countries[country_code],
                        "admin_area": admin1.get(admin_key, ""),
                        "latitude": latitude,
                        "longitude": longitude,
                        "iana_timezone_id": timezone_id,
                        "aliases": normalized_aliases(columns[1], columns[2], columns[3]),
                    }
                    payload = json.dumps(record, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n"
                    gz.write(payload.encode("utf-8"))
                    record_count += 1

    if invalid_timezones:
        sample = ", ".join(sorted(invalid_timezones)[:10])
        raise RuntimeError(f"Catalog contains invalid IANA timezone IDs: {sample}")
    if record_count == 0:
        raise RuntimeError("Generated city catalog is empty")
    CATALOG_PATH.write_bytes(buffer.getvalue())
    return record_count, hashlib.sha256(buffer.getvalue()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--snapshot-date", help="UTC snapshot date (YYYY-MM-DD); defaults to today")
    args = parser.parse_args()
    snapshot_date = args.snapshot_date or dt.datetime.now(dt.timezone.utc).date().isoformat()
    dt.date.fromisoformat(snapshot_date)

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    declared = tuple(manifest.get("required_source_artifacts", []))
    if declared != REQUIRED:
        raise RuntimeError(f"City manifest required_source_artifacts changed: {declared!r}")
    if manifest.get("runtime_network_required") is not False:
        raise RuntimeError("City manifest must forbid runtime network access")

    with tempfile.TemporaryDirectory(prefix="ruhcode-geonames-") as tmp_name:
        tmp = Path(tmp_name)
        source_hashes: dict[str, str] = {}
        source_sizes: dict[str, int] = {}
        for name in REQUIRED:
            path = tmp / name
            download(name, path)
            source_hashes[name] = sha256_file(path)
            source_sizes[name] = path.stat().st_size

        countries = load_country_names(tmp / "countryInfo.txt")
        admin1 = load_admin1(tmp / "admin1CodesASCII.txt")
        record_count, catalog_hash = build_catalog(tmp / "cities500.zip", countries, admin1)

    attribution = str(manifest.get("attribution_text", "")).strip()
    if not attribution:
        raise RuntimeError("GeoNames attribution text is missing from manifest")
    ATTRIBUTION_PATH.write_text(attribution + "\n", encoding="utf-8")
    attribution_hash = sha256_file(ATTRIBUTION_PATH)

    evidence = {
        "rc": "RC-1437",
        "dataset_id": manifest.get("dataset_id"),
        "provider": "GeoNames",
        "source_base_url": BASE_URL,
        "snapshot_date_utc": snapshot_date,
        "source_artifacts": {
            name: {"sha256": source_hashes[name], "byte_size": source_sizes[name]} for name in REQUIRED
        },
        "generated_catalog": {
            "path": CATALOG_PATH.relative_to(ROOT).as_posix(),
            "sha256": catalog_hash,
            "byte_size": CATALOG_PATH.stat().st_size,
            "record_count": record_count,
            "unique_stable_ids": True,
            "valid_iana_timezone_ids": True,
        },
        "attribution": {
            "path": ATTRIBUTION_PATH.relative_to(ROOT).as_posix(),
            "sha256": attribution_hash,
            "license": manifest.get("license"),
        },
        "runtime_network_required": False,
    }
    EVIDENCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    EVIDENCE_PATH.write_text(json.dumps(evidence, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    manifest["status"] = "BUNDLED_VERIFIED"
    manifest["source_snapshot_date"] = snapshot_date
    manifest["source_artifacts"] = evidence["source_artifacts"]
    manifest["generated_catalog"] = evidence["generated_catalog"]
    manifest["attribution_asset"] = evidence["attribution"]
    MANIFEST_PATH.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(evidence, ensure_ascii=False, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
