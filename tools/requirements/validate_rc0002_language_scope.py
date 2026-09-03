#!/usr/bin/env python3
"""RC-0002 contract: the production app supports Turkish and English only."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "lib" / "src" / "app" / "ruh_code_app.dart"
EXPECTED = ("tr", "en")


def fail(message: str) -> None:
    raise SystemExit(f"RC0002_LANGUAGE_SCOPE_FAIL: {message}")


def main() -> int:
    if not APP.is_file():
        fail("production RuhCodeApp source is missing")
    text = APP.read_text(encoding="utf-8")

    match = re.search(
        r"supportedLocales\s*:\s*const\s*<Locale>\s*\[(.*?)\]",
        text,
        flags=re.DOTALL,
    )
    if not match:
        fail("MaterialApp supportedLocales contract is missing or not compile-time explicit")

    locale_block = match.group(1)
    locales = tuple(re.findall(r"Locale\(\s*['\"]([A-Za-z_-]+)['\"]\s*\)", locale_block))
    if locales != EXPECTED:
        fail(f"supportedLocales must be exactly {EXPECTED!r} in that order; found {locales!r}")

    # Reject unsupported app-level Locale declarations outside the explicit
    # supportedLocales list. This catches a third production locale being wired
    # elsewhere in RuhCodeApp while allowing framework delegate declarations.
    all_locales = tuple(re.findall(r"Locale\(\s*['\"]([A-Za-z_-]+)['\"]\s*\)", text))
    unexpected = sorted({locale for locale in all_locales if locale not in EXPECTED})
    if unexpected:
        fail(f"unexpected production locale declarations: {unexpected}")

    required_delegates = (
        "GlobalMaterialLocalizations.delegate",
        "GlobalWidgetsLocalizations.delegate",
        "GlobalCupertinoLocalizations.delegate",
    )
    missing = [delegate for delegate in required_delegates if delegate not in text]
    if missing:
        fail(f"missing Flutter localization delegates: {missing}")

    print("RC0002_LANGUAGE_SCOPE_OK supported=tr,en other_locales=0 delegates=3")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
