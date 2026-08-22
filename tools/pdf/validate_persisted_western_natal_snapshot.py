#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SNAPSHOT = ROOT / "lib/src/pdf/persisted_western_natal_snapshot.dart"
READER = ROOT / "lib/src/pdf/persisted_western_natal_pdf.dart"
SOURCE = ROOT / "lib/src/pdf/persisted_calculation_pdf_source.dart"
PERSISTENCE = ROOT / "lib/src/pdf/western_natal_persistence_service.dart"
SECTIONS = ROOT / "lib/src/pdf/persisted_western_natal_sections.dart"
GEOMETRY = ROOT / "lib/src/pdf/pdf_western_chart_geometry.dart"
TEST_SNAPSHOT = ROOT / "test/pdf/persisted_western_natal_snapshot_test.dart"
TEST_READER = ROOT / "test/pdf/persisted_western_natal_pdf_test.dart"
TEST_PERSISTENCE = ROOT / "test/pdf/western_natal_persistence_service_test.dart"
TEST_SECTIONS = ROOT / "test/pdf/persisted_western_natal_sections_test.dart"
EVIDENCE = ROOT / "evidence/pdf/persisted_western_natal_snapshot.json"


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise SystemExit(f"Missing {label}: {needle}")


def main() -> None:
    snapshot = SNAPSHOT.read_text(encoding="utf-8")
    reader = READER.read_text(encoding="utf-8")
    source = SOURCE.read_text(encoding="utf-8")
    persistence = PERSISTENCE.read_text(encoding="utf-8")
    sections = SECTIONS.read_text(encoding="utf-8")
    test_snapshot = TEST_SNAPSHOT.read_text(encoding="utf-8")
    test_reader = TEST_READER.read_text(encoding="utf-8")
    test_persistence = TEST_PERSISTENCE.read_text(encoding="utf-8")
    test_sections = TEST_SECTIONS.read_text(encoding="utf-8")
    geometry = GEOMETRY.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    require(snapshot, "persistedWesternNatalSnapshotSchemaVersion = 1", "versioned schema")
    require(snapshot, "persistedWesternNatalCalculationType = 'western.natal'", "exact calculation type")
    require(snapshot, "snapshotSha256", "persisted SHA-256 field")
    require(snapshot, "sha256.convert(utf8.encode(canonicalJson))", "canonical digest")
    require(snapshot, "houseCuspsDeg.length != 12", "twelve-cusp validation")
    require(snapshot, "close one exact 360° cycle", "closed house cycle validation")
    require(snapshot, "placement house mismatch", "placement/cusp integrity")
    require(snapshot, "aspect exact angle does not match its aspect type", "aspect type/angle integrity")
    require(snapshot, "aspect separation disagrees with placement geometry", "aspect geometry integrity")
    require(snapshot, "requestedHouseSystem", "requested house system")
    require(snapshot, "effectiveHouseSystem", "effective house system")
    require(snapshot, "Persisted aspect references a body absent from placements", "aspect/body integrity")

    require(reader, "manifest.engineVersion != snapshot.engineVersion", "engine manifest parity")
    require(reader, "manifest.algorithmVersion != snapshot.algorithmVersion", "algorithm manifest parity")
    require(reader, "manifest.dataVersion != snapshot.dataVersion", "data manifest parity")
    require(reader, "PdfWesternChartGeometryAdapter.fromPersistedSnapshot(snapshot)", "persisted geometry projection")
    require(source, "database.transaction<PersistedCalculationPdfSnapshot?>", "transactional persisted read")

    require(persistence, "database.transaction<void>", "atomic manifest/calculation write")
    require(persistence, "table: 'calculation_manifests'", "manifest write")
    require(persistence, "table: 'calculations'", "calculation write")
    require(persistence, "PersistedWesternNatalEnvelope.seal(snapshot)", "snapshot sealing before persistence")
    require(persistence, "Manifest/snapshot engineVersion mismatch", "save-time engine parity")
    require(persistence, "Manifest/snapshot algorithmVersion mismatch", "save-time algorithm parity")
    require(persistence, "Manifest/snapshot dataVersion mismatch", "save-time data parity")
    require(persistence, "Manifest/snapshot requested house-system mismatch", "save-time house-system parity")

    forbidden_section_imports = (
        "calculation_core/ephemeris",
        "calculation_core/western/natal_chart",
        "calculation_core/western/house",
    )
    for forbidden in forbidden_section_imports:
        if forbidden in sections:
            raise SystemExit(f"Persisted Western PDF sections must not recalculate: forbidden import {forbidden}")
    require(sections, "PdfSectionIds.placements", "placements PDF section")
    require(sections, "PdfSectionIds.houses", "houses PDF section")
    require(sections, "PdfSectionIds.aspects", "aspects PDF section")
    require(sections, "envelope.snapshotSha256", "section snapshot digest")

    require(geometry, "fromPersistedSnapshot(PersistedWesternNatalSnapshot snapshot)", "persisted geometry API")
    require(geometry, "_astroBodyByName", "strict persisted body decoder")
    require(geometry, "_majorAspectByName", "strict persisted aspect decoder")

    require(test_snapshot, "tampered persisted Western snapshot is rejected before rendering", "tamper regression")
    require(test_snapshot, "persisted PDF geometry is produced without recalculating chart values", "no-recalculation regression")
    require(test_snapshot, "stored house number must agree with persisted cusp geometry", "house consistency regression")
    require(test_snapshot, "aspect type and geometry must agree with persisted placements", "aspect consistency regression")
    require(test_reader, "manifest engine version drift fails closed", "engine drift regression")
    require(test_reader, "manifest algorithm version drift fails closed", "algorithm drift regression")
    require(test_reader, "manifest data version drift fails closed", "data drift regression")
    require(test_persistence, "persist atomically and round-trip", "atomic persistence regression")
    require(test_persistence, "rolls manifest back in same transaction", "rollback regression")
    require(test_persistence, "provenance mismatch is rejected before transaction", "pre-write parity regression")
    require(test_sections, "projects placements houses and aspects from sealed snapshot only", "persisted table projection regression")
    require(test_sections, "missing localized label fails closed", "localized label regression")

    if evidence.get("done") is not False:
        raise SystemExit("Persisted Western evidence must stay done=false until external accuracy/render gates pass.")
    if evidence.get("status") != "SOURCE_LEVEL_IMPLEMENTED":
        raise SystemExit("Unexpected persisted Western evidence status.")
    required_rcs = {
        "RC-0724", "RC-0725", "RC-0726", "RC-0727", "RC-0729", "RC-0730",
        "RC-0737", "RC-0738", "RC-0763", "RC-0765", "RC-0870",
        "RC-0920", "RC-0921", "RC-0922", "RC-0923",
    }
    if set(evidence.get("requirement_ids", [])) != required_rcs:
        raise SystemExit("Persisted Western evidence RC ownership drifted.")
    contracts = evidence.get("contracts", {})
    for key in (
        "historical_recalculation_forbidden",
        "canonical_snapshot_sha256_required",
        "manifest_engine_version_must_match",
        "manifest_algorithm_version_must_match",
        "manifest_data_version_must_match",
        "manifest_house_system_must_match_snapshot",
        "manifest_and_calculation_written_in_one_transaction",
        "second_write_failure_rolls_back_manifest",
        "existing_calculation_or_manifest_id_fails_closed",
        "resolved_house_system_and_12_cusps_persisted",
        "house_cusps_must_form_closed_forward_cycle",
        "placement_house_number_must_match_persisted_cusps",
        "placements_and_major_aspects_persisted",
        "aspect_type_angle_and_placement_geometry_must_match",
        "pdf_geometry_reads_persisted_snapshot",
        "pdf_placements_houses_aspects_sections_read_persisted_snapshot",
        "localized_section_labels_required",
        "unknown_or_tampered_payload_fails_closed",
    ):
        if contracts.get(key) is not True:
            raise SystemExit(f"Evidence contract must require {key}=true")

    for path in evidence.get("source_files", []) + evidence.get("test_files", []):
        if not (ROOT / path).is_file():
            raise SystemExit(f"Evidence references missing file: {path}")

    print("Persisted Western natal snapshot/PDF/persistence contract: OK")


if __name__ == "__main__":
    main()
