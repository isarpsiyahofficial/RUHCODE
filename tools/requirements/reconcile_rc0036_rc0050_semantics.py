#!/usr/bin/env python3
"""Repair RC-0036..RC-0050 matrix rows that were promoted against shifted semantics.

The binding source is RUH_CODE_MASTER_SARTNAME.md.  This script is intentionally
conservative: rows whose evidence was produced for a different numbered
requirement are reset to NOT_STARTED rather than reinterpreted.
"""
from __future__ import annotations

import csv
import re
from pathlib import Path

SPEC = Path("RUH_CODE_MASTER_SARTNAME.md")
MATRIX = Path("requirements/requirement_state.csv")

EXPECTED = {
    36: "Ev yöneticileri hesaplanacak.",
    37: "Kavuşum açıları hesaplanacak.",
    38: "Karşıt açıları hesaplanacak.",
    39: "Kare açıları hesaplanacak.",
    40: "Üçgen açıları hesaplanacak.",
    41: "Sekstil açıları hesaplanacak.",
    42: "Gerekli minor aspect sistemleri profesyonel ayarlarda desteklenilecek.",
    43: "Aspect orb değerleri sabit kodlanmak yerine sistem tarafından yönetilebilir olacak.",
    44: "Profesyonel kullanıcı isterse orb ayarlarını değiştirebilecek.",
    45: "Element dağılımı hesaplanacak.",
    46: "Ateş, Toprak, Hava ve Su yoğunlukları gösterilecek.",
    47: "Öncü, Sabit ve Değişken nitelik dağılımları hesaplanacak.",
    48: "Retrograde gezegenler ayrıca belirtilecek.",
    49: "Gezegen yöneticilikleri gösterilebilecek.",
    50: "Exaltation, detriment ve fall gibi klasik astrolojik durumlar desteklenilecek.",
}

# These rows were physically promoted by evidence whose filenames/notes describe
# different requirements (for example RC-0050 applying/separating, while binding
# RC-0050 is classical dignity support).  Do not retain those promotions.
RESET_IDS = {f"RC-{n:04d}" for n in range(41, 51)}


def parse_spec() -> dict[int, str]:
    found: dict[int, str] = {}
    for line in SPEC.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^(\d+)\.\s+(.*)$", line.strip())
        if m:
            found[int(m.group(1))] = m.group(2).strip()
    return found


def main() -> None:
    spec = parse_spec()
    for number, expected in EXPECTED.items():
        actual = spec.get(number)
        if actual != expected:
            raise SystemExit(
                f"Binding specification drift at RC-{number:04d}: expected {expected!r}, got {actual!r}"
            )

    with MATRIX.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        raise SystemExit("Requirement matrix is empty")
    fields = list(rows[0].keys())

    by_id = {row["rc_id"]: row for row in rows}
    for number in EXPECTED:
        rc_id = f"RC-{number:04d}"
        row = by_id.get(rc_id)
        if row is None:
            raise SystemExit(f"Missing matrix row {rc_id}")
        if row["source_spec"] != "RUH_CODE_MASTER_SARTNAME.md" or row["source_number"] != str(number):
            raise SystemExit(f"Source binding mismatch for {rc_id}")

    changed = False
    for rc_id in sorted(RESET_IDS):
        row = by_id[rc_id]
        # Preserve VERIFIED/DONE only if ever independently achieved after this
        # repair script exists. Current shifted evidence is TESTED-level only.
        if row["status"] in {"VERIFIED", "DONE"}:
            raise SystemExit(f"Refusing automatic demotion of {rc_id} from {row['status']}")
        desired = {
            "status": "NOT_STARTED",
            "evidence_links": "",
            "blocked": "NO",
            "blocker": "",
            "notes": (
                "Semantic reconciliation: prior TESTED evidence was bound to a shifted/non-matching "
                "requirement meaning. Reset conservatively; this RC must be re-proven against the exact "
                "binding specification text before promotion."
            ),
        }
        for key, value in desired.items():
            if row[key] != value:
                row[key] = value
                changed = True

    if changed:
        with MATRIX.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields)
            writer.writeheader()
            writer.writerows(rows)

    print("RC-0036..RC-0050 binding semantics verified; shifted RC-0041..RC-0050 promotions reconciled.")


if __name__ == "__main__":
    main()
