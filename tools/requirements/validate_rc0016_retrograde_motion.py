#!/usr/bin/env python3
from __future__ import annotations
import csv, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
C=ROOT/'requirements/contracts/rc0016_retrograde_motion_contract.json'

def req(ok,msg):
    if not ok: raise SystemExit(msg)

def main():
    c=json.loads(C.read_text(encoding='utf-8'))
    req(c['rcId']=='RC-0016','wrong RC binding')
    req(c['promotionCeiling']=='TESTED','RC-0016 self-promotion ceiling weakened')
    rows=list(csv.DictReader((ROOT/'requirements/requirement_state.csv').open(encoding='utf-8',newline='')))
    row=next((r for r in rows if r['rc_id']=='RC-0016'),None)
    req(row is not None,'RC-0016 missing from matrix')
    req(row['source_text_sha256']==c['bindingRequirementSha256'],'RC-0016 binding SHA drift')
    for rel in c['requiredRuntimeComponents']+c['requiredCompiledTests']:
        p=ROOT/rel; req(p.is_file() and p.stat().st_size>0,f'missing RC-0016 evidence: {rel}')
    ep=(ROOT/'lib/src/calculation_core/ephemeris/ephemeris.dart').read_text(encoding='utf-8')
    provider=(ROOT/'lib/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart').read_text(encoding='utf-8')
    for needle in ('enum ApparentMotion { direct, stationary, retrograde }','longitudeSpeedDegreesPerDay','speed.abs() <= stationaryThresholdDegreesPerDay','speed < 0 ? ApparentMotion.retrograde : ApparentMotion.direct'):
        req(needle in ep,f'RC-0016 motion contract missing: {needle}')
    # The provider propagates the physical SPK Cartesian velocity components
    # (vx/vy/vz km/s), rotates vx/vy into the ecliptic frame, then derives
    # signed longitude speed. Validate the real implementation symbols rather
    # than requiring a non-existent aggregate `velocityKmPerSecond` field.
    for needle in ('longitudeSpeedDegreesPerDay','state.vxKmPerSecond','state.vyKmPerSecond','state.vzKmPerSecond','longitudeRateRadiansPerSecond','_toJ2000Ecliptic'):
        req(needle in provider,f'RC-0016 physical velocity propagation missing: {needle}')
    req('DateTime.now()' not in provider,'RC-0016 provider must not infer status from device clock')
    print('RC-0016 retrograde motion contract: OK')
if __name__=='__main__': main()
