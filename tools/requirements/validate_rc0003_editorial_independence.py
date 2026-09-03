#!/usr/bin/env python3
"""Fail-closed RC-0003 editorial-independence contract.

RC-0003 requires Turkish and English content to be prepared independently rather
than by an automatic TR -> EN translation pipeline. This validator proves the
repository-level invariants that can be mechanically verified:

* both language catalogs exist independently and cover the same daily dates;
* every row declares its own locale and contains non-empty native copy;
* paired TR/EN title, teaser and full_text are never identical after normalization;
* the two physical catalogs have distinct content digests;
* repository automation does not contain a known machine-translation dependency
  or a script that reads the Turkish daily-message catalog and writes the English
  catalog.

Human editorial quality/naturalness remains a separate review concern (RC-0004).
"""
from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG_ROOT = ROOT / "assets" / "content" / "daily_messages"
LANGS = ("tr", "en")
FIELDS = ("title", "teaser", "full_text")
EXPECTED_START = "2026-01-01"
EXPECTED_END = "2036-12-31"
EXPECTED_COUNT = 4018

# Dependencies/APIs whose presence in repo automation would be direct evidence of
# an automatic translation pipeline. Generic UI words such as `translate` are
# intentionally not banned.
FORBIDDEN_AUTOMATION_TOKENS = (
    "googletrans",
    "deep_translator",
    "google.cloud.translate",
    "translationserviceclient",
    "deepl.translator",
    "microsofttranslator",
    "azure.ai.translation",
)


def fail(message: str) -> None:
    raise SystemExit(f"RC-0003 FAIL: {message}")


def normalize(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip()).casefold()


def monthly_files(lang: str) -> list[Path]:
    directory = CATALOG_ROOT / lang
    if not directory.is_dir():
        fail(f"missing language catalog directory: {directory.relative_to(ROOT)}")
    files = sorted(p for p in directory.glob("????-??.csv") if p.is_file())
    if not files:
        fail(f"no monthly CSV files for {lang}")
    return files


def load(lang: str) -> tuple[dict[str, dict[str, str]], str]:
    rows: dict[str, dict[str, str]] = {}
    digest = hashlib.sha256()
    for path in monthly_files(lang):
        raw = path.read_bytes()
        digest.update(path.name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(raw)
        with path.open("r", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            required = {"date", "locale", "title", "teaser", "full_text", "theme_tag"}
            if reader.fieldnames is None or not required.issubset(reader.fieldnames):
                fail(f"invalid CSV schema: {path.relative_to(ROOT)}")
            for row in reader:
                date = (row.get("date") or "").strip()
                if not date:
                    fail(f"blank date in {path.relative_to(ROOT)}")
                if date in rows:
                    fail(f"duplicate {lang} date across monthly catalog: {date}")
                if (row.get("locale") or "").strip() != lang:
                    fail(f"wrong locale for {date}: expected {lang}")
                for field in FIELDS:
                    if not normalize(row.get(field) or ""):
                        fail(f"blank {field} for {lang} {date}")
                rows[date] = row
    return rows, digest.hexdigest()


def validate_automation() -> None:
    roots = [ROOT / "tools", ROOT / "scripts", ROOT / ".github" / "workflows"]
    text_suffixes = {".py", ".sh", ".dart", ".js", ".ts", ".yml", ".yaml"}
    for base in roots:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in text_suffixes:
                continue
            text = path.read_text(encoding="utf-8", errors="ignore").casefold()
            # This validator itself names forbidden tokens; skip self-reference.
            if path.resolve() == Path(__file__).resolve():
                continue
            for token in FORBIDDEN_AUTOMATION_TOKENS:
                if token in text:
                    fail(f"machine-translation dependency/API token '{token}' in {path.relative_to(ROOT)}")
            # Reject an explicit TR-source -> EN-destination daily-message pipeline.
            compact = re.sub(r"\s+", "", text)
            tr_markers = ("daily_messages/tr", "daily_messages\\tr")
            en_markers = ("daily_messages/en", "daily_messages\\en")
            if any(marker in compact for marker in tr_markers) and any(marker in compact for marker in en_markers):
                translation_words = ("translat", "çevir", "cevir")
                if any(word in compact for word in translation_words):
                    fail(f"possible automatic TR->EN daily-message translation pipeline: {path.relative_to(ROOT)}")


def main() -> int:
    catalogs: dict[str, dict[str, dict[str, str]]] = {}
    digests: dict[str, str] = {}
    for lang in LANGS:
        catalogs[lang], digests[lang] = load(lang)

    tr_dates = set(catalogs["tr"])
    en_dates = set(catalogs["en"])
    if tr_dates != en_dates:
        missing_en = sorted(tr_dates - en_dates)[:5]
        missing_tr = sorted(en_dates - tr_dates)[:5]
        fail(f"date coverage differs; missing_en={missing_en}, missing_tr={missing_tr}")
    if len(tr_dates) != EXPECTED_COUNT:
        fail(f"expected {EXPECTED_COUNT} dates per language, got {len(tr_dates)}")
    if min(tr_dates) != EXPECTED_START or max(tr_dates) != EXPECTED_END:
        fail(f"unexpected date bounds: {min(tr_dates)}..{max(tr_dates)}")
    if digests["tr"] == digests["en"]:
        fail("TR and EN physical catalog digests are identical")

    identical_fields: list[str] = []
    for date in sorted(tr_dates):
        tr = catalogs["tr"][date]
        en = catalogs["en"][date]
        for field in FIELDS:
            if normalize(tr[field]) == normalize(en[field]):
                identical_fields.append(f"{date}:{field}")
                if len(identical_fields) >= 5:
                    break
        if len(identical_fields) >= 5:
            break
    if identical_fields:
        fail(f"paired TR/EN copy is identical after normalization: {identical_fields}")

    validate_automation()
    print(
        "RC-0003 PASS: independent physical TR/EN catalogs; "
        f"dates={len(tr_dates)} each; bounds={min(tr_dates)}..{max(tr_dates)}; "
        f"tr_sha256={digests['tr']}; en_sha256={digests['en']}; "
        "no known automatic TR->EN translation pipeline detected"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
