#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
MASTER_ADDENDUM = ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md"

RC_RE = re.compile(r"^(\d+)\.\s+(.+)$", re.MULTILINE)


def load_master():
    text = MASTER.read_text(encoding="utf-8") + "\n" + MASTER_ADDENDUM.read_text(encoding="utf-8")
    items = {int(n): body.strip() for n, body in RC_RE.findall(text)}
    expected = set(range(1, 1443))
    missing = sorted(expected - set(items))
    if missing:
        raise AssertionError(f"MASTER requirement IDs missing: {missing[:20]}")
    return items


def load_requirements(path):
    payload = json.loads((ROOT / path).read_text(encoding="utf-8"))
    reqs = payload.get("requirements")
    if reqs is None:
        reqs = payload.get("requirement_ids")
    if not isinstance(reqs, list) or not reqs:
        raise AssertionError(
            f"{path}: non-empty requirements[] or requirement_ids[] is required"
        )
    parsed = []
    for rc in reqs:
        if not isinstance(rc, str) or not re.fullmatch(r"RC-\d{4}", rc):
            raise AssertionError(f"{path}: invalid requirement token {rc!r}")
        parsed.append(int(rc[3:]))
    if len(parsed) != len(set(parsed)):
        raise AssertionError(f"{path}: duplicate requirement IDs")
    return set(parsed)


EXPECTED = {
    "evidence/astronomy/western_asc_mc.json": {18, 1436},
    "evidence/astronomy/western_aspect_grid.json": {51},
    "evidence/astronomy/western_essential_dignities.json": {49, 50},
    "evidence/astronomy/western_natal_aspects.json": {37, 38, 39, 40, 41, 43, 44, 51},
    "evidence/astronomy/western_natal_distribution.json": {45, 46, 47},
    "evidence/astronomy/western_natal_placements.json": {31, 32, 33, 34, 48},
    "evidence/astronomy/western_placidus_contract.json": {19, 54, 1436},
    "evidence/astronomy/western_porphyry_houses.json": {19, 60, 1436},
    "evidence/numerology/pythagorean_profile.json": {
        161, 162, 165, 166, 167, 168, 169, 170, 171, 174, 182, 183, 329,
    },
    "evidence/numerology/pythagorean_extended_name.json": {172, 173, 175, 182, 183, 329},
    "evidence/numerology/personal_cycles.json": {174, 176, 177, 178, 329, 337, 1436},
    "evidence/numerology/pinnacles_challenges.json": {179, 180, 329},
    "evidence/numerology/compatibility.json": {181, 329},
    "evidence/bazi/sexagenary_cycle.json": {147, 148},
    "evidence/bazi/hidden_stems.json": {149},
    "evidence/bazi/four_pillars_primitives.json": {150, 151, 152},
    "evidence/bazi/ten_gods.json": {153},
    "evidence/content/terminology_glossary.json": {1059, 1060, 1061, 1062, 1063, 1064, 1065},
    "evidence/interpretation/claim_aggregation.json": {1070, 1072, 1077, 1078},
    "evidence/interpretation/quality_guard.json": {
        1066, 1067, 1068, 1069, 1072, 1073, 1074, 1075, 1076,
    },
    "evidence/pdf/local_renderer_contract.json": {950, 951, 953},
    "evidence/pdf/report_planning_contract.json": {
        862, 863, 868, 878, 881, 898, 903, 918, 919, 931, 951, 964,
    },
    "evidence/pdf/numerology_data_adapter.json": {925},
    "evidence/pdf/professional_application_service.json": {
        918, 936, 939, 940, 950, 951, 953, 964, 1085, 1086, 1088, 1089,
    },
    "evidence/backup/csv_contract.json": {
        774, 777, 792, 793, 796, 797, 798, 799, 800, 801, 802, 803, 804,
        805, 806, 807, 809, 810, 811, 812, 814, 815,
    },
    "evidence/backup/schema_registry_contract.json": {
        774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787,
        788, 789, 790, 791, 805, 806, 809, 810, 811, 812, 813, 814, 815, 816, 817,
        828, 829, 830,
    },
    "evidence/backup/full_lifecycle_contract.json": {
        795, 816, 817, 823, 838, 841, 843, 847, 848, 850, 851, 854,
        1296, 1297, 1298, 1299,
    },
    "evidence/entitlements/feature_policy_contract.json": {
        757, 760, 761, 762, 1085, 1086, 1088, 1089, 1090, 1091, 1092, 1093,
        1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1104, 1105, 1107, 1108,
    },
    "evidence/ui/design_token_contrast_contract.json": {1441},
}

