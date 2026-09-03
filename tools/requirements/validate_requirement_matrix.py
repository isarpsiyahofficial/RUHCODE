#!/usr/bin/env python3
"""Fail-closed integrity contract for the binding RC-0001..RC-1442 ledger."""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "requirements" / "requirement_state.csv"
SPECS = (
    (ROOT / "RUH_CODE_MASTER_SARTNAME.md", 1, 1420),
    (ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md", 1421, 1442),
)
EXPECTED_IDS = [f"RC-{i:04d}" for i in range(1, 1443)]
ALLOWED_STATUSES = {"OPEN", "IN_PROGRESS", "BLOCKED", "DONE"}
REQUIRED_COLUMNS = [
    "rc_id",
    "status",
    "task_ids",
    "tags",
    "evidence_required",
    "evidence_links",
    "notes",
]
NUMBERED_REQUIREMENT = re.compile(r"(?m)^(\d+)\.\s+\S")


def fail(message: str) -> None:
    raise SystemExit(f"REQUIREMENT_MATRIX_CONTRACT_FAIL: {message}")


def parse_spec_numbers(path: Path) -> list[int]:
    if not path.is_file():
        fail(f"missing binding specification: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    return [int(match.group(1)) for match in NUMBERED_REQUIREMENT.finditer(text)]


def validate_specs() -> None:
    combined: list[int] = []
    for path, first, last in SPECS:
        actual = parse_spec_numbers(path)
        expected = list(range(first, last + 1))
        if actual != expected:
            missing = sorted(set(expected) - set(actual))
            duplicate_count = len(actual) - len(set(actual))
            unexpected = sorted(set(actual) - set(expected))
            fail(
                f"{path.name} numbering mismatch: count={len(actual)} "
                f"expected={len(expected)} missing={missing[:10]} "
                f"unexpected={unexpected[:10]} duplicate_count={duplicate_count}"
            )
        combined.extend(actual)
    if combined != list(range(1, 1443)):
        fail("binding specifications do not form exact contiguous RC-0001..RC-1442")


def validate_matrix() -> tuple[int, int, int, int]:
    if not MATRIX.is_file():
        fail("missing requirements/requirement_state.csv")
    with MATRIX.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != REQUIRED_COLUMNS:
            fail(f"unexpected CSV columns: {reader.fieldnames!r}")
        rows = list(reader)

    if len(rows) != 1442:
        fail(f"matrix must contain exactly 1442 data rows; found {len(rows)}")

    ids = [row["rc_id"].strip() for row in rows]
    if ids != EXPECTED_IDS:
        missing = [rc for rc in EXPECTED_IDS if rc not in set(ids)]
        duplicates = sorted({rc for rc in ids if ids.count(rc) > 1})
        unexpected = sorted(set(ids) - set(EXPECTED_IDS))
        fail(
            f"matrix IDs are not exact/ordered RC-0001..RC-1442; "
            f"missing={missing[:10]} duplicates={duplicates[:10]} "
            f"unexpected={unexpected[:10]}"
        )

    counts = {status: 0 for status in ALLOWED_STATUSES}
    for line_no, row in enumerate(rows, start=2):
        rc_id = row["rc_id"].strip()
        status = row["status"].strip()
        if status not in ALLOWED_STATUSES:
            fail(f"{rc_id} line {line_no}: invalid status {status!r}")
        if row["evidence_required"].strip() != "YES":
            fail(f"{rc_id} line {line_no}: evidence_required must be YES")
        if status == "DONE" and not row["evidence_links"].strip():
            fail(f"{rc_id} line {line_no}: DONE requires non-empty evidence_links")
        counts[status] += 1

    return (
        counts["OPEN"],
        counts["IN_PROGRESS"],
        counts["BLOCKED"],
        counts["DONE"],
    )


def main() -> int:
    validate_specs()
    open_count, in_progress, blocked, done = validate_matrix()
    print(
        "REQUIREMENT_MATRIX_CONTRACT_OK "
        f"total=1442 open={open_count} in_progress={in_progress} "
        f"blocked={blocked} done={done}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
