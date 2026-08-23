#!/usr/bin/env python3
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "evidence/pdf/combined_report_contract.json"
SOURCE = ROOT / "lib/src/pdf/pdf_combined_report.dart"
TEST = ROOT / "test/pdf/pdf_combined_report_test.dart"
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"


def fail(message: str) -> None:
    print(f"combined-pdf-contract: FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST, MASTER):
        if not path.is_file():
            fail(f"missing required file: {path.relative_to(ROOT)}")

    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    if evidence.get("requirements") != ["RC-0903"]:
        fail("evidence must own exactly RC-0903")
    if evidence.get("done") is not False:
        fail("combined report evidence must remain done=false until production integration and final proof")

    master = MASTER.read_text(encoding="utf-8")
    match = re.search(r"^903\.\s+(.+)$", master, flags=re.MULTILINE)
    if not match or "Kombine danışmanlık raporu" not in match.group(1):
        fail("RC-0903 master semantic not found")

    source = SOURCE.read_text(encoding="utf-8")
    required_source_tokens = (
        "final class PdfCombinedMember",
        "final class PdfCombinedReportBuilder",
        "PdfReportKind get reportKind => PdfReportKind.combined",
        "Combined PDF requires at least two calculation systems",
        "Combined PDF members must belong to the same subject",
        "Combined PDF systems collide on section",
        "sha256.convert",
        "PdfSectionIds.technicalManifest",
        "PdfCombinedReportService",
    )
    for token in required_source_tokens:
        if token not in source:
            fail(f"source contract token missing: {token}")

    test = TEST.read_text(encoding="utf-8")
    required_test_tokens = (
        "combines two distinct systems for the same subject deterministically",
        "rejects a combined report with fewer than two systems",
        "rejects members that belong to different stable subjects",
        "rejects section collisions between systems",
        "rejects child render data with another snapshot digest",
        "rejects child cover or technical-manifest ownership",
    )
    for token in required_test_tokens:
        if token not in test:
            fail(f"test contract token missing: {token}")

    for key in ("source_files", "test_files"):
        values = evidence.get(key)
        if not isinstance(values, list) or not values:
            fail(f"{key} must be a non-empty list")
        for raw in values:
            candidate = ROOT / raw
            if not candidate.is_file():
                fail(f"evidence references missing file: {raw}")

    blockers = evidence.get("remainingBeforeDone")
    if not isinstance(blockers, list) or not blockers:
        fail("remainingBeforeDone must describe the still-open production proof")

    print("combined-pdf-contract: OK")


if __name__ == "__main__":
    main()
