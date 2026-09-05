#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC = 'RC-0050'
EXPECTED_SHA = '51f24e75972c9d1e0bb6a8ea78603292e39038ddf02b217b4492574dd9989451'


def require(condition, message):
    if not condition:
        raise SystemExit(f'{RC}: {message}')


contract = json.loads((ROOT / 'requirements/contracts/rc0050_applying_separating_contract.json').read_text(encoding='utf-8'))
rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
row = next(r for r in rows if r['rc_id'] == RC)
require(contract['rcId'] == RC, 'contract id mismatch')
require(contract['bindingRequirementSha256'] == row['source_text_sha256'] == EXPECTED_SHA, 'binding SHA mismatch')
require(contract['promotionCeiling'] == 'TESTED', 'promotion ceiling weakened')

source = (ROOT / 'lib/src/calculation_core/western/natal_aspects.dart').read_text(encoding='utf-8')
test = (ROOT / 'test/calculation_core/western/natal_aspects_test.dart').read_text(encoding='utf-8')
for token in [
    'enum AspectPhase { applying, exact, separating }',
    'required this.phase',
    'speedA: a.longitudeSpeedDegreesPerDay',
    'speedB: b.longitudeSpeedDegreesPerDay',
    'static AspectPhase phaseFor(',
    'final futureA = _normalize(longitudeA + speedA * probeDays)',
    'final futureB = _normalize(longitudeB + speedB * probeDays)',
    'return AspectPhase.applying',
    'return AspectPhase.separating',
]:
    require(token in source, f'missing applying/separating runtime token: {token}')
for token in [
    'derives applying exact and separating phases from physical longitude speeds',
    'AspectPhase.applying',
    'AspectPhase.exact',
    'AspectPhase.separating',
    'handles retrograde relative motion',
    'double.nan',
]:
    require(token in test, f'missing compiled phase regression token: {token}')
print(f'{RC}: PASS')
