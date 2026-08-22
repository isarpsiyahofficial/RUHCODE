#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/pdf/persisted_pythagorean_numerology_pdf.dart"
TEST = ROOT / "test/pdf/persisted_pythagorean_numerology_pdf_test.dart"
EVIDENCE = ROOT / "evidence/pdf/persisted_pythagorean_pdf.json"


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"Missing {label}: {needle}")


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    require(source, "numerology.pythagorean", "exact calculation type")
    require(source, "snapshotCanonicalJson", "canonical snapshot payload")
    require(source, "snapshotSha256", "persisted SHA-256")
    require(source, "sha256.convert(utf8.encode(canonicalJson))", "digest verification")
    require(source, "snapshot.manifest.engineVersion", "manifest version verification")
    require(source, "PdfLocalReportService<PersistedCalculationPdfSnapshot>", "local renderer chain")
    require(source, "'tr'", "Turkish locale")
    require(source, "'en'", "English locale")

    require(test, "tampered canonical snapshot digest fails before font loading", "tamper regression")
    require(test, "manifest engine-version drift fails closed before rendering", "manifest drift regression")
    require(test, "wrong calculation type is rejected instead of reinterpretation", "type isolation regression")
    require(test, "expect(fontProvider.calls, 0)", "pre-render fail-closed assertion")

    if evidence.get("done") is not False:
        raise SystemExit("Persisted numerology PDF evidence must remain done=false until runtime/font/render gates pass.")
    if evidence.get("status") != "SOURCE_LEVEL_IMPLEMENTED":
        raise SystemExit("Unexpected persisted numerology PDF evidence status.")
    contracts = evidence.get("contracts", {})
    for key in (
        "recalculation_forbidden",
        "canonical_snapshot_sha256_required",
        "manifest_engine_version_must_match",
        "unknown_or_tampered_payload_fails_closed",
        "local_renderer_only",
    ):
        if contracts.get(key) is not True:
            raise SystemExit(f"Evidence contract must require {key}=true")

    print("Persisted Pythagorean professional PDF contract: OK")


if __name__ == "__main__":
    main()
