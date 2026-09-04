#!/usr/bin/env python3
"""Fail-closed machine-checkable RC-0004 terminology/copy-quality contract.

RC-0004 requires natural and professional astrology, numerology and spiritual
terminology in both Turkish and English. Machines cannot honestly prove editorial
naturalness, so this gate deliberately proves only objective prerequisites:

* a versioned canonical bilingual terminology contract exists for all 3 domains;
* concepts and locale terms are complete, unique, Unicode-normalized and usable;
* TR/EN daily-message copy is non-empty UTF-8 text without placeholders,
  replacement characters, known mojibake or control-character leakage;
* content rows do not expose localization/template keys as user-facing prose.

Independent bilingual editorial review remains required for VERIFIED/DONE.
"""
from __future__ import annotations

import csv
import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / "requirements" / "contracts" / "rc0004_terminology_contract.json"
CONTENT_ROOT = ROOT / "assets" / "content" / "daily_messages"
LANGS = ("tr", "en")
EXPECTED_DOMAINS = {"astrology", "numerology", "spirituality"}
MIN_TERMS = 20
KEY_LIKE = re.compile(r"^(?:[a-z][a-z0-9_]*\.){1,}[a-z][a-z0-9_]*$", re.I)
TEMPLATE_TOKEN = re.compile(r"\{\{[^{}]+\}\}|\$\{[^{}]+\}")


def fail(message: str) -> None:
    raise SystemExit(f"RC-0004 FAIL: {message}")


def clean(value: object) -> str:
    return str(value or "").strip()


def load_contract() -> dict:
    if not CONTRACT.is_file():
        fail(f"missing contract: {CONTRACT.relative_to(ROOT)}")
    try:
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        fail(f"invalid UTF-8/JSON terminology contract: {exc}")
    if data.get("schema") != "ruh-code.rc0004-terminology-contract.v1":
        fail("unexpected terminology-contract schema")
    if data.get("requirement") != "RC-0004":
        fail("terminology contract is not bound to RC-0004")
    if data.get("locales") != ["tr", "en"]:
        fail("terminology contract locales must be exactly tr,en")
    if set(data.get("domains") or []) != EXPECTED_DOMAINS:
        fail("terminology contract must explicitly cover astrology, numerology and spirituality")
    terms = data.get("terms")
    if not isinstance(terms, list) or len(terms) < MIN_TERMS:
        fail(f"terminology contract must contain at least {MIN_TERMS} bilingual concepts")

    concepts: set[str] = set()
    pairs: set[tuple[str, str]] = set()
    for index, item in enumerate(terms, 1):
        if not isinstance(item, dict):
            fail(f"term #{index} is not an object")
        concept = clean(item.get("concept"))
        tr = clean(item.get("tr"))
        en = clean(item.get("en"))
        if not concept or not tr or not en:
            fail(f"term #{index} has a blank concept/TR/EN value")
        if concept in concepts:
            fail(f"duplicate terminology concept: {concept}")
        concepts.add(concept)
        pair = (tr.casefold(), en.casefold())
        if pair in pairs:
            fail(f"duplicate bilingual terminology pair: {tr!r} / {en!r}")
        pairs.add(pair)
        for locale, value in (("tr", tr), ("en", en)):
            if unicodedata.normalize("NFC", value) != value:
                fail(f"non-NFC {locale} terminology for {concept}: {value!r}")
            if any(ord(ch) < 32 and ch not in "\t\n\r" for ch in value):
                fail(f"control character in {locale} terminology for {concept}")
    if not clean(data.get("verification_boundary")):
        fail("contract must state its human-review verification boundary")
    return data


def user_fields(row: dict[str, str], path: Path) -> list[tuple[str, str]]:
    fields = set(row)
    if {"date", "locale", "title", "teaser", "full_text", "theme_tag"}.issubset(fields):
        return [("title", row.get("title") or ""), ("teaser", row.get("teaser") or ""), ("body", row.get("full_text") or "")]
    if {"date", "title", "teaser", "message", "theme"}.issubset(fields):
        return [("title", row.get("title") or ""), ("teaser", row.get("teaser") or ""), ("body", row.get("message") or "")]
    fail(f"unsupported daily-message schema: {path.relative_to(ROOT)}")
    return []


def validate_copy(contract: dict) -> tuple[int, int]:
    placeholders = tuple(clean(x).casefold() for x in contract.get("forbidden_placeholders") or [] if clean(x))
    mojibake = tuple(clean(x) for x in contract.get("forbidden_mojibake_fragments") or [] if clean(x))
    if not placeholders or not mojibake:
        fail("forbidden placeholder/mojibake lists must not be empty")

    files_checked = 0
    rows_checked = 0
    for lang in LANGS:
        directory = CONTENT_ROOT / lang
        if not directory.is_dir():
            fail(f"missing {lang} content directory")
        files = sorted(directory.glob("*.csv"))
        if not files:
            fail(f"no {lang} content shards")
        for path in files:
            files_checked += 1
            try:
                with path.open("r", encoding="utf-8", newline="") as handle:
                    reader = csv.DictReader(handle)
                    if reader.fieldnames is None:
                        fail(f"missing CSV header: {path.relative_to(ROOT)}")
                    for line_no, row in enumerate(reader, 2):
                        rows_checked += 1
                        if "locale" in row and clean(row.get("locale")) != lang:
                            fail(f"wrong locale at {path.relative_to(ROOT)}:{line_no}")
                        for field, raw in user_fields(row, path):
                            value = clean(raw)
                            if not value:
                                fail(f"blank {field} at {path.relative_to(ROOT)}:{line_no}")
                            if unicodedata.normalize("NFC", value) != value:
                                fail(f"non-NFC {field} at {path.relative_to(ROOT)}:{line_no}")
                            folded = value.casefold()
                            for token in placeholders:
                                if token in folded:
                                    fail(f"placeholder {token!r} in {field} at {path.relative_to(ROOT)}:{line_no}")
                            for fragment in mojibake:
                                if fragment in value:
                                    fail(f"mojibake {fragment!r} in {field} at {path.relative_to(ROOT)}:{line_no}")
                            if any((ord(ch) < 32 and ch not in "\t\n\r") or ord(ch) == 127 for ch in value):
                                fail(f"control character in {field} at {path.relative_to(ROOT)}:{line_no}")
                            if TEMPLATE_TOKEN.search(value):
                                fail(f"unresolved template token in {field} at {path.relative_to(ROOT)}:{line_no}")
                            if KEY_LIKE.fullmatch(value):
                                fail(f"localization-key-like user copy in {field} at {path.relative_to(ROOT)}:{line_no}")
            except UnicodeDecodeError as exc:
                fail(f"invalid UTF-8 in {path.relative_to(ROOT)}: {exc}")
    return files_checked, rows_checked


def main() -> int:
    contract = load_contract()
    files_checked, rows_checked = validate_copy(contract)
    print(
        "RC-0004 MACHINE CONTRACT PASS: "
        f"terms={len(contract['terms'])}; domains=3; locales=tr,en; "
        f"content_files={files_checked}; rows={rows_checked}; UTF-8/NFC/copy hygiene clean. "
        "Human bilingual editorial review is still required for VERIFIED/DONE."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