KEYWORDS = {
    18: "Yükselen ve MC", 19: "Ev başlangıç dereceleri", 31: "bütün gezegen yerleşimleri",
    32: "hangi burçta", 33: "Gezegen dereceleri", 34: "hangi evlerde", 37: "Kavuşum",
    38: "Karşıt", 39: "Kare", 40: "Üçgen", 41: "Sekstil", 43: "Aspect orb",
    44: "orb ayarlarını", 45: "Element dağılımı", 46: "Ateş, Toprak, Hava ve Su",
    47: "Öncü, Sabit ve Değişken", 48: "Retrograde gezegenler", 49: "Gezegen yöneticilikleri",
    50: "Exaltation", 51: "Aspect grid", 54: "Placidus", 60: "Porphyry",
    147: "Heavenly Stems", 148: "Earthly Branches", 149: "Hidden Stems",
    150: "Five Elements", 151: "Yin/Yang", 152: "Day Master", 153: "Ten Gods",
    161: "Numeroloji", 162: "Pythagorean", 166: "Life Path", 167: "Expression",
    168: "Soul Urge", 169: "Personality", 170: "Birthday", 171: "Maturity",
    172: "Balance", 173: "Karmic Lessons", 174: "Karmic Debt", 175: "Hidden Passion",
    176: "Personal Year", 177: "Personal Month", 178: "Personal Day", 179: "Pinnacle",
    180: "Challenge", 181: "compatibility", 182: "Türkçe karakterler", 183: "normalize",
    329: "Numeroloji motorlarının", 337: "Leap year",
    757: "PRO durumundaki değişiklik", 760: "Free → PRO", 761: "PRO → Free", 762: "tekrar PRO",
    774: "CSV tabanlı", 775: "tek bir düz CSV", 776: "paket halinde", 777: "UTF-8 CSV",
    778: "profiles.csv", 788: "tarot_cards.csv", 789: "favorites.csv", 790: "settings.csv", 791: "ayrı CSV",
    792: "ZIP", 793: "insan tarafından", 795: "tüm Ruh Code verilerini", 796: "UTF-8",
    800: "virgül", 801: "çift tırnak", 802: "yeni satır", 803: "Boş değer ile sıfır",
    804: "null", 805: "locale formatına", 809: "ISO formatında", 812: "çeviri metinleriyle",
    813: "Whole Sign", 815: "Türkçe yedek İngilizce", 816: "İngilizce cihazda",
    817: "Türkçe cihazdan İngilizce", 823: "bozuk backup", 828: "Foreign key",
    829: "ID değerleri", 830: "Tarih formatları", 838: "Birleştir", 841: "rollback",
    843: "iki kere import", 847: "Import sonrası", 848: "temiz kurulum", 850: "Binlerce kayıtla",
    851: "Türkçe karakterlerle", 854: "Emoji",
    862: "cihaz üzerinde", 863: "sunucumuza", 865: "Unicode", 868: "ekran görüntülerini",
    870: "vektörel", 875: "Numeroloji tabloları", 878: "A4/Letter", 881: "kenar boşlukları",
    898: "Kapak sayfası", 903: "Kombine danışmanlık raporu", 918: "bölümlerini açıp kapatabilecek",
    919: "bölüm sırası", 925: "Numeroloji sonuçları", 929: "önizleme", 931: "boş bölüm",
    936: "paylaşım menüsünden PDF", 939: "dosyalar alanına kaydedilebilecek", 940: "sunucumuzdan geçmeyecek",
    950: "yarım dosya", 951: "PDF doğrulama testi", 952: "gerçekten açılabildiği", 953: "Sayfa sayısının sıfır olmadığı",
    954: "Gerekli metinlerin", 956: "görsel regresyon", 964: "Yanlış müşteri verisinin",
    1059: "terminology glossary", 1060: "Ascendant", 1061: "House", 1062: "Vedik terimlerin transliterasyonu",
    1063: "üç farklı Türkçe isim", 1064: "gereksiz şekilde Türkçeleştirilmeyecek", 1065: "teknik terim",
    1066: "Interpretation katalogları versiyonlanacak", 1067: "interpretationVersion",
    1068: "matematik motoru versiyonunu", 1069: "yorum kataloğunun içeriğini sessizce değiştirmeyecek",
    1070: "hangi hesaplama koşullarında", 1072: "Kural eşleştirmeleri", 1073: "placeholder değerleri",
    1074: "{planet}", 1075: "tekrar kontrolü", 1076: "beş kere tekrar",
    1077: "Çelişkili yorumların", 1078: "tek kesin hüküm",
    1085: "erişim matrisi", 1086: "Feature ID", 1088: "UI kilidi", 1089: "Hesaplama servisi",
    1090: "Menü Feature ID", 1091: "bir ekranda kilitli", 1092: "PRO test hesabı",
    1093: "Free test hesabı", 1094: "geçici açılan", 1095: "başlangıç ve bitişi",
    1096: "Telefon saatini geri alarak", 1097: "yüzde yüz kırılamaz", 1098: "sıradan manipülasyonu",
    1099: "satın alma doğrulama", 1100: "restore", 1101: "Satın alma başarısızlığında",
    1104: "Offline durumda PRO", 1105: "İnternet yalnız", 1107: "sonsuz loading", 1108: "Yerel özellikler",
    1296: "Cihazlar arası veri transferi", 1297: "eski telefondan", 1298: "Yeni telefonda",
    1299: "internet sunucumuza", 1436: "doğruluk toleransı", 1441: "Accessibility zorunlu olacak",
}


def main():
    master = load_master()
    for rc, keyword in KEYWORDS.items():
        if keyword.casefold() not in master[rc].casefold():
            raise AssertionError(
                f"MASTER ownership drift: RC-{rc:04d} no longer contains expected keyword {keyword!r}: {master[rc]}"
            )

    for path, expected in EXPECTED.items():
        actual = load_requirements(path)
        if actual != expected:
            missing = sorted(expected - actual)
            extra = sorted(actual - expected)
            raise AssertionError(
                f"{path}: semantic RC ownership mismatch; missing={missing}, extra={extra}"
            )
        for rc in actual:
            if rc not in master:
                raise AssertionError(f"{path}: RC-{rc:04d} is absent from MASTER")

    families = sorted({path.split('/')[1] for path in EXPECTED})
    print(
        f"OK: semantic evidence ownership validated for {len(EXPECTED)} contracts "
        f"across {', '.join(families)}"
    )


if __name__ == "__main__":
    main()
