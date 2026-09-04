#!/usr/bin/env python3
from __future__ import annotations
import csv, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
C=ROOT/'requirements/contracts/rc0014_physical_body_positions_contract.json'

def req(ok,msg):
    if not ok: raise SystemExit(msg)

def main():
    c=json.loads(C.read_text(encoding='utf-8'))
    req(c['rcId']=='RC-0014','wrong RC binding')
    req(c['promotionCeiling']=='TESTED','RC-0014 self-promotion ceiling weakened')
    rows=list(csv.DictReader((ROOT/'requirements/requirement_state.csv').open(encoding='utf-8',newline='')))
    row=next((r for r in rows if r['rc_id']=='RC-0014'),None)
    req(row is not None,'RC-0014 missing from matrix')
    req(row['source_text_sha256']==c['bindingRequirementSha256'],'RC-0014 binding SHA drift')
    for rel in c['requiredRuntimeComponents']+c['requiredCompiledTests']:
        p=ROOT/rel; req(p.is_file() and p.stat().st_size>0,f'missing RC-0014 evidence: {rel}')
    p=(ROOT/'lib/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart').read_text(encoding='utf-8')
    for body in c['policy']['requiredPhysicalBodies']:
        req(f'AstroBody.{body}:' in p,f'physical body mapping missing: {body}')
    for needle in ('observerId: _earthNaifId','_ttJulianDayToTdbEtSeconds','_toJ2000Ecliptic','longitudeSpeedDegreesPerDay','coverage.requireContains'):
        req(needle in p,f'RC-0014 provider contract missing: {needle}')
    mapping=p.split('_naifTargetByBody',1)[1].split('};',1)[0]
    req('AstroBody.meanNode' not in mapping,'mean node must not be substituted as physical SPK target')
    req('AstroBody.trueNode' not in mapping,'true node must not be substituted as physical SPK target')
    print('RC-0014 physical body position contract: OK')
if __name__=='__main__': main()
