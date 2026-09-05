#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
rows = {r['rc_id']: r for r in csv.DictReader((ROOT/'requirements/requirement_state.csv').open(encoding='utf-8', newline=''))}
contract = json.loads((ROOT/'requirements/contracts/rc0062_natal_chart_contract.json').read_text(encoding='utf-8'))
expected_sha = '9c732cafd538326442a9937e718d0ebdc4237b464f510293eb0dfe3146ebc3d2'

if rows['RC-0062']['source_text_sha256'] != expected_sha:
    raise SystemExit('RC-0062 matrix binding SHA mismatch')
if contract['requirements']['RC-0062']['bindingRequirementSha256'] != expected_sha:
    raise SystemExit('RC-0062 contract binding SHA mismatch')
if contract.get('promotionCeiling') != 'TESTED':
    raise SystemExit('RC-0062 promotion ceiling must remain TESTED')

runtime = (ROOT/'lib/src/calculation_core/western/natal_chart.dart').read_text(encoding='utf-8')
test = (ROOT/'test/calculation_core/western/natal_chart_test.dart').read_text(encoding='utf-8')
required_runtime_tokens = (
    'final class WesternNatalChart',
    'abstract final class WesternNatalChartAssembler',
    'required this.houses',
    'required this.placements',
    'required this.aspects',
    'required this.aspectGrid',
    'required this.dignities',
    'placements.sourceId != aspects.sourceId',
    'placements.dataVersion != aspects.dataVersion',
    '_validateDerivedBodySets',
)
for token in required_runtime_tokens:
    if token not in runtime:
        raise SystemExit(f'RC-0062 runtime evidence missing: {token}')

if 'test(' not in test or 'WesternNatalChartAssembler.build' not in test:
    raise SystemExit('RC-0062 compiled natal-chart regression is missing')
for token in ('placements', 'aspects', 'aspectGrid', 'dignities'):
    if token not in test:
        raise SystemExit(f'RC-0062 compiled evidence does not exercise {token}')

for rel in contract['runtimeEvidence'] + contract['compiledEvidence']:
    if not (ROOT/rel).is_file():
        raise SystemExit(f'RC-0062 evidence file missing: {rel}')

print('RC-0062 natal chart contract: PASS')
