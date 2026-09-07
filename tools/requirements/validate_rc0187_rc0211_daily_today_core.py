from pathlib import Path

SPEC = Path('RUH_CODE_MASTER_SARTNAME.md')
PROD = Path('lib/src/application/daily/daily_today_core.dart')
TEST = Path('test/application/daily_today_core_rc0187_rc0211_test.dart')
CONTRACT = Path('requirements/contracts/rc0187_rc0211_daily_today_core_contract.json')

for p in (SPEC, PROD, TEST, CONTRACT):
    if not p.exists():
        raise SystemExit(f'RC0187_RC0211_FAIL: missing {p}')

spec = SPEC.read_text(encoding='utf-8').splitlines()
for i in range(187, 212):
    if not any(line.startswith(f'{i}.') for line in spec):
        raise SystemExit(f'RC0187_RC0211_FAIL: missing binding entry {i}')

prod = PROD.read_text(encoding='utf-8')
required = [
    'DailyTodaySnapshot', 'moonSign', 'moonPhase', 'currentPlanetaryHour',
    'nextPlanetaryHour', 'personalDay', 'personalTransits', 'retrogrades',
    'astrologicalOutlook', 'DailyMessageRecipe', 'DailyMessageEngine',
    'DailySystemId.western', 'DailySystemId.vedic', 'DailySourceEvidence',
    'RewardedUnlockGrant', 'DailyAccessPolicy', 'DailyAdExperiencePolicy',
    "scope == requestedScope && nowUtc.isBefore(expiresAtUtc)",
    "userInitiated && promptsAlreadyShown < maxRewardPromptsPerSession",
]
for token in required:
    if token not in prod:
        raise SystemExit(f'RC0187_RC0211_FAIL: missing production token {token}')

if 'Random(' in prod or 'dart:math' in prod:
    raise SystemExit('RC0187_RC0211_FAIL: random-pool daily-message implementation is forbidden')
if "systems.contains(DailySystemId.western) && systems.contains(DailySystemId.vedic)" not in prod:
    raise SystemExit('RC0187_RC0211_FAIL: western/vedic anti-fusion guard missing')

text = TEST.read_text(encoding='utf-8')
for marker in ('RC-0187', 'RC-0199', 'RC-0205', 'RC-0207', 'RC-0211'):
    if marker not in text:
        raise SystemExit(f'RC0187_RC0211_FAIL: missing regression marker {marker}')

print('RC0187_RC0211_OK')
