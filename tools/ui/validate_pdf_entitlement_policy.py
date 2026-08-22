#!/usr/bin/env python3
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "ui" / "action_registry.csv"
REGISTRY_EXTENSIONS = ROOT / "ui" / "action_registry_runtime_extensions.csv"
RUNTIME_BINDINGS = ROOT / "ui" / "runtime_action_bindings.csv"
FEATURE_CATALOG = ROOT / "lib" / "src" / "entitlements" / "feature_catalog.dart"
PDF_RUNTIME_PAGE = ROOT / "lib" / "src" / "ui" / "pdf" / "pdf_reports_pages.dart"
ACTION_IDS = ROOT / "lib" / "src" / "ui" / "actions" / "ruh_action_ids.dart"

EXPECTED_ACTION_ACCESS = {
    "ACTION-SETTINGS-PDF": "FREE",
    "ACTION-PDF-PREVIEW": "FREE",
    "ACTION-PDF-BUILD": "PRO",
    "ACTION-PDF-BUILDER-CREATE": "PRO",
    "ACTION-PDF-BUILDER-SHARE": "PRO",
    "ACTION-PDF-BUILDER-SECTIONS": "PRO",
    "ACTION-PDF-BUILDER-ORDER": "PRO",
    "ACTION-PDF-BUILDER-PREVIEW": "PRO",
}

LEGACY_BUILDER_ACTIONS = {
    "ACTION-PDF-PREVIEW-CREATE",
    "ACTION-PDF-PREVIEW-SHARE",
}

EXPECTED_RUNTIME_BINDINGS = {
    "ACTION-SETTINGS-PDF": ("settingsPdf", "lib/src/ui/navigation/main_navigation_shell.dart", "NAVIGATION", ""),
    "ACTION-PDF-PREVIEW": ("pdfPreview", "lib/src/ui/pdf/pdf_reports_pages.dart", "ROUTE", "pdf.sample_preview"),
    "ACTION-PDF-BUILD": ("pdfBuild", "lib/src/ui/pdf/pdf_reports_pages.dart", "ROUTE", "pdf.professional_export"),
    "ACTION-PDF-BUILDER-CREATE": ("pdfCreate", "lib/src/ui/pdf/pdf_reports_pages.dart", "PDF", "pdf.professional_export"),
    "ACTION-PDF-BUILDER-SHARE": ("pdfShare", "lib/src/ui/pdf/pdf_reports_pages.dart", "SHARE", "pdf.professional_export"),
}


def fail(message: str) -> None:
    raise SystemExit(f"PDF entitlement contract failed: {message}")


def read_registry() -> dict[str, dict[str, str]]:
    rows: list[dict[str, str]] = []
    with REGISTRY.open(encoding="utf-8", newline="") as handle:
        rows.extend(csv.DictReader(handle))
    if REGISTRY_EXTENSIONS.is_file():
        with REGISTRY_EXTENSIONS.open(encoding="utf-8", newline="") as handle:
            rows.extend(csv.DictReader(handle))
    result: dict[str, dict[str, str]] = {}
    for row in rows:
        action_id = row["action_id"]
        if action_id in result:
            fail(f"duplicate action across base/extension registries: {action_id}")
        result[action_id] = row
    return result


def main() -> None:
    rows = read_registry()

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
    for action_id in ("ACTION-PDF-BUILDER-CREATE", "ACTION-PDF-BUILDER-SHARE"):
        if rows[action_id]["source_screen_id"] != "SCR-PDF-BUILDER-001":
            fail(f"{action_id} must be owned by SCR-PDF-BUILDER-001")

    with RUNTIME_BINDINGS.open(encoding="utf-8", newline="") as handle:
        bindings = {row["action_id"]: row for row in csv.DictReader(handle)}
    for action_id in LEGACY_BUILDER_ACTIONS:
        if action_id in bindings:
            fail(f"legacy preview action must not be bound to professional builder runtime: {action_id}")
    for action_id, expected in EXPECTED_RUNTIME_BINDINGS.items():
        row = bindings.get(action_id)
        if row is None:
            fail(f"missing runtime binding for {action_id}")
        if row["status"] != "IMPLEMENTED":
            fail(f"runtime binding for {action_id} must be IMPLEMENTED")
        actual = (
            row["constant_name"],
            row["binding_file"],
            row["binding_kind"],
            row["feature_id"],
        )
        if actual != expected:
            fail(f"runtime binding drift for {action_id}: expected {expected}, got {actual}")

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

    action_source = ACTION_IDS.read_text(encoding="utf-8")
    if "static const pdfCreate = 'ACTION-PDF-BUILDER-CREATE';" not in action_source:
        fail("runtime create constant must use canonical builder action ID")
    if "static const pdfShare = 'ACTION-PDF-BUILDER-SHARE';" not in action_source:
        fail("runtime share constant must use canonical builder action ID")

    runtime_source = PDF_RUNTIME_PAGE.read_text(encoding="utf-8")
    runtime_fragments = (
        "featureId: RuhFeatureIds.pdfSamplePreview",
        "featureId: RuhFeatureIds.pdfProfessionalExport",
        "RuhActionIds.pdfCreate",
        "RuhActionIds.pdfShare",
        "Örnek Kişi — Demo Profil",
        "kişisel veri içermez",
        "Demo içerik gerçek bir kullanıcı, danışan veya kayıtla ilişkilendirilmez.",
        "Profesyonel PDF oluşturma PRO kullanıcılar içindir.",
    )
    for fragment in runtime_fragments:
        if fragment not in runtime_source:
            fail(f"runtime PDF UI missing data-isolation/access fragment: {fragment!r}")
    for legacy_action in LEGACY_BUILDER_ACTIONS:
        if legacy_action in runtime_source:
            fail(f"runtime PDF UI contains legacy preview action ID: {legacy_action}")

    print(
        "PDF entitlement contract OK: sample preview FREE, professional generation/export PRO, "
        "builder create/share actions are canonical, and demo preview is isolated from real user data."
    )


if __name__ == "__main__":
    main()
