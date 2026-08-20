#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / 'lib/src/app/app_runtime.dart'
PRO_BUNDLE = ROOT / 'lib/src/entitlements/professional_repository_bundle.dart'
PRO_BUNDLE_TEST = ROOT / 'test/entitlements/professional_repository_bundle_test.dart'
EVIDENCE = ROOT / 'evidence/entitlements/feature_policy_contract.json'

checks = (
    (RUNTIME, [
        'final ownershipCache = GooglePlayOwnershipCache(database);',
        'final compositeSnapshotProvider = CompositeEntitlementSnapshotProvider(',
        'localProvider: localSnapshotStore,',
        'googlePlayCache: ownershipCache,',
        'snapshotProvider: compositeSnapshotProvider,',
        'final professionalRepositories = ProfessionalRepositoryBundle(',
        'final ownershipSynchronizer = GooglePlayLifetimeOwnershipSynchronizer(',
        'lifetimeOwnershipQuery ?? const GooglePlayLifetimeOwnershipQuery()',
        'startupOwnershipSync = await ownershipSynchronizer.synchronize();',
        'Store/plugin failures must never prevent the offline-first application',
    ]),
    (PRO_BUNDLE, [
        'final class ProfessionalRepositoryBundle',
        'RuhFeatureIds.professionalClients',
        'RuhFeatureIds.professionalPresets',
        'delegate: core.clients',
        'delegate: core.consultations',
        'delegate: core.notes',
        'delegate: core.professionalPresets',
        'delegate: core.interpretationTemplates',
    ]),
    (PRO_BUNDLE_TEST, [
        'professional repositories use canonical professional feature IDs',
        'bundle.clients.featureId',
        'bundle.consultations.featureId',
        'bundle.notes.featureId',
        'bundle.presets.featureId',
        'bundle.interpretationTemplates.featureId',
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
    errors.append('missing entitlement evidence')
else:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    required = set(evidence.get('requiredProperties', []))
    for item in {
        'production professional client consultation note preset and interpretation-template repositories are composed through guarded repositories using canonical professional Feature IDs',
        'runtime entitlement resolution combines local entitlement state with cached Google Play lifetime ownership',
        'startup performs best-effort Google Play ownership synchronization without making store availability an application-start requirement',
    }:
        if item not in required:
            errors.append(f'entitlement evidence missing property: {item}')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Runtime entitlement composition contract OK (source-level, not DONE).')
