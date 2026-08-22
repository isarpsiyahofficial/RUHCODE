#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/pdf/persisted_manifest_section.dart"
TEST = ROOT / "test/pdf/persisted_manifest_section_test.dart"
EVIDENCE = ROOT / "evidence/pdf/persisted_manifest_section.json"


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"Missing {label}: {needle}")


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    require(source, "PdfSectionIds.technicalManifest", "technical manifest section id")
    require(source, "manifest.location.latitude", "persisted latitude")
    require(source, "manifest.location.longitude", "persisted longitude")
    require(source, "manifest.location.ianaTimeZoneId", "persisted timezone")
    require(source, "manifest.utcDateTime.toIso8601String()", "persisted UTC time")
    require(source, "manifest.localDateTime.toIso8601String()", "persisted local time")
    require(source, "manifest.houseSystemId", "persisted house system")
    require(source, "manifest.zodiacSystemId", "persisted zodiac system")
    for forbidden in ("calculation_core/", "timezone/", "geocod"):
        if forbidden in source:
            raise SystemExit(f"Technical manifest section must not recompute persisted data: {forbidden}")

    require(test, "projects persisted manifest without recomputation", "projection regression")
    require(test, "missing localization fails closed", "localization fail-closed regression")

    expected = {"RC-0911", "RC-0912", "RC-0913", "RC-0914", "RC-0916"}
    if set(evidence.get("requirement_ids", [])) != expected:
        raise SystemExit("Persisted manifest section RC ownership drifted.")
    if evidence.get("done") is not False:
        raise SystemExit("Persisted manifest evidence must remain done=false until render gates pass.")
    for path in evidence.get("source_files", []) + evidence.get("test_files", []):
        if not (ROOT / path).is_file():
            raise SystemExit(f"Evidence references missing file: {path}")

    print("Persisted CalculationManifest PDF section contract: OK")


if __name__ == "__main__":
    main()
