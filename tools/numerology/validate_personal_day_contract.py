#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
ENGINE = ROOT / 'lib/src/calculation_core/numerology/personal_day.dart'
FACTOR = ROOT / 'lib/src/calculation_core/daily/personal_day_factor.dart'
TEST = ROOT / 'test/calculation_core/personal_day_test.dart'
FACTOR_TEST = ROOT / 'test/calculation_core/personal_day_daily_factor_test.dart'
MANIFEST = ROOT / 'requirements/reference_manifests/personal_day_runtime.json'

required_files = [ENGINE, FACTOR, TEST, FACTOR_TEST, MANIFEST]
missing = [str(path.relative_to(ROOT)) for path in required_files if not path.exists()]
if missing:
    raise SystemExit(f'Missing personal-day contract files: {missing}')

engine = ENGINE.read_text(encoding='utf-8')
factor = FACTOR.read_text(encoding='utf-8')
tests = TEST.read_text(encoding='utf-8')
factor_tests = FACTOR_TEST.read_text(encoding='utf-8')
manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))

assert "numerology.pythagorean.personal-day" in engine
assert "PersonalCycleReductionPolicy.singleDigit" in engine
assert "preserveMasterNumbers" in engine
assert "masterNumbers = <int>{11, 22, 33}" in engine
assert "birthDate.month + birthDate.day + universalYear" in engine
assert "personalYear + targetDate.month" in engine
assert "personalMonth + targetDate.day" in engine
assert "DailyFactorKind.personalDay" in factor
assert "policy.name" in factor
assert "2026, 8, 16" in tests
assert "2027, 8, 16" in tests
assert "2028, 2, 29" in tests
assert "personal-day|2026-08-16|4|py-7|pm-6|singleDigit" in factor_tests
assert manifest['engineId'] == 'numerology.pythagorean.personal-day'
assert manifest['engineVersion'] == '1'
assert manifest['defaultReductionPolicy'] == 'singleDigit'
assert manifest['masterNumbers'] == [11, 22, 33]
assert manifest['localeIndependent'] is True
assert manifest['networkRequired'] is False
assert manifest['dailySnapshotFactor'] == 'personalDay'

print('Personal Day contract OK')
