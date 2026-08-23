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
    "evidence/pdf/report_planning_contract.json": {
        862, 863, 868, 878, 881, 898, 903, 918, 919, 931, 951, 964
    },
    "evidence/pdf/preflight_preview_contract.json": {929, 1440, 1441},
    "evidence/pdf/professional_application_service.json": {
        918, 936, 939, 940, 950, 951, 953, 964, 1085, 1086, 1088, 1089
    },
    "evidence/pdf/numerology_data_adapter.json": {925},
    "evidence/pdf/persisted_pythagorean_pdf.json": {925, 964},
}

KEYWORDS = {
    862: "tamamen cihaz üzerinde",
    863: "sunucumuza veri gönderilmeyecek",
    868: "ekran görüntülerini PDF’e yapıştırmaktan",
    878: "A4/Letter",
    881: "güvenli kenar boşlukları",
    898: "Kapak sayfası",
    903: "Kombine danışmanlık raporu",
    918: "rapor bölümlerini açıp kapatabilecek",
    919: "bölüm sırası değiştirilebilecek",
    925: "Numeroloji sonuçları bölümü",
    929: "PDF oluşturulmadan önce önizleme",
    931: "içerik yoksa boş bölüm",
    936: "paylaşım menüsünden PDF",
    939: "cihazın dosyalar alanına",
    940: "paylaşım işlemleri bizim sunucumuzdan geçmeyecek",
    950: "yarım dosya başarılı rapor",
    951: "PDF doğrulama testi",
    953: "Sayfa sayısının sıfır olmadığı",
    964: "Yanlış müşteri verisinin başka raporda",
    1085: "merkezi bir entitlement sistemi",
    1086: "tek bir Feature ID",
    1088: "UI kilidi Feature ID’ye",
    1089: "Hesaplama servisi Feature ID’ye",
    1440: "dokunulabilir öğenin",
    1441: "Accessibility zorunlu",
}

FORBIDDEN_OWNERSHIP = {
    "evidence/pdf/report_planning_contract.json": {865, 929, 956},
    "evidence/pdf/professional_application_service.json": {952},
    "evidence/pdf/numerology_data_adapter.json": {875, 903, 954},
    "evidence/pdf/persisted_pythagorean_pdf.json": {875},
}


def load_master() -> dict[int, str]:
    text = MASTER.read_text(encoding="utf-8") + "\n" + ADDENDUM.read_text(encoding="utf-8")
    items = {int(number): body.strip() for number, body in RC_RE.findall(text)}
    if set(items) != set(range(1, 1443)):
        raise AssertionError("MASTER sequence is not exactly RC-0001..RC-1442")
    return items


def load_requirements(relative_path: str) -> set[int]:
    payload = json.loads((ROOT / relative_path).read_text(encoding="utf-8"))
    raw_a = payload.get("requirements")
    raw_b = payload.get("requirement_ids")
    if raw_a is not None and raw_b is not None and raw_a != raw_b:
        raise AssertionError(f"{relative_path}: requirements and requirement_ids disagree")
    raw = raw_a if raw_a is not None else raw_b
    if not isinstance(raw, list) or not raw:
        raise AssertionError(f"{relative_path}: requirements[] or requirement_ids[] is required")
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
    needed_rcs = set().union(*EXPECTED.values())
    for rc in sorted(needed_rcs):
        keyword = KEYWORDS.get(rc)
        if keyword is None:
            continue
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
        forbidden = FORBIDDEN_OWNERSHIP.get(path, set())
        leaked = actual & forbidden
        if leaked:
            raise AssertionError(f"{path}: unresolved PDF requirements must remain open: {sorted(leaked)}")

    print(
        "OK: PDF renderer/planning/preflight/application/numerology evidence is bound to exact MASTER ownership; "
        "unproven Unicode/open/visual/table requirements remain explicitly open"
    )


if __name__ == "__main__":
    main()
