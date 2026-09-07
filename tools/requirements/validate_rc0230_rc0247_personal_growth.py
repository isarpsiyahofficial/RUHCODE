#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0230_rc0247_personal_growth_contract.json'
PROD = ROOT / 'lib/src/application/personal_growth/personal_growth_core.dart'
TEST = ROOT / 'test/application/personal_growth/personal_growth_core_test.dart'

def fail(msg):
    print(f'FAIL: {msg}')
    sys.exit(1)

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists(): fail(f'missing {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(230, 248):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec): fail(f'binding specification no longer contains numbered requirement {n}.')
    rc = f'RC-{n:04d}'
    if rc not in contract['requirements']: fail(f'contract missing {rc}')

required_prod = [
    'PersonalJournalEntry', 'PersonalGoal', 'GoalTask', 'HabitRecord',
    'ReflectionEntry', 'LifeWheelScore', 'PersonalValue', 'MoodEnergyEntry',
    'DailyCheckIn', 'CheckInKind.morning', 'CheckInKind.evening', 'PersonalNote',
    'AstrologyContextLink', 'GrowthSnapshot', 'journalForDate', 'moodEnergyForDate'
]
for token in required_prod:
    if token not in prod: fail(f'production evidence missing token {token}')

if 'this.astrologyContext' not in prod or 'AstrologyContextLink?' not in prod:
    fail('astrology context must remain optional')
if 'works without astrology context' not in test:
    fail('regression does not prove astrology-independent usage')
if 'duplicate task ids fail closed' not in test:
    fail('goal-subtask fail-closed regression missing')

print('OK: RC-0230..RC-0247 personal growth contract/evidence validated')
