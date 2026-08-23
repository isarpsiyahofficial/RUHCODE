#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"
RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)

EXPECTED = {
    "evidence/pdf/local_renderer_contract.json": {950, 951, 953},
}

KEYWORDS = {
    950: "yarım dosya başarılı rapor",
    951: "PDF doğrulama testi",
    953: "Sayfa sayısının sıfır olmadığı",
}


def load_master() -> dict[int, str]:
    text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    items = {int(number): body.strip() for number, body in RC_RE.findall(text)}
    if set(items) != set(range(1, 1443)):
        raise AssertionError("MASTER sequence is not exactly RC-0001..RC-1442")
    return items


def load_requirements(relative_path: str) -> set[int]:
    payload = json.loads((ROOT / relative_path).read_text(encoding="utf-8"))
    raw = payload.get("requirements")
    if not isinstance(raw, list) or not raw:
        raise AssertionError(f"{relative_path}: requirements[] is required")
    values: list[int] = []
    for token in raw:
        if not isinstance(token, str) or re.fullmatch(r"RC-\d{4}", token) is None:
            raise AssertionError(f"{relative_path}: invalid RC token {token!r}")
        values.append(int(token[3:]))
    if len(values) != len(set(values)):
        raise AssertionError(f"{relative_path}: duplicate RC IDs")
    return set(values)


def main() -> None:
    master = load_master()
    for rc, keyword in KEYWORDS.items():
        if keyword.casefold() not in master[rc].casefold():
            raise AssertionError(
                f"MASTER PDF ownership drift: RC-{rc:04d} no longer contains {keyword!r}: {master[rc]}"
            )

    for path, expected in EXPECTED.items():
        actual = load_requirements(path)
        if actual != expected:
            raise AssertionError(
                f"{path}: semantic RC ownership mismatch; "
                f"missing={sorted(expected - actual)} extra={sorted(actual - expected)}"
            )

    print("OK: local PDF renderer evidence is bound exactly to RC-0950/0951/0953")


if __name__ == "__main__":
    main()
