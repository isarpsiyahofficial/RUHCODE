#!/usr/bin/env python3
"""Fail-closed RC-0003 editorial-independence contract.

RC-0003 requires Turkish and English content to be prepared independently rather
than by an automatic TR -> EN translation pipeline. This validator proves the
repository-level invariants that can be mechanically verified:

* both language catalogs exist independently and cover the same daily dates;
* every row belongs to its language path and contains non-empty native copy;
* paired TR/EN title, teaser and body are never identical after normalization;
* the two physical catalogs have distinct content digests;
* repository automation does not contain a known machine-translation dependency
  or a script that reads the Turkish daily-message catalog and writes the English
  catalog.

The catalog has two supported historical schemas:
  v1: date,title,teaser,message,theme
  v2: date,locale,title,teaser,full_text,theme_tag
and two shard styles:
  monthly: YYYY-MM.csv
  annual:  YYYY.csv
Monthly shards are primary. Annual shards may fill dates absent from monthly
shards; overlapping rows must normalize to exactly the same canonical record.

Human editorial provenance/quality remains a separate verification concern.
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


def shard_files(lang: str) -> tuple[list[Path], list[Path]]:
    directory = CATALOG_ROOT / lang
    if not directory.is_dir():
        fail(f"missing language catalog directory: {directory.relative_to(ROOT)}")
    monthly = sorted(p for p in directory.glob("????-??.csv") if p.is_file())
    annual = sorted(p for p in directory.glob("????.csv") if p.is_file())
    if not monthly and not annual:
        fail(f"no CSV shards for {lang}")
    return monthly, annual


def normalize_row(row: dict[str, str], lang: str, path: Path) -> dict[str, str]:
    fieldnames = set(row)
    v2 = {"date", "locale", "title", "teaser", "full_text", "theme_tag"}
    v1 = {"date", "title", "teaser", "message", "theme"}
    if v2.issubset(fieldnames):
        locale = (row.get("locale") or "").strip()
        if locale != lang:
            fail(f"wrong locale in {path.relative_to(ROOT)}: expected {lang}, got {locale!r}")
        full_text = row.get("full_text") or ""
        theme_tag = row.get("theme_tag") or ""
    elif v1.issubset(fieldnames):
        full_text = row.get("message") or ""
        theme_tag = row.get("theme") or ""
    else:
        fail(f"invalid CSV schema: {path.relative_to(ROOT)}")

    normalized = {
        "date": (row.get("date") or "").strip(),
        "locale": lang,
        "title": row.get("title") or "",
        "teaser": row.get("teaser") or "",
        "full_text": full_text,
        "theme_tag": theme_tag,
    }
    if not normalized["date"]:
        fail(f"blank date in {path.relative_to(ROOT)}")
    for field in FIELDS:
        if not normalize(normalized[field]):
            fail(f"blank {field} for {lang} {normalized['date']}")
    if not normalize(normalized["theme_tag"]):
        fail(f"blank theme for {lang} {normalized['date']}")
    return normalized


def canonical_record(row: dict[str, str]) -> tuple[str, ...]:
    return tuple(normalize(row[key]) for key in ("locale", "title", "teaser", "full_text", "theme_tag"))


def load_shard(path: Path, lang: str) -> list[dict[str, str]]:
    result: list[dict[str, str]] = []
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames is None:
            fail(f"missing CSV header: {path.relative_to(ROOT)}")
        seen_here: set[str] = set()
        for raw_row in reader:
            row = normalize_row(raw_row, lang, path)
            date = row["date"]
            if date in seen_here:
                fail(f"duplicate {lang} date inside {path.relative_to(ROOT)}: {date}")
            seen_here.add(date)
            result.append(row)
    return result


def load(lang: str) -> tuple[dict[str, dict[str, str]], str, int, int]:
    rows: dict[str, dict[str, str]] = {}
    origins: dict[str, Path] = {}
    digest = hashlib.sha256()
    monthly, annual = shard_files(lang)

    for path in [*monthly, *annual]:
        raw = path.read_bytes()
        digest.update(path.name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(raw)

    # Monthly shards are authoritative when both shard styles contain a date.
    for path in monthly:
        for row in load_shard(path, lang):
            date = row["date"]
            if date in rows:
                fail(f"duplicate {lang} date across monthly shards: {date}")
            rows[date] = row
            origins[date] = path

    annual_fill_count = 0
    annual_overlap_count = 0
    for path in annual:
        for row in load_shard(path, lang):
            date = row["date"]
            if date not in rows:
                rows[date] = row
                origins[date] = path
                annual_fill_count += 1
                continue
            annual_overlap_count += 1
            if canonical_record(rows[date]) != canonical_record(row):
                fail(
                    "conflicting monthly/annual duplicate for "
                    f"{lang} {date}: {origins[date].relative_to(ROOT)} vs {path.relative_to(ROOT)}"
                )

    return rows, digest.hexdigest(), annual_fill_count, annual_overlap_count


def validate_automation() -> None:
    roots = [ROOT / "tools", ROOT / "scripts", ROOT / ".github" / "workflows"]
    text_suffixes = {".py", ".sh", ".dart", ".js", ".ts", ".yml", ".yaml"}
    for base in roots:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in text_suffixes:
                continue
            if path.resolve() == Path(__file__).resolve():
                continue
            text = path.read_text(encoding="utf-8", errors="ignore").casefold()
            for token in FORBIDDEN_AUTOMATION_TOKENS:
                if token in text:
                    fail(f"machine-translation dependency/API token '{token}' in {path.relative_to(ROOT)}")
            compact = re.sub(r"\s+", "", text)
            tr_markers = ("daily_messages/tr", "daily_messages\\tr")
            en_markers = ("daily_messages/en", "daily_messages\\en")
            if any(marker in compact for marker in tr_markers) and any(marker in compact for marker in en_markers):
                if any(word in compact for word in ("translat", "çevir", "cevir")):
                    fail(f"possible automatic TR->EN daily-message translation pipeline: {path.relative_to(ROOT)}")


def main() -> int:
    catalogs: dict[str, dict[str, dict[str, str]]] = {}
    digests: dict[str, str] = {}
    fill_counts: dict[str, int] = {}
    overlap_counts: dict[str, int] = {}
    for lang in LANGS:
        catalogs[lang], digests[lang], fill_counts[lang], overlap_counts[lang] = load(lang)

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
        f"annual_fill_tr={fill_counts['tr']}; annual_fill_en={fill_counts['en']}; "
        f"annual_overlap_tr={overlap_counts['tr']}; annual_overlap_en={overlap_counts['en']}; "
        f"tr_sha256={digests['tr']}; en_sha256={digests['en']}; "
        "legacy+current schemas and monthly+annual shards normalized; "
        "no known automatic TR->EN translation pipeline detected"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
