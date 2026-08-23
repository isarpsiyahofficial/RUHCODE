#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
EVIDENCE = ROOT / "evidence/pdf/page_geometry_contract.json"

RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)
EXPECTED = {878, 879}
KEYWORDS = {
    878: "A4/Letter",
    879: "Varsayılan profesyonel rapor A4",
}


def main():
    master_text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    master = {int(n): body.strip() for n, body in RC_RE.findall(master_text)}

    payload = json.loads(EVIDENCE.read_text(encoding="utf-8"))
    reqs = payload.get("requirements")
    if not isinstance(reqs, list):
        raise AssertionError("page geometry evidence requires requirements[]")

    actual = set()
    for token in reqs:
        if not isinstance(token, str) or not re.fullmatch(r"RC-\d{4}", token):
            raise AssertionError(f"invalid requirement token: {token!r}")
        actual.add(int(token[3:]))

    if actual != EXPECTED:
        raise AssertionError(
            f"page geometry semantic ownership mismatch; expected={sorted(EXPECTED)}, actual={sorted(actual)}"
        )

    for rc, keyword in KEYWORDS.items():
        text = master.get(rc)
        if text is None:
            raise AssertionError(f"RC-{rc:04d} missing from MASTER")
        if keyword.casefold() not in text.casefold():
            raise AssertionError(
                f"RC-{rc:04d} MASTER semantic drift: expected keyword {keyword!r}; actual={text!r}"
            )

    if payload.get("done") is True:
        raise AssertionError(
            "page geometry evidence cannot be DONE before approved-font rendered fixtures, visual regression, device-open proof, and exact CI evidence"
        )

    required_sources = {
        "lib/src/pdf/pdf_page_geometry_inspector.dart",
        "lib/src/pdf/pdf_local_service.dart",
    }
    required_tests = {"test/pdf/pdf_page_geometry_inspector_test.dart"}
    if set(payload.get("source_files", [])) != required_sources:
        raise AssertionError("page geometry source_files drift")
    if set(payload.get("test_files", [])) != required_tests:
        raise AssertionError("page geometry test_files drift")

    for path in sorted(required_sources | required_tests):
        if not (ROOT / path).is_file():
            raise AssertionError(f"missing page geometry evidence path: {path}")

    print("OK: PDF page geometry evidence is semantically bound to RC-0878/RC-0879 and remains non-DONE until final proofs exist")


if __name__ == "__main__":
    main()
