#!/usr/bin/env python3
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "ui" / "action_registry.csv"
FEATURE_CATALOG = ROOT / "lib" / "src" / "entitlements" / "feature_catalog.dart"

EXPECTED_ACTION_ACCESS = {
    "ACTION-SETTINGS-PDF": "FREE",
    "ACTION-PDF-PREVIEW": "FREE",
    "ACTION-PDF-BUILD": "PRO",
    "ACTION-PDF-PREVIEW-CREATE": "PRO",
    "ACTION-PDF-PREVIEW-SHARE": "PRO",
    "ACTION-PDF-BUILDER-SECTIONS": "PRO",
    "ACTION-PDF-BUILDER-ORDER": "PRO",
    "ACTION-PDF-BUILDER-PREVIEW": "PRO",
}


def fail(message: str) -> None:
    raise SystemExit(f"PDF entitlement contract failed: {message}")


def main() -> None:
    with REGISTRY.open(encoding="utf-8", newline="") as handle:
        rows = {row["action_id"]: row for row in csv.DictReader(handle)}

    for action_id, expected in EXPECTED_ACTION_ACCESS.items():
        row = rows.get(action_id)
        if row is None:
            fail(f"missing action {action_id}")
        if row["status"] != "ACTIVE":
            fail(f"{action_id} must remain ACTIVE")
        if row["entitlement"] != expected:
            fail(f"{action_id} expected {expected}, got {row['entitlement']}")

    if rows["ACTION-PDF-PREVIEW"]["label_or_purpose"] != "Örnek PDF Önizle":
        fail("Free preview must be explicitly labelled as an example preview")
    if rows["ACTION-PDF-BUILD"]["label_or_purpose"] != "Profesyonel PDF Oluştur":
        fail("PRO build action must be explicitly labelled as professional PDF generation")

    source = FEATURE_CATALOG.read_text(encoding="utf-8")
    required_fragments = (
        "static const pdfSamplePreview = 'pdf.sample_preview';",
        "static const pdfProfessionalExport = 'pdf.professional_export';",
        "RuhFeatureIds.pdfSamplePreview: FeaturePolicy(",
        "id: RuhFeatureIds.pdfSamplePreview,\n      baseAccess: FeatureBaseAccess.free,",
        "RuhFeatureIds.pdfProfessionalExport: FeaturePolicy(",
        "id: RuhFeatureIds.pdfProfessionalExport,\n      baseAccess: FeatureBaseAccess.pro,",
    )
    for fragment in required_fragments:
        if fragment not in source:
            fail(f"feature catalog missing canonical fragment: {fragment!r}")

    print("PDF entitlement contract OK: sample preview FREE, professional generation/export PRO.")


if __name__ == "__main__":
    main()
