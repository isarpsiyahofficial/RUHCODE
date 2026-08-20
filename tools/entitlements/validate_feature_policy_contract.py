#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / 'lib/src/entitlements/feature_catalog.dart'
SERVICE = ROOT / 'lib/src/entitlements/entitlement_service.dart'
STORE = ROOT / 'lib/src/entitlements/local_entitlement_snapshot_store.dart'
TIME_ANCHOR = ROOT / 'lib/src/entitlements/local_entitlement_time_anchor.dart'
ACCESS_GUARD = ROOT / 'lib/src/entitlements/feature_access_guard.dart'
PLAY_OWNERSHIP = ROOT / 'lib/src/entitlements/google_play_lifetime_ownership.dart'
TEST = ROOT / 'test/entitlements/entitlement_service_test.dart'
STORE_TEST = ROOT / 'test/entitlements/local_entitlement_snapshot_store_test.dart'
TIME_ANCHOR_TEST = ROOT / 'test/entitlements/local_entitlement_time_anchor_test.dart'
SQLITE_TEST = ROOT / 'test/entitlements/entitlement_sqlite_preservation_test.dart'
ACCESS_GUARD_TEST = ROOT / 'test/entitlements/feature_access_guard_test.dart'
PLAY_OWNERSHIP_TEST = ROOT / 'test/entitlements/google_play_lifetime_ownership_test.dart'
PUBSPEC = ROOT / 'pubspec.yaml'
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
        'final now = await clock.nowUtc();',
    ]),
    (STORE, [
        'final class LocalEntitlementSnapshotStore implements EntitlementSnapshotProvider',
        "static const tableName = 'system_entitlement_state'",
        "static const recordId = 'current'",
        'tx.get(table: tableName, id: recordId)',
        'tx.put(',
        'tx.delete(table: tableName, id: recordId)',
        'Stored temporary grant expiry must be UTC ISO-8601.',
    ]),
    (TIME_ANCHOR, [
        'final class LocalRollbackResistantEntitlementClock implements EntitlementClock',
        "static const tableName = 'system_entitlement_time_anchor'",
        "static const recordId = 'latest_seen_utc'",
        'final DateTime effective;',
        'effective = wallNow.isAfter(anchor) ? wallNow : anchor;',
        'Stored entitlement time anchor must be UTC ISO-8601.',
        'clearing app data/reinstalling',
    ]),
    (ACCESS_GUARD, [
        'final class FeatureAccessGuard',
        'Future<FeatureAccessDecision> forUi',
        'Future<FeatureAccessDecision> forRoute',
        'Future<FeatureAccessDecision> forService',
        'RuhFeatureCatalog.policyFor(featureId)',
        'final allowed = await entitlements.canUse(featureId);',
        'throw FeatureAccessDeniedException(featureId);',
    ]),
    (PLAY_OWNERSHIP, [
        "const ruhCodeLifetimeProductId = 'ruh_code_lifetime_pro'",
        'final class GooglePlayLifetimeOwnershipQuery implements LifetimeOwnershipQuery',
        'getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()',
        'queryPastPurchases()',
        'purchase.verificationData.serverVerificationData',
        "sha256",
        "static const tableName = 'system_google_play_ownership'",
        'if (check.status == StoreOwnershipStatus.unavailable)',
        'cacheChanged: false',
        'final class CompositeEntitlementSnapshotProvider implements EntitlementSnapshotProvider',
        'hasPro: local.hasPro || (store?.owned ?? false)',
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
    (STORE_TEST, [
        'missing local entitlement state defaults to Free without mutating user tables',
        'PRO and temporary grants round trip in dedicated system table only',
        'clear removes entitlement state without clearing domain data',
        'non UTC temporary grant cannot be persisted',
    ]),
    (TIME_ANCHOR_TEST, [
        'first observation stores exact UTC wall time',
        'device clock rollback cannot move effective entitlement time backwards',
        'later legitimate wall time advances the persistent anchor',
        'time anchor never mutates domain records',
        'non UTC wall clock is rejected',
    ]),
    (SQLITE_TEST, [
        'Free to PRO to Free changes only dedicated entitlement rows',
        'persistent time anchor cannot change user data in production SQLite adapter',
        'stored PRO snapshot and rollback-resistant time combine offline',
        'sqfliteFfiInit',
        'SqfliteLocalDatabase(',
        'expect(await snapshotDomain(), before)',
        'Rolling the wall clock back cannot resurrect the expired grant.',
    ]),
    (ACCESS_GUARD_TEST, [
        'UI route and service surfaces use the same EntitlementService result',
        'runService never executes a locked action',
        'runService executes exactly once when access is allowed',
        'invented feature IDs fail closed before entitlement lookup',
    ]),
    (PLAY_OWNERSHIP_TEST, [
        'successful owned query is cached and exposed as offline PRO',
        'store outage never revokes previously confirmed ownership',
        'successful not-owned query clears only Google Play ownership cache',
        'owned cache requires fingerprint and UTC timestamp',
    ]),
    (PUBSPEC, [
        'in_app_purchase: ^3.3.0',
        'in_app_purchase_android: ^0.5.2',
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
        errors.append('entitlement policy evidence must remain done=false until device/release proofs pass')
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
        'entitlement snapshot is persisted offline in a dedicated system table separate from user-domain records',
        'local time anchor never moves behind the latest UTC instant already observed by the installation',
        'local time-anchor protection explicitly does not claim reinstall-proof tamper resistance',
        'production SQLite Free to PRO to Free transitions preserve user-domain records byte-for-byte at the logical JSON layer',
        'expired temporary access cannot be resurrected by rolling the device wall clock backward within the same installation',
        'UI route and service access checks use one FeatureAccessGuard backed by the same EntitlementService',
        'locked service actions are rejected before their action executes',
        'Google Play lifetime ownership uses the official Android past-purchase query path',
        'a Google Play query outage never revokes previously confirmed cached lifetime ownership',
        'a successful Google Play not-owned result changes only the store ownership cache and cannot erase independent local entitlement state',
        'cached confirmed Google Play lifetime ownership remains usable offline',
    }:
        if item not in required:
            errors.append(f'entitlement evidence missing property: {item}')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Feature entitlement/guard/Google-Play ownership contract OK (source-level, not DONE).')
