#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
EVIDENCE = ROOT / "evidence/pdf/persisted_western_natal_snapshot.json"
RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)

EXPECTED = {
    724: "Calculation Manifest",
    725: "engineVersion",
    726: "algorithmVersion",
    727: "dataVersion",
    729: "ev sistemi",
    730: "zodiac sistemi",
    737: "yeniden üretilebilir",
    738: "sessizce değiştirmeyecek",
    763: "transaction",
    765: "atomik",
    870: "vektörel",
    920: "Harita bölümü",
    921: "Gezegenler bölümü",
    922: "Evler bölümü",
    923: "Aspectler bölümü",
}


def main() -> None:
    master_text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    master = {int(n): body.strip() for n, body in RC_RE.findall(master_text)}
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    actual = evidence.get("requirement_ids")
    if not isinstance(actual, list):
        raise SystemExit("Persisted Western evidence must expose requirement_ids[].")
    expected_tokens = {f"RC-{rc:04d}" for rc in EXPECTED}
    if set(actual) != expected_tokens:
        missing = sorted(expected_tokens - set(actual))
        extra = sorted(set(actual) - expected_tokens)
        raise SystemExit(f"Persisted Western semantic ownership drift: missing={missing}, extra={extra}")

    for rc, keyword in EXPECTED.items():
        body = master.get(rc)
        if body is None:
            raise SystemExit(f"MASTER missing RC-{rc:04d}")
        if keyword.casefold() not in body.casefold():
            raise SystemExit(
                f"RC-{rc:04d} semantic ownership drift; expected keyword {keyword!r}, got: {body}"
            )

    print("Persisted Western semantic RC traceability: OK")


if __name__ == "__main__":
    main()
