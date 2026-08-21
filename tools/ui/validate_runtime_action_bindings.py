#!/usr/bin/env python3
import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / 'ui/action_registry.csv'
BINDINGS = ROOT / 'ui/runtime_action_bindings.csv'
ACTION_IDS = ROOT / 'lib/src/ui/actions/ruh_action_ids.dart'


def die(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    registry_rows = list(csv.DictReader(REGISTRY.open(encoding='utf-8', newline='')))
    registry = {row['action_id'].strip(): row for row in registry_rows}
    if len(registry) != len(registry_rows):
        die('action registry contains duplicate action IDs')

    action_source = ACTION_IDS.read_text(encoding='utf-8')
    constant_pairs = dict(
        re.findall(r"static const\s+(\w+)\s*=\s*'(ACTION-[A-Z0-9-]+)';", action_source)
    )
    if not constant_pairs:
        die('no canonical runtime action constants found')

    bindings = list(csv.DictReader(BINDINGS.open(encoding='utf-8', newline='')))
    seen_actions = set()
    seen_constants = set()
    allowed_kinds = {'NAVIGATION', 'ROUTE', 'INPUT', 'DATA', 'TOGGLE', 'FILTER', 'BACKUP', 'PDF', 'SHARE'}

    for line, row in enumerate(bindings, 2):
        action_id = row['action_id'].strip()
        constant_name = row['constant_name'].strip()
        binding_file = row['binding_file'].strip()
        binding_kind = row['binding_kind'].strip()
        status = row['status'].strip()

        if status != 'IMPLEMENTED':
            die(f'runtime binding must be IMPLEMENTED on line {line}: {action_id}')
        if action_id in seen_actions:
            die(f'duplicate runtime action binding: {action_id}')
        if constant_name in seen_constants:
            die(f'duplicate runtime constant binding: {constant_name}')
        seen_actions.add(action_id)
        seen_constants.add(constant_name)

        registry_row = registry.get(action_id)
        if registry_row is None:
            die(f'runtime action is absent from action registry: {action_id}')
        if registry_row['status'].strip() != 'ACTIVE':
            die(f'runtime action is not ACTIVE in registry: {action_id}')
        if registry_row['a11y_label_required'].strip().lower() != 'true':
            die(f'runtime action must require accessibility label: {action_id}')
        if binding_kind not in allowed_kinds:
            die(f'unknown binding kind for {action_id}: {binding_kind}')

        actual_action = constant_pairs.get(constant_name)
        if actual_action != action_id:
            die(
                f'constant/action mismatch for {constant_name}: '
                f'expected {action_id}, found {actual_action!r}'
            )

        path = ROOT / binding_file
        if not path.is_file():
            die(f'binding file does not exist for {action_id}: {binding_file}')
        text = path.read_text(encoding='utf-8')
        marker = f'RuhActionIds.{constant_name}'
        if marker not in text:
            die(f'binding file does not reference {marker} for {action_id}')

    scalar_constants = set(constant_pairs)
    missing = scalar_constants - seen_constants
    extra = seen_constants - scalar_constants
    if missing:
        die(f'canonical runtime action constants missing bindings: {sorted(missing)}')
    if extra:
        die(f'bindings reference unknown runtime constants: {sorted(extra)}')

    print(
        f'OK: runtime action bindings validated; implemented_actions={len(bindings)}, '
        f'registry_actions={len(registry_rows)}'
    )


if __name__ == '__main__':
    main()
