#!/usr/bin/env python3
import json
from pathlib import Path

PATH = Path('requirements/reference_manifests/offline_ephemeris_runtime.json')

data = json.loads(PATH.read_text(encoding='utf-8'))
assert data['productDateRange'] == {'start': '1890-01-01', 'end': '2110-12-31'}

p = data['planetaryEphemeris']
assert p['solution'] == 'DE440'
assert p['officialCoverage'] == '1550-2650'
assert p['sourceUrl'].startswith('https://ssd.jpl.nasa.gov/')
assert p['redistributionPolicySource'] == 'https://naif.jpl.nasa.gov/naif/rules.html'
assert p['redistributionRule'] == 'unmodified_NAIF_distributed_kernel_permitted'
assert p['commercialUse'] == 'allowed_under_NAIF_rules_no_fee'
if p['proven']:
    assert p['bundled'] is True
    assert isinstance(p['sha256'], str) and len(p['sha256']) == 64
    assert isinstance(p['byteSize'], int) and p['byteSize'] > 0
    assert p['retrievedAtUtc']
else:
    assert p['bundled'] is False or p['sha256'] is not None


e = data['earthOrientation']
assert e['authority'] == 'IERS'
assert e['primaryProduct'] == 'finals2000A.all'
assert e['observedCoverageStarts'] == '1973-01-02'
assert e['coversProductDateRange'] is False
assert e['fabricatedFutureEopForbidden'] is True
assert e['outsideCoveragePolicy'] == 'separate_versioned_time_scale_model_or_unavailable'
if e['proven']:
    assert e['bundled'] is True
    assert isinstance(e['sha256'], str) and len(e['sha256']) == 64

r = data['runtimeRules']
for key in ('networkFallback', 'nearestDateFallback', 'zeroStateFallback'):
    assert r[key] is False
for key in ('corruptionFailsClosed', 'outOfCoverageFailsClosed', 'independentGoldenEvidenceRequired', 'cleanCheckoutReproducibilityRequired'):
    assert r[key] is True

print('offline ephemeris runtime contract: PASS')
