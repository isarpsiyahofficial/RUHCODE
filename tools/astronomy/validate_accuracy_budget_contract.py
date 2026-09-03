#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
manifest = ROOT / 'requirements/reference_manifests/astronomy_accuracy_budgets.json'

if not manifest.exists():
    raise SystemExit('missing astronomy accuracy budget manifest')

data = json.loads(manifest.read_text(encoding='utf-8'))
if data.get('contract') != 'astronomy_accuracy_budgets':
    raise SystemExit('invalid astronomy accuracy budget contract id')
if data.get('status') != 'acceptance-targets-not-yet-proven':
    raise SystemExit('accuracy budgets must remain explicitly unproven until evidence exists')
if data.get('proven') is not False:
    raise SystemExit('accuracy budgets cannot be marked proven without independent evidence')

budgets = data.get('budgets') or {}
required = {
    'sunGeocentricLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'moonGeocentricLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'planetGeocentricLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'nodeLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'ayanamshaLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'nakshatraLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'padaLongitudeMaxAbsErrorDegrees': (0, 0.1),
    'ascendantLongitudeMaxAbsErrorDegrees': (0, 0.2),
    'mcLongitudeMaxAbsErrorDegrees': (0, 0.2),
    'houseCuspLongitudeMaxAbsErrorDegrees': (0, 0.2),
    'sunriseSunsetMaxAbsErrorSeconds': (0, 300),
    'planetaryHourBoundaryMaxAbsErrorSeconds': (0, 300),
}
for key, (minimum, maximum) in required.items():
    value = budgets.get(key)
    if not isinstance(value, (int, float)) or not (minimum < value <= maximum):
        raise SystemExit(f'invalid or missing accuracy budget: {key}')

boundary = data.get('boundaryRules') or {}
for key in ('signBoundary', 'houseBoundary', 'nakshatraBoundary', 'padaBoundary', 'aspectOrb'):
    text = boundary.get(key)
    if not isinstance(text, str) or 'unrounded' not in text:
        raise SystemExit(f'boundary rule must require unrounded values: {key}')

evidence = data.get('evidenceRequired') or {}
for key in (
    'independentReferenceDataset',
    'physicalPackagedRuntimeDataset',
    'sourceVersionAndChecksum',
    'boundaryCases',
    'crossTimezoneCases',
    'crossLatitudeCases',
    'supportedDateRangeCases',
):
    if evidence.get(key) is not True:
        raise SystemExit(f'missing mandatory accuracy evidence requirement: {key}')

prohibited = set(data.get('prohibitedAcceptance') or [])
for item in (
    'self-reference against the same algorithm implementation',
    'manual approximate visual acceptance',
):
    if item not in prohibited:
        raise SystemExit(f'missing prohibited acceptance mode: {item}')

print('Astronomy Accuracy Budget Contract OK')
