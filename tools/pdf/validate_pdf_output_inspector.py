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

    for token in (
        "hasStartXref",
        "startXrefOffset",
        "startXrefTargetRecognized",
        "xrefHasRootReference",
        "rootReferenceResolvesToCatalog",
        "catalogPagesReferenceResolves",
        "pageParentsPresent",
        "pageParentsResolveToPages",
        "pageParentLinksValid",
        "_pageObjects",
        "_pageParentStatus",
        "_rootReference",
        "_catalogPagesReference",
        "_objectHasType",
        r"startxref\s+(\d+)\s+%%EOF\s*$",
        r"^xref\b",
        r"/Type\s*/XRef",
        "pageTreeCountConsistent",
    ):
        require(source, token, "source")

    for token in (
        "rejects EOF-only trailer without mandatory startxref",
        "rejects startxref offset outside the PDF byte range",
        "rejects startxref offset that points to non-xref content",
        "rejects xref trailer that does not declare a Root reference",
        "rejects Root reference that does not resolve to Catalog object",
        "rejects Catalog Pages reference that does not resolve to Pages tree",
        "rejects a Page object that omits mandatory Parent reference",
        "rejects a Page Parent reference that resolves to non-Pages object",
        "rejects junk after final EOF marker",
        "page-count gate verifies 50+ page regression fixture",
    ):
        require(test, token, "test")

    properties = evidence.get("requiredProperties")
    if not isinstance(properties, list):
        raise AssertionError("evidence: requiredProperties[] is required")
    joined = "\n".join(str(item) for item in properties).casefold()
    for phrase in (
        "startxref",
        "xref table or xref stream",
        "junk appended after the final eof",
        "pages-tree declared count",
        "every page object must declare an indirect parent reference",
        "every parent reference must resolve to an actual pages-tree object",
        "root reference must resolve to the referenced catalog object",
        "catalog pages reference must resolve to the referenced pages-tree object",
    ):
        if phrase not in joined:
            raise AssertionError(f"evidence: required property missing phrase {phrase!r}")

    if evidence.get("done") is not False:
        raise AssertionError("evidence must remain done=false until independent parser/render proof exists")

    print(
        "OK: PDF structural inspector requires final EOF, startxref, valid xref target, "
        "Root->Catalog->Pages resolution, Page->Parent->Pages linkage, and page-tree count consistency"
    )


if __name__ == "__main__":
    main()
