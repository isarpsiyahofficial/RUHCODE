#!/usr/bin/env python3
"""Machine-readable requirement/test traceability audit for RC-0001..RC-1442.

Normal CI reports incomplete traceability without pretending the product is
release-ready. `--release` is fail-closed: every requirement must be DONE and
must have at least one repository test path linked in its evidence.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "requirements" / "requirement_state.csv"
REPORT = ROOT / "requirements" / "requirement_test_traceability_report.json"
RC = re.compile(r"RC-\d{4}")
TEST_SUFFIXES = ("_test.dart", "_test.py", "test.py")


def test_files() -> list[Path]:
    roots = [ROOT / "test", ROOT / "tools" / "requirements" / "tests"]
    result: list[Path] = []
    for base in roots:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and path.name.endswith(TEST_SUFFIXES):
                result.append(path)
    return sorted(result)


def linked_test_paths(evidence: str) -> list[str]:
    return [
        item.strip()
        for item in evidence.split("|")
        if item.strip().endswith(TEST_SUFFIXES)
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--release", action="store_true")
    parser.add_argument("--write-report", action="store_true")
    args = parser.parse_args()

    with MATRIX.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))

    if len(rows) != 1442:
        raise SystemExit(f"TRACEABILITY_FAIL: expected 1442 rows, got {len(rows)}")

    all_tests = test_files()
    unbound_tests: list[str] = []
    for path in all_tests:
        relative = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8", errors="replace")
        linked_from_matrix = any(relative in row["evidence_links"] for row in rows)
        embedded_id = bool(RC.search(text))
        if not linked_from_matrix and not embedded_id:
            unbound_tests.append(relative)

    no_test_link = [
        row["rc_id"] for row in rows if not linked_test_paths(row["evidence_links"])
    ]
    not_done = [row["rc_id"] for row in rows if row["status"] != "DONE"]

    report = {
        "total_requirements": len(rows),
        "total_test_files": len(all_tests),
        "requirements_without_test_link": no_test_link,
        "unbound_test_files": unbound_tests,
        "not_done_requirements": not_done,
        "release_ready": not no_test_link and not not_done,
    }
    if args.write_report:
        REPORT.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    print(
        "REQUIREMENT_TEST_TRACEABILITY "
        f"requirements={len(rows)} tests={len(all_tests)} "
        f"missing_test_links={len(no_test_link)} "
        f"unbound_tests={len(unbound_tests)} not_done={len(not_done)}"
    )
    if args.release and (no_test_link or not_done):
        raise SystemExit(
            "TRACEABILITY_RELEASE_FAIL: final release requires every RC to be "
            "DONE and linked to at least one test path"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
