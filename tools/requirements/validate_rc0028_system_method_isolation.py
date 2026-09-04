#!/usr/bin/env python3
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC_ID = 'RC-0028'
CONTRACT = ROOT / 'requirements/contracts/rc0028_system_method_isolation_contract.json'
MATRIX = ROOT / 'requirements/requirement_state.csv'
IMPORT_RE = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def imported_system(importer: Path, uri: str, system_roots: dict[str, str]) -> str | None:
    if uri.startswith('dart:') or uri.startswith('package:flutter'):
        return None
    if uri.startswith('package:ruh_code/'):
        rel = uri[len('package:ruh_code/'):]
        candidate = ROOT / rel
    elif uri.startswith('.'):
        candidate = (importer.parent / uri).resolve()
    else:
        return None
    try:
        rel_candidate = candidate.relative_to(ROOT).as_posix()
    except ValueError:
        return None
    for name, root in system_roots.items():
        root_prefix = root.rstrip('/') + '/'
        if rel_candidate == root or rel_candidate.startswith(root_prefix):
            return name
    return None


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    rows = list(csv.DictReader(MATRIX.open(encoding='utf-8', newline='')))
    row = next(r for r in rows if r['rc_id'] == RC_ID)
    require(contract['rcId'] == RC_ID, 'RC-0028 contract id mismatch')
    require(contract['bindingRequirementSha256'] == row['source_text_sha256'], 'RC-0028 binding SHA mismatch')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0028 promotion ceiling weakened')

    system_roots = contract['systemRoots']
    require(len(system_roots) >= 5, 'RC-0028 expected named calculation systems missing')
    scanned = 0
    for system, rel_root in system_roots.items():
        root = ROOT / rel_root
        require(root.is_dir(), f'RC-0028 system root missing: {rel_root}')
        files = sorted(root.rglob('*.dart'))
        require(files, f'RC-0028 system root has no Dart implementation: {rel_root}')
        for path in files:
            text = path.read_text(encoding='utf-8')
            scanned += 1
            for uri in IMPORT_RE.findall(text):
                target = imported_system(path, uri, system_roots)
                if target is not None and target != system:
                    raise SystemExit(
                        f'RC-0028 cross-system calculation import: '
                        f'{path.relative_to(ROOT)} ({system}) -> {uri} ({target})'
                    )

    require(scanned >= 10, 'RC-0028 system scan unexpectedly small')
    print(f'RC-0028 system method isolation contract: PASS ({scanned} Dart files)')


if __name__ == '__main__':
    main()
