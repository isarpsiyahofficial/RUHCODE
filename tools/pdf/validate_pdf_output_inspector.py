#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/pdf/pdf_output_inspector.dart"
TEST = ROOT / "test/pdf/pdf_output_inspector_test.dart"
EVIDENCE = ROOT / "evidence/pdf/local_renderer_contract.json"


def require(text: str, token: str, label: str) -> None:
    if token not in text:
        raise AssertionError(f"{label}: required token missing: {token!r}")


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    require(source, "hasStartXref", "source")
    require(source, "startXrefOffset", "source")
    require(source, "startXrefTargetRecognized", "source")
    require(source, r"startxref\\s+(\\d+)\\s+%%EOF\\s*$", "source")
    require(source, r"^xref\\b", "source")
    require(source, "/Type\\s*/XRef", "source")
    require(source, "pageTreeCountConsistent", "source")

    require(test, "rejects EOF-only trailer without mandatory startxref", "test")
    require(test, "rejects startxref offset outside the PDF byte range", "test")
    require(test, "rejects startxref offset that points to non-xref content", "test")
    require(test, "rejects junk after final EOF marker", "test")
    require(test, "page-count gate verifies 50+ page regression fixture", "test")

    properties = evidence.get("requiredProperties")
    if not isinstance(properties, list):
        raise AssertionError("evidence: requiredProperties[] is required")
    joined = "\n".join(str(item) for item in properties).casefold()
    for phrase in (
        "startxref",
        "xref table or xref stream",
        "junk appended after the final eof",
        "pages-tree declared count",
    ):
        if phrase not in joined:
            raise AssertionError(f"evidence: required property missing phrase {phrase!r}")

    if evidence.get("done") is not False:
        raise AssertionError("evidence must remain done=false until independent parser/render proof exists")

    print("OK: PDF structural inspector requires final EOF, startxref, valid xref target, and page-tree count consistency")


if __name__ == "__main__":
    main()
