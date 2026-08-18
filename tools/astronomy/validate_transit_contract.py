#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = ROOT / 'requirements/reference_manifests/transit_runtime.json'
engine = ROOT / 'lib/src/calculation_core/transits/transit_aspects.dart'
factor = ROOT / 'lib/src/calculation_core/daily/transit_factor.dart'
engine_test = ROOT / 'test/calculation_core/transit_aspects_test.dart'
factor_test = ROOT / 'test/calculation_core/transit_daily_factor_test.dart'

for path in (manifest, engine, factor, engine_test, factor_test):
    if not path.exists():
        raise SystemExit(f'missing transit contract file: {path.relative_to(ROOT)}')

data = json.loads(manifest.read_text(encoding='utf-8'))
if data.get('contract') != 'transit_runtime' or data.get('zodiac') != 'tropical':
    raise SystemExit('invalid transit contract metadata')
if data.get('supportedAspects') != ['conjunction', 'sextile', 'square', 'trine', 'opposition']:
    raise SystemExit('transit contract must contain the five required major aspects')
if data.get('supportedPhases') != ['applying', 'exact', 'separating', 'indeterminate']:
    raise SystemExit('transit contract must expose applying/exact/separating/indeterminate phases')
phase = data.get('phaseClassification') or {}
if phase.get('usesEphemerisLongitudeSpeed') is not True:
    raise SystemExit('transit phase classification must use ephemeris longitude speed')
if phase.get('networkLookupRequired') is not False:
    raise SystemExit('transit phase classification must remain offline')
if phase.get('exactPhasePrecedence') is not True:
    raise SystemExit('exact phase must take precedence over applying/separating')
if phase.get('stationaryNonExactPhase') != 'indeterminate':
    raise SystemExit('stationary non-exact aspects must be indeterminate')
if data.get('dailySnapshotBinding') is not True:
    raise SystemExit('transits must be bound to DailySnapshot')
if data.get('requiresExactTtEphemeris') is not True:
    raise SystemExit('transits must require exact TT ephemeris states')
if data.get('networkFallbackAllowed') is not False or data.get('nearestDateFallbackAllowed') is not False:
    raise SystemExit('transit fallback policy must remain strict/offline')
if data.get('physicalEphemerisDatasetDone') is not False:
    raise SystemExit('physical ephemeris must remain NOT_DONE until packaged data exists')
if data.get('independentAccuracySuiteDone') is not False:
    raise SystemExit('accuracy suite must remain NOT_DONE until evidence exists')

engine_text = engine.read_text(encoding='utf-8')
for token in (
    'TransitAspectType',
    'TransitAspectPhase',
    'TransitAspectOrbPolicy',
    '_classifyPhase',
    '_smallestAngularSeparation',
    'longitudeSpeedDegreesPerDay',
    'ephemeris.stateAt',
    'orbDegrees',
    'List<TransitAspectMatch>.unmodifiable',
):
    if token not in engine_text:
        raise SystemExit(f'transit engine missing token: {token}')

test_text = engine_test.read_text(encoding='utf-8')
for token in (
    'TransitAspectPhase.applying',
    'TransitAspectPhase.exact',
    'TransitAspectPhase.separating',
    'TransitAspectPhase.indeterminate',
    'retrograde motion can make an aspect applying',
):
    if token not in test_text:
        raise SystemExit(f'transit phase test missing token: {token}')

factor_text = factor.read_text(encoding='utf-8')
for token in (
    'DailyFactorKind.transit',
    "sourceEngineId: 'western_transit_aspects'",
    'TransitAspectEngine',
):
    if token not in factor_text:
        raise SystemExit(f'DailySnapshot transit binding missing token: {token}')

print('Transit Contract OK')
