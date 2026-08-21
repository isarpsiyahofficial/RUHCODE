from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "lib/src/content/terminology/terminology_glossary.dart"
TEST = ROOT / "test/content/terminology/terminology_glossary_test.dart"
EVIDENCE = ROOT / "evidence/content/terminology_glossary.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    test = TEST.read_text(encoding="utf-8")
    evidence = json.loads(EVIDENCE.read_text(encoding="utf-8"))

    for token in (
        "enum TerminologyId",
        "RuhTerminologyGlossary",
        "static const String version = 'terminology.v1'",
        "en: 'Ascendant'",
        "tr: 'Yükselen'",
        "en: 'House'",
        "tr: 'Ev'",
        "en: 'Nakshatra'",
        "tr: 'Nakshatra'",
        "en: 'Life Path'",
        "tr: 'Yaşam Yolu'",
        "validateComplete",
    ):
        require(token in source, f"terminology source missing token: {token}")

    for token in (
        "every canonical terminology ID has TR and EN labels",
        "critical Western terminology stays fixed",
        "Vedik technical terminology is not arbitrarily renamed",
        "numerology terminology is stable across the app",
        "unsupported locale fails closed",
    ):
        require(token in test, f"terminology test missing regression: {token}")

    require(evidence.get("contract_id") == "TR_EN_TERMINOLOGY_GLOSSARY_V1", "unexpected contract id")
    require(evidence.get("version") == "terminology.v1", "unexpected glossary version")
    require(evidence.get("done") is False, "source-level evidence must not claim DONE")
    for rc in ("RC-1059", "RC-1060", "RC-1061", "RC-1062", "RC-1063", "RC-1064", "RC-1065"):
        require(rc in evidence.get("requirements", []), f"missing requirement mapping: {rc}")

    remaining = " ".join(evidence.get("remaining_before_done", []))
    require("production UI/PDF/notification surfaces" in remaining, "consumer migration blocker must remain explicit")

    print("terminology glossary structural contract: OK")


if __name__ == "__main__":
    main()
