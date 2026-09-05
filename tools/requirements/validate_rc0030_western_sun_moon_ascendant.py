#!/usr/bin/env python3
import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC = "RC-0030"
EXPECTED_SHA = "823d0276f9829cacc625c544f5991c6fa16e946714013841fd66a7cc1e45982a"


def require(condition, message):
    if not condition:
        raise SystemExit(f"{RC}: {message}")


contract_path = ROOT / "requirements/contracts/rc0030_western_sun_moon_ascendant_contract.json"
contract = json.loads(contract_path.read_text(encoding="utf-8"))
require(contract["rcId"] == RC, "contract rcId mismatch")
require(contract["bindingRequirementSha256"] == EXPECTED_SHA, "contract binding SHA mismatch")

rows = list(csv.DictReader((ROOT / "requirements/requirement_state.csv").open(encoding="utf-8", newline="")))
row = next(item for item in rows if item["rc_id"] == RC)
require(row["source_text_sha256"] == EXPECTED_SHA, "matrix source SHA mismatch")

spec_lines = (ROOT / "RUH_CODE_MASTER_SARTNAME.md").read_text(encoding="utf-8").splitlines()
source = next(line.split(". ", 1)[1] for line in spec_lines if line.startswith("30. "))
require(hashlib.sha256(source.encode("utf-8")).hexdigest() == EXPECTED_SHA, "binding source text changed")

production = (ROOT / "lib/src/calculation_core/western/luminaries_ascendant.dart").read_text(encoding="utf-8")
placements = (ROOT / "lib/src/calculation_core/western/natal_placements.dart").read_text(encoding="utf-8")
houses = (ROOT / "lib/src/calculation_core/western/equal_house_systems.dart").read_text(encoding="utf-8")
test = (ROOT / "test/calculation_core/western/luminaries_ascendant_test.dart").read_text(encoding="utf-8")

for token in ["AstroBody.sun", "AstroBody.moon", "houses.ascendantLongitude", "TropicalZodiacSign.values", "WesternNatalPlacements.build"]:
    require(token in production, f"missing production token: {token}")
require("degreeInSign" in placements and "houseNumber" in placements, "Western placement projection incomplete")
require("ascendantLongitude" in houses, "house result does not expose Ascendant")
for token in ["fails closed when Sun or Moon is absent", "AstroBody.sun", "AstroBody.moon", "ascendantSign"]:
    require(token in test, f"missing compiled regression token: {token}")

print(f"{RC}: PASS")
