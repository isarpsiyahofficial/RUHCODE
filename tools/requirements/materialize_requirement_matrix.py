#!/usr/bin/env python3
"""Materialize the binding RC-0001..RC-1442 traceability matrix.

The binding specification remains the source of truth. This tool makes each RC
machine-traceable without auto-promoting implementation state. Existing evidence
and lifecycle state are preserved only when safe; legacy OPEN rows become
NOT_STARTED and legacy BLOCKED is represented through the separate blocker
columns rather than by weakening the lifecycle model required by MASTER TODO.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import io
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MATRIX = ROOT / "requirements" / "requirement_state.csv"
SPECS = (
    (ROOT / "RUH_CODE_MASTER_SARTNAME.md", 1, 1420),
    (ROOT / "RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md", 1421, 1442),
)
NUMBERED = re.compile(r"(?m)^(\d+)\.\s+(.+?)\s*$")
COLUMNS = [
    "rc_id",
    "status",
    "task_ids",
    "tags",
    "evidence_type",
    "evidence_required",
    "evidence_links",
    "blocked",
    "blocker",
    "source_spec",
    "source_number",
    "source_text_sha256",
    "notes",
]
LIFECYCLE = {"NOT_STARTED", "IMPLEMENTED", "TESTED", "VERIFIED", "DONE"}

TAG_RULES: tuple[tuple[str, tuple[str, ...]], ...] = (
    ("CALC", ("hesap", "calculate", "calculation", "ephemer", "astrolo", "numerolo", "zodyak", "zodiac", "gezegen", "planet", "doğum haritas", "chart", "house", "ev sistemi", "orb", "ayanamsha", "nakshatra", "dasha", "bazi", "panchanga", "sunrise", "sunset", "timezone", "saat dilimi", "koordinat")),
    ("CONTENT", ("yorum", "interpret", "içerik", "content", "metin", "açıklama", "mesaj", "rehber", "meaning", "anlam", "katalog")),
    ("UI", ("ekran", "screen", "ui", "ux", "buton", "button", "kart", "card", "navig", "route", "ikon", "icon", "tema", "theme", "layout", "dialog", "modal", "onboarding", "splash")),
    ("I18N", ("türkçe", "ingilizce", "tr/en", "tr-en", "dil", "language", "locale", "çeviri", "translation", "i18n")),
    ("OFFLINE", ("offline", "internetsiz", "internet olmadan", "ağ olmadan", "network")),
    ("ENTITLEMENT", ("free", "pro", "premium", "reklam", "ad ", "ads", "ödüllü", "rewarded", "satın", "purchase", "entitlement", "paywall")),
    ("BACKUP", ("backup", "yedek", "restore", "geri yük", "csv", "export", "import")),
    ("PDF", ("pdf", "rapor", "report")),
    ("SECURITY", ("security", "güvenlik", "şifre", "password", "encrypt", "hash", "sha", "tamper", "secret", "privacy", "gizlilik", "izin", "permission")),
    ("A11Y", ("accessibility", "erişilebilir", "talkback", "semantics", "screen reader", "kontrast", "contrast", "touch target")),
    ("PERF", ("performance", "performans", "latency", "gecikme", "memory", "bellek", "startup", "açılış süresi", "fps", "jank")),
    ("RELEASE", ("release", "apk", "aab", "build", "derle", "sign", "imza", "ci", "clean checkout", "artifact", "play store", "version")),
)

EVIDENCE_BY_TAG = {
    "CALC": "GOLDEN_OR_CONTRACT_TEST",
    "CONTENT": "CONTENT_REVIEW",
    "UI": "UI_REFERENCE_OR_WIDGET_TEST",
    "I18N": "I18N_TEST",
    "OFFLINE": "OFFLINE_TEST",
    "ENTITLEMENT": "ENTITLEMENT_TEST",
    "BACKUP": "BACKUP_ROUNDTRIP_TEST",
    "PDF": "PDF_OUTPUT_TEST",
    "SECURITY": "SECURITY_TEST",
    "A11Y": "ACCESSIBILITY_TEST",
    "PERF": "PERFORMANCE_TEST",
    "RELEASE": "RELEASE_ARTIFACT_EVIDENCE",
}


def normalize_text(text: str) -> str:
    return " ".join(text.strip().split())


def parse_specs() -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for path, first, last in SPECS:
        text = path.read_text(encoding="utf-8")
        matches = [(int(m.group(1)), normalize_text(m.group(2))) for m in NUMBERED.finditer(text)]
        expected = list(range(first, last + 1))
        actual = [n for n, _ in matches]
        if actual != expected:
            raise SystemExit(f"MATERIALIZE_FAIL: {path.name} numbering is not exact {first}..{last}")
        for number, requirement in matches:
            rows.append({
                "rc_id": f"RC-{number:04d}",
                "source_spec": path.name,
                "source_number": str(number),
                "source_text_sha256": hashlib.sha256(requirement.encode("utf-8")).hexdigest(),
                "requirement_text": requirement,
            })
    if len(rows) != 1442:
        raise SystemExit(f"MATERIALIZE_FAIL: expected 1442 requirements, got {len(rows)}")
    return rows


def read_existing() -> dict[str, dict[str, str]]:
    if not MATRIX.exists():
        return {}
    with MATRIX.open("r", encoding="utf-8", newline="") as handle:
        return {row.get("rc_id", "").strip(): row for row in csv.DictReader(handle)}


def infer_tags(text: str) -> list[str]:
    lowered = text.casefold()
    tags = [tag for tag, needles in TAG_RULES if any(needle in lowered for needle in needles)]
    return tags or ["TRACE"]


def evidence_type(tags: list[str]) -> str:
    values = [EVIDENCE_BY_TAG[tag] for tag in tags if tag in EVIDENCE_BY_TAG]
    return "|".join(dict.fromkeys(values)) if values else "CONTRACT_TEST_OR_REVIEW"


def migrate_status(old: dict[str, str]) -> tuple[str, str, str]:
    raw = old.get("status", "").strip()
    blocked = old.get("blocked", "").strip().upper()
    blocker = old.get("blocker", "").strip()
    if raw in LIFECYCLE:
        return raw, (blocked if blocked in {"YES", "NO"} else "NO"), blocker
    if raw == "OPEN" or not raw:
        return "NOT_STARTED", "NO", blocker
    if raw == "IN_PROGRESS":
        return "IMPLEMENTED", "NO", blocker
    if raw == "BLOCKED":
        return "NOT_STARTED", "YES", blocker or old.get("notes", "").strip()
    if raw == "DONE":
        # Preserve DONE only when evidence already exists. Otherwise fail closed.
        if old.get("evidence_links", "").strip():
            return "DONE", (blocked if blocked in {"YES", "NO"} else "NO"), blocker
        return "NOT_STARTED", "NO", ""
    return "NOT_STARTED", "NO", blocker


def materialize() -> str:
    specs = parse_specs()
    existing = read_existing()
    out = io.StringIO(newline="")
    writer = csv.DictWriter(out, fieldnames=COLUMNS, lineterminator="\n")
    writer.writeheader()
    for spec in specs:
        rc_id = spec["rc_id"]
        old = existing.get(rc_id, {})
        status, blocked, blocker = migrate_status(old)
        tags = infer_tags(spec["requirement_text"])
        old_task_ids = old.get("task_ids", "").strip()
        writer.writerow({
            "rc_id": rc_id,
            "status": status,
            "task_ids": old_task_ids or f"TASK-{rc_id}",
            "tags": "|".join(tags),
            "evidence_type": old.get("evidence_type", "").strip() or evidence_type(tags),
            "evidence_required": "YES",
            "evidence_links": old.get("evidence_links", "").strip(),
            "blocked": blocked,
            "blocker": blocker,
            "source_spec": spec["source_spec"],
            "source_number": spec["source_number"],
            "source_text_sha256": spec["source_text_sha256"],
            "notes": old.get("notes", "").strip(),
        })
    return out.getvalue()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail if the committed matrix is not canonical")
    args = parser.parse_args()
    canonical = materialize()
    current = MATRIX.read_text(encoding="utf-8") if MATRIX.exists() else ""
    if args.check:
        if current != canonical:
            raise SystemExit("MATERIALIZE_CHECK_FAIL: requirements/requirement_state.csv is not canonical; run materializer")
        print("MATERIALIZE_CHECK_OK total=1442")
        return 0
    MATRIX.parent.mkdir(parents=True, exist_ok=True)
    MATRIX.write_text(canonical, encoding="utf-8", newline="")
    print("MATERIALIZE_OK total=1442")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
