#!/usr/bin/env python3
import csv, hashlib, re, sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
IA = R / 'docs/UI_INFORMATION_ARCHITECTURE.md'
REF = R / 'ui/reference_manifest.csv'
STATE = R / 'ui/state_reference_manifest.csv'
ACT = R / 'ui/action_registry.csv'
AST = R / 'ui/asset_manifest.csv'

SC = set(re.findall(r'SCR-[A-Z0-9-]+', IA.read_text(encoding='utf-8')))

PRIORITY_ACTION_SOURCES = {
    'SCR-TODAY-001','SCR-TOOLS-001','SCR-ASTROLOGY-001','SCR-WESTERN-INPUT-001',
    'SCR-WESTERN-CHART-001','SCR-VEDIC-INPUT-001','SCR-VEDIC-D1-001',
    'SCR-NUMEROLOGY-001','SCR-NUMEROLOGY-INPUT-001','SCR-PYTHAGOREAN-001',
    'SCR-PLANETARY-HOURS-001','SCR-RECORDS-001','SCR-CLIENTS-001',
    'SCR-PROFILE-001','SCR-SETTINGS-001','SCR-BACKUP-001','SCR-PDF-001',
    'SCR-PDF-PREVIEW-001',
}

REQUIRED_STATES = {
    ('SCR-TODAY-001','FREE'),('SCR-TODAY-001','PRO'),('SCR-TODAY-001','OFFLINE'),
    ('SCR-TODAY-MESSAGE-001','FREE_LOCKED'),('SCR-TODAY-MESSAGE-001','TEMP_UNLOCKED'),('SCR-TODAY-MESSAGE-001','PRO'),
    ('SCR-TODAY-YEAR-001','FREE_LOCKED'),('SCR-TODAY-YEAR-001','PRO'),
    ('SCR-WESTERN-INPUT-001','UNKNOWN_BIRTH_TIME'),('SCR-WESTERN-INPUT-001','VALIDATION_ERROR'),
    ('SCR-WESTERN-CHART-001','PARTIAL_UNKNOWN_TIME'),('SCR-WESTERN-CHART-001','PRO'),
    ('SCR-VEDIC-INPUT-001','UNKNOWN_BIRTH_TIME'),('SCR-VEDIC-INPUT-001','VALIDATION_ERROR'),
    ('SCR-VEDIC-D1-001','PARTIAL_UNKNOWN_TIME'),('SCR-VEDIC-D1-001','PRO'),
    ('SCR-PYTHAGOREAN-001','PRO'),('SCR-PLANETARY-HOURS-001','OFFLINE'),('SCR-PLANETARY-HOURS-001','POLAR_UNAVAILABLE'),
    ('SCR-CLIENTS-001','EMPTY'),('SCR-CLIENTS-001','PRO'),('SCR-PDF-PREVIEW-001','ERROR'),('SCR-PDF-PREVIEW-001','PRO'),
    ('SCR-SETTINGS-001','FREE'),('SCR-SETTINGS-001','PRO'),('SCR-PREMIUM-001','FREE'),('SCR-PREMIUM-001','PRO'),
    ('SCR-BACKUP-001','EMPTY'),('SCR-BACKUP-001','ERROR'),('SCR-BACKUP-PREVIEW-001','VALIDATION_ERROR'),
    ('SCR-STATE-OFFLINE-001','DEFAULT'),('SCR-STATE-ERROR-001','DEFAULT'),('SCR-STATE-EMPTY-001','DEFAULT'),
}

def die(m):
    print('ERROR:', m, file=sys.stderr)
    raise SystemExit(1)

def rows(p):
    if not p.is_file(): die(f'missing {p.relative_to(R)}')
    return list(csv.DictReader(p.open(encoding='utf-8', newline='')))

def validate_reference_rows(ref_rows, label, require_screen_coverage=False):
    seen=set(); tracked=set(); approved=set(); pending=set()
    for n,x in enumerate(ref_rows,2):
        k=(x['screen_id'].strip(),x['state_id'].strip(),x['reference_version'].strip())
        if k in seen: die(f'duplicate {label} reference {k}')
        seen.add(k); tracked.add(k[0])
        if k[0] not in SC: die(f'unknown screen {k[0]} in {label}')
        if x['approval_status'] not in {'PENDING','APPROVED','REJECTED'}: die(f'bad {label} reference status line {n}')
        if x['approval_status']=='APPROVED':
            approved.add((k[0],k[1])); p=x['reference_path'].strip(); h=x['sha256'].strip().lower()
            if not p or not re.fullmatch(r'[0-9a-f]{64}',h): die(f'approved {label} reference missing path/hash line {n}')
            f=R/p
            if not f.is_file() or hashlib.sha256(f.read_bytes()).hexdigest()!=h: die(f'{label} reference file/hash mismatch {p}')
        elif x['approval_status']=='PENDING': pending.add((k[0],k[1]))
    if require_screen_coverage:
        missing=sorted(SC-tracked); extra=sorted(tracked-SC)
        if missing: die('reference manifest does not cover every IA screen: '+', '.join(missing))
        if extra: die('reference manifest contains unknown screens: '+', '.join(extra))
    return seen,tracked,approved,pending

ref_rows=rows(REF)
_,tracked,approved,pending=validate_reference_rows(ref_rows,'base',True)
state_rows=rows(STATE)
state_seen,_,state_approved,state_pending=validate_reference_rows(state_rows,'state',False)
state_pairs={(a,b) for a,b,_ in state_seen}
missing_states=sorted(REQUIRED_STATES-state_pairs)
unknown_required=sorted(state_pairs-REQUIRED_STATES)
if missing_states: die('missing required UI states: '+', '.join(f'{a}:{b}' for a,b in missing_states))
if unknown_required: die('state manifest contains undeclared required states: '+', '.join(f'{a}:{b}' for a,b in unknown_required))

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
    if x['a11y_label_required'].strip().lower() not in {'true','false'}: die(f'invalid a11y flag {a}')
for a in {'ACTION-NAV-TODAY','ACTION-NAV-TOOLS','ACTION-NAV-RECORDS','ACTION-NAV-PROFILE'}:
    if a not in seen: die(f'missing global action {a}')
missing_priority_sources=sorted(PRIORITY_ACTION_SOURCES-action_sources)
if missing_priority_sources: die('priority screens missing action coverage: '+', '.join(missing_priority_sources))

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

print(f'UI contracts OK: IA screens={len(SC)} tracked_refs={len(tracked)} approved_refs={len(approved)} pending_refs={len(pending)} required_states={len(REQUIRED_STATES)} approved_states={len(state_approved)} pending_states={len(state_pending)} actions={len(act_rows)} action_sources={len(action_sources)} priority_action_sources={len(PRIORITY_ACTION_SOURCES)} assets={len(asset_rows)} approved_assets={asset_approved}')
print(f'UI reference coverage: {len(tracked)}/{len(SC)} (100.0%)')
print(f'Required state coverage: {len(state_pairs)}/{len(REQUIRED_STATES)} (100.0%)')
print(f'Priority action-source coverage: {len(PRIORITY_ACTION_SOURCES)}/{len(PRIORITY_ACTION_SOURCES)} (100.0%)')
