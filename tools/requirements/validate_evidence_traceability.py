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
    if not isinstance(reqs, list) or not reqs:
        raise AssertionError(f"{path}: non-empty requirements[] is required")
    parsed = []
    for rc in reqs:
        if not isinstance(rc, str) or not re.fullmatch(r"RC-\d{4}", rc):
            raise AssertionError(f"{path}: invalid requirement token {rc!r}")
        parsed.append(int(rc[3:]))
    if len(parsed) != len(set(parsed)):
        raise AssertionError(f"{path}: duplicate requirement IDs")
    return set(parsed)


# Exact semantic ownership for evidence files that previously suffered or are especially
# vulnerable to TODO-index-as-RC drift. QA umbrella requirements are included only where the
# MASTER literally applies them to the engine family. Unrelated data/security/offline RCs must
# never appear here.
EXPECTED = {
    "evidence/numerology/pythagorean_profile.json": {
        161, 162, 165, 166, 167, 168, 169, 170, 171, 174, 182, 183, 329,
    },
    "evidence/numerology/pythagorean_extended_name.json": {
        172, 173, 175, 182, 183, 329,
    },
    "evidence/numerology/personal_cycles.json": {
        174, 176, 177, 178, 329, 337, 1436,
    },
    "evidence/numerology/pinnacles_challenges.json": {
        179, 180, 329,
    },
    "evidence/numerology/compatibility.json": {
        181, 329,
    },
    "evidence/bazi/sexagenary_cycle.json": {
        147, 148,
    },
    "evidence/bazi/hidden_stems.json": {
        149,
    },
    "evidence/bazi/four_pillars_primitives.json": {
        150, 151, 152,
    },
    "evidence/bazi/ten_gods.json": {
        153,
    },
}

# Literal keyword assertions make accidental reassignment harder even if an EXPECTED set is edited.
KEYWORDS = {
    147: "Heavenly Stems",
    148: "Earthly Branches",
    149: "Hidden Stems",
    150: "Five Elements",
    151: "Yin/Yang",
    152: "Day Master",
    153: "Ten Gods",
    161: "Numeroloji",
    162: "Pythagorean",
    166: "Life Path",
    167: "Expression",
    168: "Soul Urge",
    169: "Personality",
    170: "Birthday",
    171: "Maturity",
    172: "Balance",
    173: "Karmic Lessons",
    174: "Karmic Debt",
    175: "Hidden Passion",
    176: "Personal Year",
    177: "Personal Month",
    178: "Personal Day",
    179: "Pinnacle",
    180: "Challenge",
    181: "compatibility",
    182: "Türkçe karakterler",
    183: "normalize",
    329: "Numeroloji motorlarının",
    337: "Leap year",
    1436: "doğruluk toleransı",
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
