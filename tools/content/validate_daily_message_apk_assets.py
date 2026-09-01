#!/usr/bin/env python3
"""Validate packaged Daily Message assets inside a built Flutter APK.

This is a release-evidence gate for RC-1424/1425/1426/1427/1433/1434. It
inspects the APK ZIP itself rather than trusting pubspec/source declarations.
Both repository shard schemas are normalized explicitly; no guessed schema,
runtime generation, locale fallback, or random date fallback is accepted.
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import re
import zipfile
from collections import Counter
from datetime import date, timedelta
from pathlib import Path

ASSET_PREFIX = "assets/flutter_assets/assets/content/daily_messages"
LOCALES = ("tr", "en")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
EXPECTED_START = date(2026, 1, 1)
EXPECTED_END = date(2036, 12, 31)
CANONICAL = ("date", "locale", "title", "teaser", "full_text", "theme_tag")
LEGACY = ("date", "title", "teaser", "message", "theme")


def iter_days(start: date, end: date):
    current = start
    while current <= end:
        yield current.isoformat()
        current += timedelta(days=1)


def parse_rows(raw: bytes, asset_name: str, path_locale: str):
    text = raw.decode("utf-8-sig")
    reader = csv.DictReader(io.StringIO(text))
    if reader.fieldnames is None:
        raise ValueError(f"{asset_name}: missing CSV header")
    header = tuple(name.strip().lower() for name in reader.fieldnames)
    if header == CANONICAL:
        schema = "canonical"
    elif header == LEGACY:
        schema = "legacy"
    else:
        raise ValueError(f"{asset_name}: unsupported Daily Message CSV header {header!r}")

    for line_number, row in enumerate(reader, start=2):
        day = (row.get("date") or "").strip()
        if not day and all(not (value or "").strip() for value in row.values()):
            continue
        if schema == "canonical":
            row_locale = (row.get("locale") or "").strip().lower()
            title = (row.get("title") or "").strip()
            teaser = (row.get("teaser") or "").strip()
            full_text = (row.get("full_text") or "").strip()
            theme = (row.get("theme_tag") or "").strip()
        else:
            row_locale = path_locale
            title = (row.get("title") or "").strip()
            teaser = (row.get("teaser") or "").strip()
            full_text = (row.get("message") or "").strip()
            theme = (row.get("theme") or "").strip()

        empty_fields = [
            name
            for name, value in (
                ("date", day),
                ("locale", row_locale),
                ("title", title),
                ("teaser", teaser),
                ("full_text", full_text),
                ("theme_tag", theme),
            )
            if not value
        ]
        if empty_fields:
            raise ValueError(
                f"{asset_name}:{line_number}: empty required Daily Message fields {empty_fields}"
            )
        yield line_number, day, row_locale, schema


def validate(apk: Path) -> dict:
    if not apk.is_file():
        raise FileNotFoundError(apk)

    expected_days = set(iter_days(EXPECTED_START, EXPECTED_END))
    seen = Counter()
    shard_counts = Counter()
    schema_counts = Counter()
    errors: list[str] = []

    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        csv_assets = [
            name for name in names
            if name.startswith(f"{ASSET_PREFIX}/") and name.endswith(".csv")
        ]
        for locale in LOCALES:
            locale_prefix = f"{ASSET_PREFIX}/{locale}/"
            if not any(name.startswith(locale_prefix) for name in csv_assets):
                errors.append(f"APK contains no packaged {locale.upper()} Daily Message CSV assets")

        for name in sorted(csv_assets):
            parts = name.split("/")
            try:
                path_locale = parts[parts.index("daily_messages") + 1].lower()
            except (ValueError, IndexError):
                errors.append(f"unparseable Daily Message asset path: {name}")
                continue
            if path_locale not in LOCALES:
                errors.append(f"unexpected locale directory {path_locale!r}: {name}")
                continue
            shard_counts[path_locale] += 1
            try:
                raw = archive.read(name)
                for line_number, day, row_locale, schema in parse_rows(raw, name, path_locale):
                    schema_counts[f"{path_locale}:{schema}"] += 1
                    if not DATE_RE.match(day):
                        errors.append(f"{name}:{line_number}: invalid date key {day!r}")
                        continue
                    try:
                        parsed_day = date.fromisoformat(day)
                    except ValueError:
                        errors.append(f"{name}:{line_number}: impossible date {day!r}")
                        continue
                    if row_locale != path_locale:
                        errors.append(
                            f"{name}:{line_number}: locale {row_locale!r} does not match path locale {path_locale!r}"
                        )
                    if EXPECTED_START <= parsed_day <= EXPECTED_END:
                        seen[(day, row_locale)] += 1
            except (UnicodeDecodeError, csv.Error, ValueError) as exc:
                errors.append(str(exc))

    missing = []
    duplicates = []
    for day in sorted(expected_days):
        for locale in LOCALES:
            count = seen[(day, locale)]
            if count == 0:
                missing.append(f"{day}|{locale}")
            elif count > 1:
                duplicates.append(f"{day}|{locale}={count}")

    counts = {locale: sum(seen[(day, locale)] for day in expected_days) for locale in LOCALES}
    if missing:
        errors.append(f"missing exact date/locale records: {len(missing)}; first={missing[:10]}")
    if duplicates:
        errors.append(f"duplicate exact date/locale records: {len(duplicates)}; first={duplicates[:10]}")
    for locale in LOCALES:
        if counts[locale] != 4018:
            errors.append(f"{locale.upper()} packaged exact-range count is {counts[locale]}, expected 4018")

    return {
        "ok": not errors,
        "apk": str(apk),
        "asset_prefix": ASSET_PREFIX,
        "range": {"start": EXPECTED_START.isoformat(), "end": EXPECTED_END.isoformat()},
        "expected_per_locale": 4018,
        "counts": counts,
        "shards": dict(shard_counts),
        "schema_row_counts": dict(schema_counts),
        "missing_count": len(missing),
        "duplicate_count": len(duplicates),
        "errors": errors,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("apk", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    report = validate(args.apk)
    rendered = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True)
    print(rendered)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(rendered + "\n", encoding="utf-8")
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
