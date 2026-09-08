#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1085_rc1104_entitlement_resilience_contract.json'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
FILES = [
    ROOT / 'lib/src/entitlements/feature_catalog.dart',
    ROOT / 'lib/src/entitlements/entitlement_service.dart',
    ROOT / 'lib/src/entitlements/feature_access_guard.dart',
    ROOT / 'lib/src/entitlements/rewarded_temporary_unlock.dart',
    ROOT / 'lib/src/entitlements/local_entitlement_time_anchor.dart',
    ROOT / 'lib/src/entitlements/google_play_lifetime_ownership.dart',
    ROOT / 'lib/src/entitlements/monetization_resilience.dart',
    ROOT / 'test/entitlements/entitlement_service_test.dart',
    ROOT / 'test/entitlements/feature_access_guard_test.dart',
    ROOT / 'test/entitlements/local_entitlement_time_anchor_test.dart',
    ROOT / 'test/entitlements/google_play_lifetime_ownership_test.dart',
    ROOT / 'test/entitlements/rewarded_temporary_unlock_test.dart',
    ROOT / 'test/entitlements/monetization_resilience_rc1085_rc1104_test.dart',
]


def fail(msg: str) -> None:
    raise SystemExit(f'RC1085_RC1104_FAIL: {msg}')


for path in [CONTRACT, MASTER, *FILES]:
    if not path.exists():
        fail(f'missing evidence file: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(1085, 1105)]
if list(contract.get('requirements', {}).keys()) != expected:
    fail('contract must preserve exact RC-1085..RC-1104 order with no omissions')

master = MASTER.read_text(encoding='utf-8')
for n in range(1085, 1105):
    if f'{n}.' not in master:
        fail(f'binding master requirement {n} not found')

combined = '\n'.join(p.read_text(encoding='utf-8') for p in FILES)
for token in (
    'RuhFeatureIds', 'RuhFeatureCatalog', 'PolicyEntitlementService',
    'FeatureAccessSurface.menu', 'forMenu', 'FeatureAccessSurface.service',
    'EntitlementTier.temporary', 'validUntilUtc',
    'LocalRollbackResistantEntitlementClock',
    'GooglePlayLifetimeOwnershipQuery', 'queryPastPurchases',
    'verificationFingerprint', 'CompositeEntitlementSnapshotProvider',
    'MonetizationResiliencePolicy', 'preserveUserData', 'preserveCalculation',
    'OfflineCapabilityDecision', 'usableOffline'
):
    if token not in combined:
        fail(f'evidence token missing: {token}')

for required_test_phrase in (
    'PRO account can use all canonical features',
    'UI menu route and service surfaces use the same EntitlementService result',
    'failed purchase cannot mutate entitlement state or user data',
    'ad unavailable cannot change an otherwise valid free calculation',
    'already-entitled local PRO capability remains usable offline',
):
    if required_test_phrase not in combined:
        fail(f'regression evidence missing: {required_test_phrase}')

print('RC1085_RC1104_OK')
