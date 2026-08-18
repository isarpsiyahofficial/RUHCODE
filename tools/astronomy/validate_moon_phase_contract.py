#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = ROOT / 'requirements/reference_manifests/moon_phase_runtime.json'
engine = ROOT / 'lib/src/calculation_core/lunar/moon_phase.dart'
factor = ROOT / 'lib/src/calculation_core/daily/moon_phase_factor.dart'
test_engine = ROOT / 'test/calculation_core/moon_phase_test.dart'
test_factor = ROOT / 'test/calculation_core/moon_phase_daily_factor_test.dart'

for path in (manifest, engine, factor, test_engine, test_factor):
    if not path.exists():
        raise SystemExit(f'missing required moon-phase contract file: {path.relative_to(ROOT)}')

data = json.loads(manifest.read_text(encoding='utf-8'))
if data.get('contract') != 'moon_phase_runtime':
    raise SystemExit('unexpected moon-phase contract id')
if data.get('dailySnapshotBinding') is not True:
    raise SystemExit('moon phase must be bound to DailySnapshot')
if data.get('physicalEphemerisDatasetDone') is not False:
    raise SystemExit('physical ephemeris must remain NOT_DONE until real packaged data exists')

engine_text = engine.read_text(encoding='utf-8')
for token in ('AstroBody.sun', 'AstroBody.moon', 'illuminatedFraction', 'MoonPhaseName.fullMoon'):
    if token not in engine_text:
        raise SystemExit(f'moon phase engine missing token: {token}')
if 'network' in engine_text.lower():
    raise SystemExit('moon phase engine must not contain network fallback logic')

factor_text = factor.read_text(encoding='utf-8')
for token in ('DailyFactorKind.moonPhase', "sourceEngineId: 'moon_phase'", 'MoonPhaseEngine'):
    if token not in factor_text:
        raise SystemExit(f'DailySnapshot moon phase binding missing token: {token}')

print('Moon Phase Contract OK')
