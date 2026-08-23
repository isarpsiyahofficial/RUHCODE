#!/usr/bin/env python3
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "RUH_CODE_MASTER_SARTNAME.md"
EVIDENCE = ROOT / "evidence/pdf/report_planning_contract.json"

EXPECTED = {
    "RC-0862", "RC-0863", "RC-0868", "RC-0878", "RC-0881", "RC-0898",
    "RC-0918", "RC-0919", "RC-0931", "RC-0951", "RC-0964",
}
MUST_REMAIN_OPEN = {"RC-0865", "RC-0903", "RC-0929", "RC-0956"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


master = MASTER.read_text(encoding="utf-8")
evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))
owned = set(evidence.get("requirements", []))
require(owned == EXPECTED, f"PDF planning evidence ownership drift: {sorted(owned)}")
require(evidence.get("done") is False, "PDF planning evidence cannot be DONE yet")
require(owned.isdisjoint(MUST_REMAIN_OPEN), "PDF planning evidence is claiming a known open requirement")

semantic_checks = {
    862: "PDF rapor sistemi tamamen cihaz üzerinde çalışacak",
    863: "PDF oluşturmak için bizim sunucumuza veri gönderilmeyecek",
    868: "ekran görüntülerini PDF’e yapıştırmaktan ibaret olmayacak",
    878: "A4/Letter benzeri gerçek belge ölçülerine göre layout’u olacak",
    881: "güvenli kenar boşlukları",
    898: "Kapak sayfası profesyonel biçimde oluşturulacak",
    918: "rapor bölümlerini açıp kapatabilecek",
    919: "bölüm sırası değiştirilebilecek",
    931: "içerik yoksa boş bölüm oluşturulmayacak",
    951: "PDF doğrulama testi oluşturulacak",
    964: "Yanlış müşteri verisinin başka raporda çıkması",
}
for number, phrase in semantic_checks.items():
    match = re.search(rf"^{number}\.\s+(.+)$", master, re.MULTILINE)
    require(match is not None, f"RC-{number:04d} missing from MASTER")
    require(phrase in match.group(1), f"RC-{number:04d} semantic text drifted")

# A report-kind enum value is not enough to prove a real multi-system combined
# consultation report. Keep RC-0903 open until multiple persisted calculation
# types are composed and rendered together through a production handler.
combined_match = re.search(r"^903\.\s+(.+)$", master, re.MULTILINE)
require(combined_match is not None, "RC-0903 missing from MASTER")
require(
    "Kombine danışmanlık raporu birden fazla sistemi kapsayabilecek" in combined_match.group(1),
    "RC-0903 semantic text drifted",
)

blockers = "\n".join(evidence.get("releaseBlockers", []))
for rc in MUST_REMAIN_OPEN:
    require(rc in blockers, f"{rc} must be explicitly documented as open")

print("PDF report-planning semantic ownership: OK")
