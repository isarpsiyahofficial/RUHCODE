#!/usr/bin/env python3
"""Repository-wide integrity checks for machine-readable evidence contracts.

This validator is intentionally generic. Semantic RC ownership for selected contracts
is enforced by validate_evidence_traceability.py; this file makes sure *all* evidence
JSON files cannot silently reference invalid requirements or missing source/test files.
"""

from __future__ import annotations

import json
import re
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE_ROOT = ROOT / "evidence"
RC_TOKEN = re.compile(r"RC-(\d{4})$")
MAX_RC = 1442


def _fail(path: Path, message: str) -> None:
    rel = path.relative_to(ROOT)
    raise AssertionError(f"{rel}: {message}")


def _require_safe_repo_path(evidence_path: Path, raw: object, field: str) -> None:
    if not isinstance(raw, str) or not raw.strip():
        _fail(evidence_path, f"{field} entries must be non-empty strings")

    value = raw.strip().replace("\\", "/")
    if "://" in value:
        # URLs are provenance references, not repository paths.
        return

    posix = PurePosixPath(value)
    if posix.is_absolute() or ".." in posix.parts:
        _fail(evidence_path, f"unsafe {field} repository path: {raw!r}")

    target = ROOT.joinpath(*posix.parts)
    if not target.exists():
        _fail(evidence_path, f"missing {field} repository path: {value}")
    if not target.is_file():
        _fail(evidence_path, f"{field} path must resolve to a file: {value}")


def _parse_requirement_list(evidence_path: Path, payload: dict) -> set[int]:
    reqs = payload.get("requirements")
    req_ids = payload.get("requirement_ids")

    if reqs is None and req_ids is None:
        return set()

    parsed_sets: list[set[int]] = []
    for field, value in (("requirements", reqs), ("requirement_ids", req_ids)):
        if value is None:
            continue
        if not isinstance(value, list) or not value:
            _fail(evidence_path, f"{field} must be a non-empty list when present")

        parsed: list[int] = []
        for token in value:
            if not isinstance(token, str):
                _fail(evidence_path, f"{field} token must be a string: {token!r}")
            match = RC_TOKEN.fullmatch(token)
            if not match:
                _fail(evidence_path, f"invalid {field} token: {token!r}")
            number = int(match.group(1))
            if not 1 <= number <= MAX_RC:
                _fail(evidence_path, f"out-of-range requirement token: {token}")
            parsed.append(number)

        if len(parsed) != len(set(parsed)):
            _fail(evidence_path, f"duplicate IDs in {field}")
        parsed_sets.append(set(parsed))

    if len(parsed_sets) == 2 and parsed_sets[0] != parsed_sets[1]:
        _fail(
            evidence_path,
            "requirements and requirement_ids disagree; keep a single canonical RC set",
        )
    return parsed_sets[0]


def _validate_path_list(evidence_path: Path, payload: dict, field: str) -> int:
    value = payload.get(field)
    if value is None:
        return 0
    if not isinstance(value, list):
        _fail(evidence_path, f"{field} must be a list when present")
    seen: set[str] = set()
    for entry in value:
        if not isinstance(entry, str):
            _fail(evidence_path, f"{field} entries must be strings: {entry!r}")
        normalized = entry.strip().replace("\\", "/")
        if normalized in seen:
            _fail(evidence_path, f"duplicate {field} path: {normalized}")
        seen.add(normalized)
        _require_safe_repo_path(evidence_path, entry, field)
    return len(value)


def main() -> None:
    if not EVIDENCE_ROOT.is_dir():
        raise AssertionError("evidence/ directory is missing")

    files = sorted(EVIDENCE_ROOT.rglob("*.json"))
    if not files:
        raise AssertionError("no evidence JSON files found")

    contracts = 0
    requirement_links = 0
    source_links = 0
    test_links = 0
    validator_links = 0

    for path in files:
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            _fail(path, f"invalid UTF-8 JSON: {exc}")
        if not isinstance(payload, dict):
            _fail(path, "top-level JSON value must be an object")

        if "contract" in payload:
            contract = payload["contract"]
            if not isinstance(contract, str) or not contract.strip():
                _fail(path, "contract must be a non-empty string when present")
            contracts += 1

        requirement_links += len(_parse_requirement_list(path, payload))
        source_links += _validate_path_list(path, payload, "sources")
        test_links += _validate_path_list(path, payload, "tests")
        validator_links += _validate_path_list(path, payload, "validators")

        done = payload.get("done")
        if done is not None and not isinstance(done, bool):
            _fail(path, "done must be boolean when present")

        blockers = payload.get("releaseBlockers")
        if blockers is not None:
            if not isinstance(blockers, list) or any(
                not isinstance(item, str) or not item.strip() for item in blockers
            ):
                _fail(path, "releaseBlockers must be a list of non-empty strings")
            if done is True and blockers:
                _fail(path, "done=true evidence cannot retain releaseBlockers")

    print(
        "OK: evidence integrity validated for "
        f"{len(files)} JSON files; contracts={contracts}; "
        f"RC-links={requirement_links}; sources={source_links}; "
        f"tests={test_links}; validators={validator_links}"
    )


if __name__ == "__main__":
    main()
