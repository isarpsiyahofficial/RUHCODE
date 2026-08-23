#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)

EXPECTED = {
    "evidence/ui/design_token_contrast_contract.json": {1441},
    "evidence/ui/runtime_theme_token_contract.json": {1441},
    "evidence/ui/accessibility_text_scale_contract.json": {1441},
    "evidence/ui/critical_semantics_contract.json": {1441},
    "evidence/ui/runtime_action_coverage_contract.json": {1440},
    "evidence/ui/backup_restore_preview_accessibility_contract.json": {
        832, 833, 834, 835, 836, 837, 838, 839, 1440, 1441,
    },
}

KEYWORDS = {
    832: "önizleme gösterilecek",
    833: "Kaç profil",
    834: "Kaç müşteri",
    835: "Kaç danışmanlık",
    836: "Kaç günlük kaydı",
    837: "Kaç hesaplama",
    838: "Birleştir",
    839: "Mevcut veriyi değiştir",
    1440: "navigation/action sözleşmesi",
    1441: "Accessibility zorunlu olacak",
}


def load_master() -> dict[int, str]:
    text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    items = {int(number): body.strip() for number, body in RC_RE.findall(text)}
    if set(items) != set(range(1, 1443)):
        missing = sorted(set(range(1, 1443)) - set(items))
        extra = sorted(set(items) - set(range(1, 1443)))
        raise AssertionError(f"MASTER sequence drift: missing={missing[:20]} extra={extra[:20]}")
    return items


def load_requirement_ids(relative_path: str) -> set[int]:
    path = ROOT / relative_path
    payload = json.loads(path.read_text(encoding="utf-8"))
    raw = payload.get("requirements")
    if raw is None:
        raw = payload.get("requirement_ids")
    if not isinstance(raw, list) or not raw:
        raise AssertionError(f"{relative_path}: non-empty requirements list is required")
    parsed: list[int] = []
    for token in raw:
        if not isinstance(token, str) or re.fullmatch(r"RC-\d{4}", token) is None:
            raise AssertionError(f"{relative_path}: invalid requirement token {token!r}")
        parsed.append(int(token[3:]))
    if len(parsed) != len(set(parsed)):
        raise AssertionError(f"{relative_path}: duplicate requirement IDs")
    return set(parsed)


def main() -> None:
    master = load_master()

    for rc, keyword in KEYWORDS.items():
        if keyword.casefold() not in master[rc].casefold():
            raise AssertionError(
                f"MASTER UI ownership drift: RC-{rc:04d} no longer contains {keyword!r}: {master[rc]}"
            )

    for relative_path, expected in EXPECTED.items():
        actual = load_requirement_ids(relative_path)
        if actual != expected:
            raise AssertionError(
                f"{relative_path}: semantic RC ownership mismatch; "
                f"missing={sorted(expected - actual)} extra={sorted(actual - expected)}"
            )

    print(
        "OK: exact UI/accessibility/action evidence ownership validated for "
        f"{len(EXPECTED)} contracts"
    )


if __name__ == "__main__":
    main()
