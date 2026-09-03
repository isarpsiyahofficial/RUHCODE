#!/usr/bin/env python3
"""RC-0002 contract: the production app supports Turkish and English only."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "lib" / "src" / "app" / "ruh_code_app.dart"
PUBSPEC = ROOT / "pubspec.yaml"
EXPECTED = ("tr", "en")


def fail(message: str) -> None:
    raise SystemExit(f"RC0002_LANGUAGE_SCOPE_FAIL: {message}")


def main() -> int:
    if not APP.is_file():
        fail("production RuhCodeApp source is missing")
    text = APP.read_text(encoding="utf-8")

    match = re.search(
        r"static\s+const\s+supportedLocales\s*=\s*<Locale>\s*\[(.*?)\];",
        text,
        flags=re.DOTALL,
    )
    if not match:
        fail("canonical compile-time supportedLocales contract is missing")

    locale_block = match.group(1)
    locales = tuple(re.findall(r"Locale\(\s*['\"]([A-Za-z_-]+)['\"]\s*\)", locale_block))
    if locales != EXPECTED:
        fail(f"supportedLocales must be exactly {EXPECTED!r} in that order; found {locales!r}")

    # MaterialApp must consume the same canonical list; a second inline list
    # would create a drift path between the tested constant and runtime wiring.
    if not re.search(r"supportedLocales\s*:\s*supportedLocales\s*,", text):
        fail("MaterialApp is not wired to the canonical supportedLocales list")
    if not re.search(r"localizationsDelegates\s*:\s*localizationDelegates\s*,", text):
        fail("MaterialApp is not wired to the canonical localizationDelegates list")

    # Reject unsupported app-level Locale declarations anywhere in RuhCodeApp.
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

    # The packaged language-scoped content roots must not introduce a third
    # top-level locale. This is intentionally scoped to the production assets
    # declared in pubspec; RC-0003 owns editorial independence/completeness.
    if not PUBSPEC.is_file():
        fail("pubspec.yaml is missing")
    pubspec = PUBSPEC.read_text(encoding="utf-8")
    declared_content_locales = tuple(
        re.findall(r"assets/content/daily_messages/([A-Za-z_-]+)/", pubspec)
    )
    if declared_content_locales != EXPECTED:
        fail(
            "daily-message production asset locales must be exactly "
            f"{EXPECTED!r}; found {declared_content_locales!r}"
        )

    print("RC0002_LANGUAGE_SCOPE_OK supported=tr,en other_locales=0 delegates=3 assets=tr,en")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
