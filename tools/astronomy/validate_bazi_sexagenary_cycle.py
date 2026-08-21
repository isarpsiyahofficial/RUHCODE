#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/calculation_core/bazi/sexagenary_cycle.dart'
TEST = ROOT / 'test/calculation_core/bazi/sexagenary_cycle_test.dart'
EVIDENCE = ROOT / 'evidence/bazi/sexagenary_cycle.json'

for path in (SOURCE, TEST, EVIDENCE):
    if not path.is_file():
        raise SystemExit(f'missing BaZi sexagenary artifact: {path.relative_to(ROOT)}')

evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
if evidence.get('status') != 'SOURCE_LEVEL_IMPLEMENTED' or evidence.get('done') is not False:
    raise SystemExit('BaZi sexagenary evidence must remain source-level until runtime/reference proof exists')

source = SOURCE.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for token in (
    'enum HeavenlyStem',
    'enum EarthlyBranch',
    'enum WuXingElement',
    'enum YinYang',
    'static const int length = 60;',
    '0 = Jia-Zi, 59 = Gui-Hai',
    'stem.polarity != branch.polarity',
):
    if token not in source:
        raise SystemExit(f'missing BaZi sexagenary source contract token: {token}')

for forbidden in (
    'CivilDate',
    'solarTerm',
    'SolarTerm',
    'DateTime.now',
):
    if forbidden in source:
        raise SystemExit(f'unverified date/solar-term logic leaked into pure sexagenary primitive: {forbidden}')

for token in (
    'all 60 canonical pairs preserve Yin/Yang parity and are unique',
    'invalid parity pair is rejected instead of invented',
    'SexagenaryCycle.at(-1)',
):
    if token not in test:
        raise SystemExit(f'missing BaZi sexagenary regression: {token}')

print('BaZi sexagenary cycle contract: OK')
