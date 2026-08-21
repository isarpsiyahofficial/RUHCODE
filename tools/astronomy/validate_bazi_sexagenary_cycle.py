#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/calculation_core/bazi/sexagenary_cycle.dart'
TEST = ROOT / 'test/calculation_core/bazi/sexagenary_cycle_test.dart'
EVIDENCE = ROOT / 'evidence/bazi/sexagenary_cycle.json'
HIDDEN_SOURCE = ROOT / 'lib/src/calculation_core/bazi/hidden_stems.dart'
HIDDEN_TEST = ROOT / 'test/calculation_core/bazi/hidden_stems_test.dart'
HIDDEN_EVIDENCE = ROOT / 'evidence/bazi/hidden_stems.json'

for path in (SOURCE, TEST, EVIDENCE, HIDDEN_SOURCE, HIDDEN_TEST, HIDDEN_EVIDENCE):
    if not path.is_file():
        raise SystemExit(f'missing BaZi contract artifact: {path.relative_to(ROOT)}')

for evidence_path in (EVIDENCE, HIDDEN_EVIDENCE):
    evidence = json.loads(evidence_path.read_text(encoding='utf-8'))
    if evidence.get('status') != 'SOURCE_LEVEL_IMPLEMENTED' or evidence.get('done') is not False:
        raise SystemExit(
            f'{evidence_path.name} must remain source-level until runtime/reference proof exists'
        )

source = SOURCE.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
hidden = HIDDEN_SOURCE.read_text(encoding='utf-8')
hidden_test = HIDDEN_TEST.read_text(encoding='utf-8')

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

for token in (
    'abstract final class BaZiHiddenStems',
    'EarthlyBranch.zi: <HeavenlyStem>[HeavenlyStem.gui]',
    'EarthlyBranch.chou: <HeavenlyStem>',
    'EarthlyBranch.hai: <HeavenlyStem>',
    'static HeavenlyStem mainQi',
    'List<HeavenlyStem>.unmodifiable(stems)',
):
    if token not in hidden:
        raise SystemExit(f'missing BaZi Hidden Stems source contract token: {token}')

for forbidden in ('double weight', 'percentage', 'CivilDate', 'DateTime.now'):
    if forbidden in hidden:
        raise SystemExit(f'unverified weighting/date logic leaked into Hidden Stems primitive: {forbidden}')

for token in (
    'all twelve branches have a non-empty unique hidden-stem mapping',
    'single-stem branches preserve their canonical main qi',
    'multi-stem branches preserve canonical ordered stems',
    'returned lists are immutable',
):
    if token not in hidden_test:
        raise SystemExit(f'missing BaZi Hidden Stems regression: {token}')

print('BaZi sexagenary + Hidden Stems contract: OK')
