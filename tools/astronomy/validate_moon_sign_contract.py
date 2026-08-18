#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = ROOT / 'requirements/reference_manifests/moon_sign_runtime.json'
engine = ROOT / 'lib/src/calculation_core/lunar/moon_sign.dart'
factor = ROOT / 'lib/src/calculation_core/daily/moon_sign_factor.dart'
test_file = ROOT / 'test/calculation_core/moon_sign_test.dart'

for path in (manifest, engine, factor, test_file):
    if not path.exists():
        raise SystemExit(f'missing moon-sign contract file: {path.relative_to(ROOT)}')

data = json.loads(manifest.read_text(encoding='utf-8'))
if data.get('contract') != 'moon_sign_runtime' or data.get('zodiac') != 'tropical':
    raise SystemExit('invalid moon-sign contract metadata')
if data.get('signWidthDegrees') != 30:
    raise SystemExit('tropical sign width must be 30 degrees')
if len(data.get('signOrder', [])) != 12:
    raise SystemExit('tropical zodiac must contain 12 signs')
if data.get('dailySnapshotBinding') is not True:
    raise SystemExit('Moon sign must be bound to DailySnapshot')
if data.get('physicalEphemerisDatasetDone') is not False:
    raise SystemExit('physical ephemeris must remain NOT_DONE until packaged data exists')

engine_text = engine.read_text(encoding='utf-8')
for token in ('AstroBody.moon', '/ 30.0', 'TropicalZodiacSign.values[index]', 'degreeWithinSign'):
    if token not in engine_text:
        raise SystemExit(f'moon-sign engine missing token: {token}')

factor_text = factor.read_text(encoding='utf-8')
for token in ('DailyFactorKind.moonSign', "sourceEngineId: 'moon_sign_tropical'", 'MoonSignEngine'):
    if token not in factor_text:
        raise SystemExit(f'DailySnapshot moon-sign binding missing token: {token}')

print('Moon Sign Contract OK')
