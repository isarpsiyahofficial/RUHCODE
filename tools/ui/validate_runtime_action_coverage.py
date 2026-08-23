#!/usr/bin/env python3
import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BINDINGS = ROOT / "ui/runtime_action_bindings.csv"
CONSTANTS = ROOT / "lib/src/ui/actions/ruh_action_ids.dart"


def die(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    rows = list(csv.DictReader(BINDINGS.open(encoding="utf-8", newline="")))
    if not rows:
        die("runtime action binding manifest is empty")

    constants_text = CONSTANTS.read_text(encoding="utf-8")
    constants = {
        name: action_id
        for name, action_id in re.findall(
            r"static const\s+(\w+)\s*=\s*'([^']+)'\s*;",
            constants_text,
        )
    }
    if not constants:
        die("no canonical RuhActionIds constants found")

    seen_ids: set[str] = set()
    seen_constants: set[str] = set()
    for row_number, row in enumerate(rows, start=2):
        action_id = row["action_id"].strip()
        constant_name = row["constant_name"].strip()
        binding_file = row["binding_file"].strip()
        status = row["status"].strip()

        if status != "IMPLEMENTED":
            die(f"runtime binding row must be IMPLEMENTED: {action_id} -> {status!r}")
        if action_id in seen_ids:
            die(f"duplicate runtime action binding: {action_id}")
        if constant_name in seen_constants:
            die(f"canonical constant bound more than once: {constant_name}")
        seen_ids.add(action_id)
        seen_constants.add(constant_name)

        expected_id = constants.get(constant_name)
        if expected_id is None:
            die(f"binding references missing RuhActionIds constant: {constant_name}")
        if expected_id != action_id:
            die(
                f"binding/constant mismatch on row {row_number}: "
                f"{constant_name}={expected_id}, manifest={action_id}"
            )

        path = ROOT / binding_file
        if not path.is_file():
            die(f"runtime binding source is missing: {binding_file}")
        source = path.read_text(encoding="utf-8")
        token = f"RuhActionIds.{constant_name}"
        if token not in source:
            die(
                f"dead runtime action binding: {action_id} declares {binding_file} "
                f"but {token} is not referenced there"
            )

    declared_runtime_constants = set(constants)
    missing_manifest = declared_runtime_constants - seen_constants
    extra_manifest = seen_constants - declared_runtime_constants
    if missing_manifest:
        die(f"RuhActionIds constants missing runtime binding rows: {sorted(missing_manifest)}")
    if extra_manifest:
        die(f"runtime manifest has unknown constants: {sorted(extra_manifest)}")

    set_match = re.search(
        r"allRuntimeBindings\s*=\s*<String>\{(?P<body>.*?)\};",
        constants_text,
        flags=re.DOTALL,
    )
    if set_match is None:
        die("RuhActionIds.allRuntimeBindings set is missing")
    listed = {
        token
        for token in re.findall(r"\b([A-Za-z_]\w*)\s*,", set_match.group("body"))
    }
    if listed != declared_runtime_constants:
        die(
            "allRuntimeBindings drift: "
            f"missing={sorted(declared_runtime_constants - listed)} "
            f"extra={sorted(listed - declared_runtime_constants)}"
        )

    print(
        f"OK: {len(rows)} runtime actions have exact constants, manifest rows, "
        "and live source references; dead bindings rejected"
    )


if __name__ == "__main__":
    main()
