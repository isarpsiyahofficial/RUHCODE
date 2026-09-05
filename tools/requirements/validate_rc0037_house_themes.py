#!/usr/bin/env python3
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RC = 'RC-0037'
EXPECTED_SHA = '5f25283b4628a240681df6b56700b7c2604022c62d4c1e30776d3e0141804472'


def require(condition, message):
    if not condition:
        raise SystemExit(f'{RC}: {message}')


contract = json.loads((ROOT / 'requirements/contracts/rc0037_house_themes_contract.json').read_text(encoding='utf-8'))
rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
row = next(r for r in rows if r['rc_id'] == RC)
require(contract['rcId'] == RC, 'contract id mismatch')
require(contract['bindingRequirementSha256'] == row['source_text_sha256'] == EXPECTED_SHA, 'binding SHA mismatch')
require(contract['promotionCeiling'] == 'TESTED', 'promotion ceiling weakened')

source_path = ROOT / 'lib/src/interpretation/western_house_themes.dart'
test_path = ROOT / 'test/interpretation/western_house_themes_test.dart'
source = source_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')
require('/calculation_core/' not in source_path.as_posix(), 'interpretation content leaked into calculation_core')
for token in [
    'static const List<WesternHouseTheme> all = [',
    'final String titleTr;',
    'final String titleEn;',
    'final String descriptionTr;',
    'final String descriptionEn;',
    "RangeError.range(houseNumber, 1, 12",
]:
    require(token in source, f'missing house-theme runtime token: {token}')
require(source.count('WesternHouseTheme(houseNumber:') == 12, 'catalog must contain exactly twelve explicit house themes')
for token in ['hasLength(12)', 'theme.titleTr.trim()', 'theme.titleEn.trim()', 'theme.descriptionTr.trim()', 'theme.descriptionEn.trim()', 'throwsRangeError']:
    require(token in test, f'missing compiled catalog regression token: {token}')
print(f'{RC}: PASS')
