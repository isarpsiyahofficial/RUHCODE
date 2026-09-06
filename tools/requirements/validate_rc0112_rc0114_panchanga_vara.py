#!/usr/bin/env python3
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2]
contract=json.loads((ROOT/'requirements/contracts/rc0112_rc0114_panchanga_vara_contract.json').read_text(encoding='utf-8'))
vara=(ROOT/'lib/src/calculation_core/vedic/vedic_vara.dart').read_text(encoding='utf-8')
agg=(ROOT/'lib/src/calculation_core/vedic/vedic_panchanga_snapshot.dart').read_text(encoding='utf-8')
test=(ROOT/'test/calculation_core/vedic/vedic_vara_panchanga_snapshot_test.dart').read_text(encoding='utf-8')
assert contract['requirements']==['RC-0112','RC-0114']
for token in ['previousSunrise','floor() % 7','sunrise.jdUt1 > queryJdUt1','sourceId.trim().isEmpty']:
    assert token in vara, token
for token in ['VedicPanchanga.calculateFromSnapshot','VedicVaraCalculator.calculate']:
    assert token in agg, token
for token in ['previous sunrise weekday','assembles all five Panchanga limbs','future sunrise']:
    assert token in test, token
print('RC-0112/0114 binding validation: PASS')
