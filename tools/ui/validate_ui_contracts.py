#!/usr/bin/env python3
import csv, hashlib, re, sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
IA = R / 'docs/UI_INFORMATION_ARCHITECTURE.md'
REF = R / 'ui/reference_manifest.csv'
STATE = R / 'ui/state_reference_manifest.csv'
ACT = R / 'ui/action_registry.csv'
AST = R / 'ui/asset_manifest.csv'
GEOM = R / 'ui/dynamic_geometry_manifest.csv'

SC = set(re.findall(r'SCR-[A-Z0-9-]+', IA.read_text(encoding='utf-8')))

ACTION_REQUIRED_SOURCES = {
    'SCR-TODAY-001','SCR-TOOLS-001','SCR-ASTROLOGY-001',
    'SCR-WESTERN-INPUT-001','SCR-WESTERN-CHART-001','SCR-WESTERN-PLACEMENTS-001','SCR-WESTERN-ASPECTS-001','SCR-WESTERN-HOUSES-001','SCR-WESTERN-TECH-001','SCR-WESTERN-INTERP-001','SCR-WESTERN-SETTINGS-001',
    'SCR-TRANSIT-001','SCR-TRANSIT-TIMELINE-001','SCR-SYNASTRY-SELECT-001','SCR-SYNASTRY-RESULT-001','SCR-COMPOSITE-001','SCR-DAVISON-001','SCR-SOLAR-RETURN-001','SCR-LUNAR-RETURN-001','SCR-PROGRESSIONS-001','SCR-SOLAR-ARC-001','SCR-PROFECTIONS-001',
    'SCR-VEDIC-INPUT-001','SCR-VEDIC-D1-001','SCR-VEDIC-D9-001','SCR-VEDIC-VARGAS-001','SCR-VEDIC-DASHA-001','SCR-VEDIC-DASHA-DETAIL-001','SCR-VEDIC-GOCHARA-001','SCR-VEDIC-PANCHANGA-001','SCR-VEDIC-STRENGTH-001','SCR-VEDIC-SETTINGS-001',
    'SCR-CHINESE-001','SCR-BAZI-INPUT-001','SCR-BAZI-PILLARS-001','SCR-BAZI-ELEMENTS-001','SCR-BAZI-TENGODS-001','SCR-BAZI-LUCK-001','SCR-PLANETARY-HOURS-001','SCR-PLANETARY-HOURS-NOTIFY-001',
    'SCR-NUMEROLOGY-001','SCR-NUMEROLOGY-INPUT-001','SCR-PYTHAGOREAN-001','SCR-CHALDEAN-001','SCR-LOSHU-001','SCR-NUM-PERIODS-001','SCR-NUM-TIMELINE-001','SCR-NUM-COMPAT-001',
    'SCR-SPIRITUAL-001','SCR-TAROT-DAILY-001','SCR-TAROT-THREE-001','SCR-TAROT-SESSION-001','SCR-INTENTION-001','SCR-GRATITUDE-001','SCR-DREAM-001','SCR-MEDITATION-001','SCR-BREATH-001',
    'SCR-GROWTH-001','SCR-GOALS-001','SCR-HABITS-001','SCR-CHECKIN-AM-001','SCR-CHECKIN-PM-001','SCR-WEEKLY-REVIEW-001','SCR-LIFE-WHEEL-001','SCR-MOOD-001',
    'SCR-RECORDS-001','SCR-PROFILES-001','SCR-PROFILE-DETAIL-001','SCR-CLIENTS-001','SCR-CLIENT-NEW-001','SCR-CLIENT-DETAIL-001','SCR-CONSULT-PREP-001','SCR-CONSULT-LIVE-001','SCR-CONSULT-HISTORY-001','SCR-PRO-PRESETS-001','SCR-PRO-LIBRARY-001','SCR-PRO-SHARE-001','SCR-LEARNING-001',
    'SCR-PROFILE-001','SCR-SETTINGS-001','SCR-LANGUAGE-001','SCR-NOTIFICATIONS-001','SCR-PRIVACY-001','SCR-APP-LOCK-001','SCR-PREMIUM-001','SCR-BACKUP-001','SCR-BACKUP-IMPORT-001','SCR-BACKUP-PREVIEW-001','SCR-PDF-001','SCR-PDF-BUILDER-001','SCR-PDF-PREVIEW-001',
    'SCR-ONBOARD-LANGUAGE-001','SCR-ONBOARD-INTRO-001','SCR-ONBOARD-PROFILE-001','SCR-LOCATION-SEARCH-001','SCR-LOCATION-DISAMBIG-001','SCR-LOCATION-MANUAL-001',
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

REQUIRED_GEOMETRY = {
    'GEOM-WESTERN-NATAL-WHEEL','GEOM-WESTERN-ASPECT-LINES','GEOM-WESTERN-TRANSIT-OVERLAY','GEOM-WESTERN-SYNASTRY-WHEEL','GEOM-WESTERN-COMPOSITE-WHEEL',
    'GEOM-VEDIC-D1','GEOM-VEDIC-D9','GEOM-VEDIC-VARGA','GEOM-BAZI-PILLARS','GEOM-BAZI-ELEMENTS','GEOM-NUMEROLOGY-LOSHU','GEOM-NUMEROLOGY-PYTHAGOREAN','GEOM-PDF-WESTERN-WHEEL','GEOM-PDF-VEDIC-CHART',
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
        if x['status']=='ACTIVE': action_sources.add(s)
    if t.startswith('SCR-') and t not in SC: die(f'unknown action target {t}')
    if x['status'] not in {'ACTIVE','PENDING','DEPRECATED'} or not t: die(f'invalid action {a}')
    if x['a11y_label_required'].strip().lower() not in {'true','false'}: die(f'invalid a11y flag {a}')
    if x['action_type'].strip() not in {'NAVIGATION','INPUT','TOGGLE','CALCULATION','DATA','FILTER','PDF','SHARE','BACKUP','PURCHASE'}: die(f'invalid action type {a}')
    if x['offline_behavior'].strip() not in {'AVAILABLE','REQUIRES_NETWORK','UNAVAILABLE'}: die(f'invalid offline behavior {a}')
for a in {'ACTION-NAV-TODAY','ACTION-NAV-TOOLS','ACTION-NAV-RECORDS','ACTION-NAV-PROFILE'}:
    if a not in seen: die(f'missing global action {a}')
unknown_action_requirements=sorted(ACTION_REQUIRED_SOURCES-SC)
if unknown_action_requirements: die('action-required contract references unknown screens: '+', '.join(unknown_action_requirements))
missing_action_sources=sorted(ACTION_REQUIRED_SOURCES-action_sources)
if missing_action_sources: die('interactive screens missing ACTIVE action coverage: '+', '.join(missing_action_sources))

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

geom_rows=rows(GEOM); geom_seen=set(); geom_sources=set()
for n,x in enumerate(geom_rows,2):
    g=x['geometry_id'].strip(); s=x['source_screen_id'].strip(); calc=x['calculation_source'].strip(); contract=x['renderer_contract'].strip()
    if not g.startswith('GEOM-') or g in geom_seen: die(f'bad/duplicate geometry {g}')
    geom_seen.add(g)
    if s not in SC: die(f'unknown geometry screen {s}')
    geom_sources.add(s)
    if not calc or calc in {'TBD','UNKNOWN'}: die(f'missing calculation source for {g}')
    if contract not in {'DETERMINISTIC_VECTOR','DETERMINISTIC_LAYOUT','SHARED_CALCULATION_VECTOR'}: die(f'invalid renderer contract {g}')
    if x['golden_required'].strip().lower()!='true': die(f'golden test must be required for {g}')
    if x['status'].strip() not in {'SPECIFIED','IMPLEMENTED','TESTED','VERIFIED'}: die(f'invalid geometry status {g}')
missing_geometry=sorted(REQUIRED_GEOMETRY-geom_seen)
extra_geometry=sorted(geom_seen-REQUIRED_GEOMETRY)
if missing_geometry: die('missing required dynamic geometry contracts: '+', '.join(missing_geometry))
if extra_geometry: die('undeclared dynamic geometry contracts: '+', '.join(extra_geometry))

print(f'UI contracts OK: IA screens={len(SC)} tracked_refs={len(tracked)} approved_refs={len(approved)} pending_refs={len(pending)} required_states={len(REQUIRED_STATES)} approved_states={len(state_approved)} pending_states={len(state_pending)} actions={len(act_rows)} action_sources={len(action_sources)} required_action_sources={len(ACTION_REQUIRED_SOURCES)} assets={len(asset_rows)} approved_assets={asset_approved} dynamic_geometry={len(geom_rows)}')
print(f'UI reference coverage: {len(tracked)}/{len(SC)} (100.0%)')
print(f'Required state coverage: {len(state_pairs)}/{len(REQUIRED_STATES)} (100.0%)')
print(f'Interactive action-source coverage: {len(ACTION_REQUIRED_SOURCES)}/{len(ACTION_REQUIRED_SOURCES)} (100.0%)')
print(f'Dynamic geometry contract coverage: {len(geom_seen)}/{len(REQUIRED_GEOMETRY)} (100.0%)')
