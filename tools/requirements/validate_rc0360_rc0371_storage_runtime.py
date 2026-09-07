#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT=ROOT/'requirements/contracts/rc0360_rc0371_storage_runtime_contract.json'
STORAGE=ROOT/'lib/src/data/profile/profile_storage_contract.dart'
RUNTIME=ROOT/'lib/src/application/runtime_capability_policy.dart'
GUARD=ROOT/'lib/src/entitlements/feature_access_guard.dart'
TESTS=[ROOT/'test/data/profile_storage_rc0360_rc0365_test.dart',ROOT/'test/application/runtime_capability_rc0366_rc0371_test.dart']
for p in (SPEC,CONTRACT,STORAGE,RUNTIME,GUARD,*TESTS):
    if not p.exists(): raise SystemExit(f'RC0360_RC0371_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(360,372):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0360_RC0371_FAIL: binding {n}.')
c=json.loads(CONTRACT.read_text(encoding='utf-8'))
if c.get('requirement_range')!='RC-0360..RC-0371': raise SystemExit('RC0360_RC0371_FAIL: range')
storage=STORAGE.read_text(encoding='utf-8'); runtime=RUNTIME.read_text(encoding='utf-8'); guard=GUARD.read_text(encoding='utf-8')
for token in ['ProfileRelationship { self, partner, family, client }','ownerId','ProfileStorageTier { localEncrypted, cloudEncrypted }','abstract interface class ProfileRepository','listForOwner','getForOwner','deleteForOwner','cross-owner profile access blocked']:
    if token not in storage: raise SystemExit(f'RC0360_RC0371_FAIL: storage token {token!r}')
for token in ['enum RuntimeDependency { localOnly, remoteRequired }','westernCalculation','vedicCalculation','baziCalculation','numerologyCalculation','profileReadWrite','pdfGeneration','premiumVerification','cloudSync','launchNetworkAllowList => const {}','abstract interface class PremiumEntitlementVerifier','signedAssertionId']:
    if token not in runtime: raise SystemExit(f'RC0360_RC0371_FAIL: runtime token {token!r}')
if 'local premium booleans are deliberately not accepted here' not in guard or 'EntitlementService' not in guard:
    raise SystemExit('RC0360_RC0371_FAIL: canonical entitlement guard evidence missing')
text='\n'.join(p.read_text(encoding='utf-8') for p in TESTS)
for token in ['cross-owner profile or client-note access fails closed','core product capabilities are explicitly offline','premium assertion requires verifier provenance']:
    if token not in text: raise SystemExit(f'RC0360_RC0371_FAIL: test token {token!r}')
blocked=c.get('blocked_until') or []
if not any('encrypted local ProfileRepository' in x for x in blocked): raise SystemExit('RC0360_RC0371_FAIL: encryption blocker missing')
if not any('airplane-mode' in x for x in blocked): raise SystemExit('RC0360_RC0371_FAIL: offline device blocker missing')
print('RC0360_RC0371_OK')
