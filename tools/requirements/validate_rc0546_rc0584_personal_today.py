from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0546_rc0584_personal_today_contract.json'
PROD = ROOT / 'lib/src/daily/personal_today_calendar.dart'
TEST = ROOT / 'test/daily/personal_today_calendar_rc0546_rc0584_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(546, 585):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'PersonalTodaySnapshot', 'PersonalSignalKind.moon', 'PersonalSignalKind.planetaryHour',
    'PersonalSignalKind.personalDay', 'PersonalSignalKind.transit', 'PersonalSignalKind.vedicPeriod',
    'PersonalSignalKind.moonPhase', 'importantEffects(', 'TodayEntitlement.free', 'TodayEntitlement.pro',
    'TodayRange.week', 'TodayRange.month', 'TodayRange.year', 'PersonalCalendar', 'FavoriteDate',
    'ReminderKind.transitExact', 'ReminderKind.personalMonthChanged', 'ReminderKind.fullMoon',
    'ReminderKind.planetaryHourStarted', 'HistoricalCorrelationPolicy'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in ['Free sees first important effects', 'Year view is PRO', 'Past day returns its own journal', 'Reminder categories are independently manageable']:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until runtime/UI/release evidence exists')

print('RC-0546..RC-0584 personal Today/calendar contract OK')
