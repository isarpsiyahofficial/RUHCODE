#!/usr/bin/env python3
"""Fail-closed integrity contract for the binding RC-0001..RC-1442 ledger."""

from __future__ import annotations

import csv
import hashlib
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
ALLOWED_STATUSES = {"NOT_STARTED", "IMPLEMENTED", "TESTED", "VERIFIED", "DONE"}
ALLOWED_TAGS = {"TRACE", "CALC", "CONTENT", "UI", "I18N", "OFFLINE", "ENTITLEMENT", "BACKUP", "PDF", "SECURITY", "A11Y", "PERF", "RELEASE"}
REQUIRED_COLUMNS = [
    "rc_id",
    "status",
    "task_ids",
    "tags",
    "evidence_type",
    "evidence_required",
    "evidence_links",
    "blocked",
    "blocker",
    "source_spec",
    "source_number",
    "source_text_sha256",
    "notes",
]
NUMBERED_REQUIREMENT = re.compile(r"(?m)^(\d+)\.\s+(.+?)\s*$")
TASK_ID = re.compile(r"^TASK-[A-Z0-9][A-Z0-9._-]*$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")


def fail(message: str) -> None:
    raise SystemExit(f"REQUIREMENT_MATRIX_CONTRACT_FAIL: {message}")


def normalize_text(text: str) -> str:
    return " ".join(text.strip().split())


def parse_specs() -> dict[str, dict[str, str]]:
    combined: list[int] = []
    by_id: dict[str, dict[str, str]] = {}
    for path, first, last in SPECS:
        if not path.is_file():
            fail(f"missing binding specification: {path.relative_to(ROOT)}")
        text = path.read_text(encoding="utf-8")
        matches = [(int(m.group(1)), normalize_text(m.group(2))) for m in NUMBERED_REQUIREMENT.finditer(text)]
        actual = [number for number, _ in matches]
        expected = list(range(first, last + 1))
        if actual != expected:
            missing = sorted(set(expected) - set(actual))
            duplicate_count = len(actual) - len(set(actual))
            unexpected = sorted(set(actual) - set(expected))
            fail(
                f"{path.name} numbering mismatch: count={len(actual)} expected={len(expected)} "
                f"missing={missing[:10]} unexpected={unexpected[:10]} duplicate_count={duplicate_count}"
            )
        for number, requirement in matches:
            rc_id = f"RC-{number:04d}"
            by_id[rc_id] = {
                "source_spec": path.name,
                "source_number": str(number),
                "source_text_sha256": hashlib.sha256(requirement.encode("utf-8")).hexdigest(),
            }
        combined.extend(actual)
    if combined != list(range(1, 1443)):
        fail("binding specifications do not form exact contiguous RC-0001..RC-1442")
    return by_id


def validate_matrix(specs: dict[str, dict[str, str]]) -> dict[str, int]:
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
        id_set = set(ids)
        missing = [rc for rc in EXPECTED_IDS if rc not in id_set]
        duplicates = sorted({rc for rc in ids if ids.count(rc) > 1})
        unexpected = sorted(set(ids) - set(EXPECTED_IDS))
        fail(
            "matrix IDs are not exact/ordered RC-0001..RC-1442; "
            f"missing={missing[:10]} duplicates={duplicates[:10]} unexpected={unexpected[:10]}"
        )

    counts = {status: 0 for status in ALLOWED_STATUSES}
    blocked_count = 0
    for line_no, row in enumerate(rows, start=2):
        rc_id = row["rc_id"].strip()
        status = row["status"].strip()
        if status not in ALLOWED_STATUSES:
            fail(f"{rc_id} line {line_no}: invalid lifecycle status {status!r}")

        task_ids = [item.strip() for item in row["task_ids"].split("|") if item.strip()]
        if not task_ids or any(not TASK_ID.fullmatch(item) for item in task_ids):
            fail(f"{rc_id} line {line_no}: at least one valid TASK-* id is required")

        tags = [item.strip() for item in row["tags"].split("|") if item.strip()]
        if not tags:
            fail(f"{rc_id} line {line_no}: tags must not be empty")
        unknown_tags = sorted(set(tags) - ALLOWED_TAGS)
        if unknown_tags:
            fail(f"{rc_id} line {line_no}: unknown tags {unknown_tags}")

        if not row["evidence_type"].strip():
            fail(f"{rc_id} line {line_no}: evidence_type is required")
        if row["evidence_required"].strip() != "YES":
            fail(f"{rc_id} line {line_no}: evidence_required must be YES")
        if status == "DONE" and not row["evidence_links"].strip():
            fail(f"{rc_id} line {line_no}: DONE requires non-empty evidence_links")

        blocked = row["blocked"].strip()
        blocker = row["blocker"].strip()
        if blocked not in {"YES", "NO"}:
            fail(f"{rc_id} line {line_no}: blocked must be YES or NO")
        if blocked == "YES" and not blocker:
            fail(f"{rc_id} line {line_no}: blocked=YES requires blocker text")
        if blocked == "NO" and blocker:
            fail(f"{rc_id} line {line_no}: blocker text requires blocked=YES")
        if blocked == "YES" and status == "DONE":
            fail(f"{rc_id} line {line_no}: DONE cannot remain blocked")
        blocked_count += int(blocked == "YES")

        expected_source = specs[rc_id]
        for key in ("source_spec", "source_number", "source_text_sha256"):
            if row[key].strip() != expected_source[key]:
                fail(f"{rc_id} line {line_no}: {key} is not bound to the canonical specification")
        if not SHA256.fullmatch(row["source_text_sha256"].strip()):
            fail(f"{rc_id} line {line_no}: invalid source_text_sha256")

        # Lifecycle monotonicity is semantic: later states require evidence.
        if status in {"TESTED", "VERIFIED", "DONE"} and not row["evidence_links"].strip():
            fail(f"{rc_id} line {line_no}: {status} requires evidence_links")
        counts[status] += 1

    counts["BLOCKED"] = blocked_count
    return counts


def main() -> int:
    specs = parse_specs()
    counts = validate_matrix(specs)
    print(
        "REQUIREMENT_MATRIX_CONTRACT_OK "
        f"total=1442 not_started={counts['NOT_STARTED']} implemented={counts['IMPLEMENTED']} "
        f"tested={counts['TESTED']} verified={counts['VERIFIED']} done={counts['DONE']} "
        f"blocked={counts['BLOCKED']}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
