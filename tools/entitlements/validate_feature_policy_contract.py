#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / 'lib/src/entitlements/feature_catalog.dart'
SERVICE = ROOT / 'lib/src/entitlements/entitlement_service.dart'
TEST = ROOT / 'test/entitlements/entitlement_service_test.dart'
EVIDENCE = ROOT / 'evidence/entitlements/feature_policy_contract.json'

checks = (
    (CATALOG, [
        'abstract final class RuhFeatureIds',
        'abstract final class RuhFeatureCatalog',
        'FeatureBaseAccess.free',
        'FeatureBaseAccess.pro',
        'temporaryUnlockAllowed: true',
        'Unknown Ruh Code feature ID.',
        'Feature policy catalog must cover every canonical feature ID exactly once.',
    ]),
    (SERVICE, [
        'final class PolicyEntitlementService implements EntitlementService',
        'RuhFeatureCatalog.policyFor(featureId)',
        'snapshot.hasPro',
        'policy.baseAccess == FeatureBaseAccess.free',
        'policy.temporaryUnlockAllowed',
        'grant.validUntilUtc.isAfter(now)',
        'Temporary entitlement expiry must be UTC.',
        'Entitlement clock must return UTC.',
    ]),
    (TEST, [
        'catalog covers every canonical feature ID exactly once',
        'free feature stays usable without PRO',
        'locked PRO feature is denied without active temporary grant',
        'PRO account can use all canonical features',
        'active temporary grant unlocks only eligible feature until exact UTC expiry',
        'unknown feature ID fails closed',
        'temporary expiry must be UTC',
        'entitlement clock must return UTC',
    ]),
)

errors = []
for path, tokens in checks:
    if not path.exists():
        errors.append(f'missing {path.relative_to(ROOT)}')
        continue
    text = path.read_text(encoding='utf-8')
    for token in tokens:
        if token not in text:
            errors.append(f'{path.relative_to(ROOT)} missing token: {token}')

if not EVIDENCE.exists():
    errors.append(f'missing {EVIDENCE.relative_to(ROOT)}')
else:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if evidence.get('contract') != 'ruh-code-feature-entitlement-policy-v1':
        errors.append('unexpected entitlement evidence contract id')
    if evidence.get('done') is not False:
        errors.append('entitlement policy evidence must remain done=false until store/restore/UI/release proofs pass')
    if evidence.get('offlineCore') is not True:
        errors.append('entitlement policy core must be offline-capable')
    required = set(evidence.get('requiredProperties', []))
    for item in {
        'one canonical Feature ID catalog is shared by UI routes and services',
        'every canonical Feature ID has exactly one base Free or PRO policy',
        'unknown Feature IDs fail closed',
        'PRO entitlement unlocks every canonical Feature ID',
        'temporary access can unlock only policy-approved PRO features',
        'temporary grants use exact UTC expiry and expire at the boundary',
        'entitlement resolution itself does not delete or mutate user records',
    }:
        if item not in required:
            errors.append(f'entitlement evidence missing property: {item}')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Feature entitlement policy contract OK (source-level, not DONE).')
