#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT=ROOT/'requirements/contracts/rc0342_rc0359_ui_profile_contract.json'
IA=ROOT/'lib/src/ui/navigation/information_architecture.dart'
PROFILE=ROOT/'lib/src/domain/profile/birth_profile.dart'
TEST_IA=ROOT/'test/ui/information_architecture_rc0342_rc0353_test.dart'
TEST_PROFILE=ROOT/'test/domain/birth_profile_rc0354_rc0359_test.dart'
for p in (SPEC,CONTRACT,IA,PROFILE,TEST_IA,TEST_PROFILE):
    if not p.exists(): raise SystemExit(f'RC0342_RC0359_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(342,360):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec):
        raise SystemExit(f'RC0342_RC0359_FAIL: missing binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0342..RC-0359': raise SystemExit('RC0342_RC0359_FAIL: range')
ia=IA.read_text(encoding='utf-8')
profile=PROFILE.read_text(encoding='utf-8')
for token in [
    'enum PrimaryDestination', 'today, discover, calculate, records, profile',
    'enum ExperienceMode', 'professionalOnly: true', 'visibleToolDomains',
    "trLabel: 'Batı Astrolojisi'", "trLabel: 'Vedik Astroloji'",
    "trLabel: 'Çin Astrolojisi'", "trLabel: 'Numeroloji'",
    "trLabel: 'Spiritüel Araçlar'", "trLabel: 'Kişisel Gelişim'",
    'static const onboarding', 'optionalBirthProfile',
]:
    if token not in ia: raise SystemExit(f'RC0342_RC0359_FAIL: IA token {token!r}')
for token in [
    'enum BirthTimeKnowledge', 'known, unknown', 'BirthTimeValue.unknown',
    'BirthTimeDependency', 'requireLocalBirthDateTime',
    'time-dependent calculation blocked', 'BirthPlaceSelection',
    'IANA timeZoneId required', 'copyWith', 'BirthTimeFeatureNotice',
]:
    if token not in profile: raise SystemExit(f'RC0342_RC0359_FAIL: profile token {token!r}')
tests=TEST_IA.read_text(encoding='utf-8')+TEST_PROFILE.read_text(encoding='utf-8')
for token in [
    'professional tools cannot leak into simple mode',
    'first launch policy exposes only a short onboarding flow',
    'unknown birth time can never fabricate a time-dependent datetime',
    'profile data can be edited without changing stable profile identity',
]:
    if token not in tests: raise SystemExit(f'RC0342_RC0359_FAIL: test token {token!r}')
blocked=c.get('blocked_until') or []
if not any('MainNavigationShell' in item for item in blocked): raise SystemExit('RC0342_RC0359_FAIL: runtime UI blocker missing')
if not any('ascendant' in item.lower() for item in blocked): raise SystemExit('RC0342_RC0359_FAIL: birth-time route blocker missing')
print('RC0342_RC0359_OK')
