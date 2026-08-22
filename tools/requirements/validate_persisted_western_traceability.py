#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)

CONTRACTS = {
    "evidence/pdf/persisted_western_natal_snapshot.json": {
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
    },
    "evidence/pdf/persisted_manifest_section.json": {
        911: "koordinat",
        912: "timezone",
        913: "hesaplama sistemi",
        914: "Ev sistemi",
        916: "Calculation Manifest",
    },
    "evidence/pdf/persisted_western_pdf_service.json": {
        916: "Calculation Manifest",
        920: "Harita bölümü",
        921: "Gezegenler bölümü",
        922: "Evler bölümü",
        923: "Aspectler bölümü",
        964: "Yanlış müşteri verisinin",
    },
}


def load_requirements(payload: dict, path: str) -> list[str]:
    actual = payload.get("requirement_ids")
    if actual is None:
        actual = payload.get("requirements")
    if not isinstance(actual, list) or not actual:
        raise SystemExit(f"{path}: non-empty requirement_ids[] or requirements[] is required")
    return actual


def main() -> None:
    master_text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    master = {int(n): body.strip() for n, body in RC_RE.findall(master_text)}

    for relative, expected in CONTRACTS.items():
        path = ROOT / relative
        if not path.is_file():
            raise SystemExit(f"Missing persisted Western evidence: {relative}")
        evidence = json.loads(path.read_text(encoding="utf-8"))
        actual = load_requirements(evidence, relative)
        expected_tokens = {f"RC-{rc:04d}" for rc in expected}
        if set(actual) != expected_tokens:
            missing = sorted(expected_tokens - set(actual))
            extra = sorted(set(actual) - expected_tokens)
            raise SystemExit(
                f"{relative}: persisted Western semantic ownership drift: missing={missing}, extra={extra}"
            )

        for rc, keyword in expected.items():
            body = master.get(rc)
            if body is None:
                raise SystemExit(f"MASTER missing RC-{rc:04d}")
            if keyword.casefold() not in body.casefold():
                raise SystemExit(
                    f"{relative}: RC-{rc:04d} semantic ownership drift; "
                    f"expected keyword {keyword!r}, got: {body}"
                )

    print(
        f"Persisted Western semantic RC traceability: OK ({len(CONTRACTS)} evidence contracts)"
    )


if __name__ == "__main__":
    main()
