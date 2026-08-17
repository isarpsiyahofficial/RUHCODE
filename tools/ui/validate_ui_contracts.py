#!/usr/bin/env python3
import csv, hashlib, re, sys
from pathlib import Path
R=Path(__file__).resolve().parents[2]
IA=R/'docs/UI_INFORMATION_ARCHITECTURE.md'
REF=R/'ui/reference_manifest.csv'; ACT=R/'ui/action_registry.csv'; AST=R/'ui/asset_manifest.csv'
SC=set(re.findall(r'SCR-[A-Z0-9-]+',IA.read_text(encoding='utf-8')))

def die(m): print('ERROR:',m,file=sys.stderr); raise SystemExit(1)
def rows(p):
    if not p.is_file(): die(f'missing {p.relative_to(R)}')
    return list(csv.DictReader(p.open(encoding='utf-8',newline='')))

ref_rows=rows(REF); seen=set(); tracked=set(); approved=set(); pending=set()
for n,x in enumerate(ref_rows,2):
    k=(x['screen_id'].strip(),x['state_id'].strip(),x['reference_version'].strip())
    if k in seen: die(f'duplicate reference {k}')
    seen.add(k); tracked.add(k[0])
    if k[0] not in SC: die(f'unknown screen {k[0]}')
    if x['approval_status'] not in {'PENDING','APPROVED','REJECTED'}: die(f'bad reference status line {n}')
    if x['approval_status']=='APPROVED':
        approved.add(k[0]); p=x['reference_path'].strip(); h=x['sha256'].strip().lower()
        if not p or not re.fullmatch(r'[0-9a-f]{64}',h): die(f'approved reference missing path/hash line {n}')
        f=R/p
        if not f.is_file() or hashlib.sha256(f.read_bytes()).hexdigest()!=h: die(f'reference file/hash mismatch {p}')
    elif x['approval_status']=='PENDING': pending.add(k[0])

act_rows=rows(ACT); seen=set(); action_sources=set()
for n,x in enumerate(act_rows,2):
    a=x['action_id'].strip(); s=x['source_screen_id'].strip(); t=x['target_screen_id_or_effect'].strip()
    if not a.startswith('ACTION-') or a in seen: die(f'bad/duplicate action {a}')
    seen.add(a)
    if s!='GLOBAL_NAV':
        if s not in SC: die(f'unknown action source {s}')
        action_sources.add(s)
    if t.startswith('SCR-') and t not in SC: die(f'unknown action target {t}')
    if x['status'] not in {'ACTIVE','PENDING','DEPRECATED'} or not t: die(f'invalid action {a}')
for a in {'ACTION-NAV-TODAY','ACTION-NAV-TOOLS','ACTION-NAV-RECORDS','ACTION-NAV-PROFILE'}:
    if a not in seen: die(f'missing global action {a}')

asset_rows=rows(AST); seen=set(); asset_approved=0
for n,x in enumerate(asset_rows,2):
    a=x['asset_id'].strip()
    if not a.startswith('ASSET-') or a in seen: die(f'bad/duplicate asset {a}')
    seen.add(a)
    if x['approval_status'] not in {'PENDING','APPROVED','REJECTED'}: die(f'bad asset status {a}')
    if x['approval_status']=='APPROVED':
        asset_approved+=1; p=x['path'].strip(); h=x['sha256'].strip().lower()
        if not p or not re.fullmatch(r'[0-9a-f]{64}',h) or x['license'].strip() in {'','TBD'} or not x['provenance'].strip(): die(f'approved asset incomplete {a}')
        f=R/p
        if not f.is_file() or hashlib.sha256(f.read_bytes()).hexdigest()!=h: die(f'asset file/hash mismatch {a}')

missing=sorted(SC-tracked)
print(f'UI contracts OK: IA screens={len(SC)} tracked_refs={len(tracked)} approved_refs={len(approved)} pending_refs={len(pending)} action_sources={len(action_sources)} assets={len(asset_rows)} approved_assets={asset_approved}')
print(f'UI reference coverage: {len(tracked)}/{len(SC)} ({(100*len(tracked)/len(SC)):.1f}%)')
if missing:
    print('Pending manifest coverage (not a structural failure yet):')
    for sid in missing: print(' -',sid)
