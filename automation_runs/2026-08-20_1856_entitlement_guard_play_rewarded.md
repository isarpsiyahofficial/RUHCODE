# Ruh Code Automation Run — 2026-08-20 18:56

## Scope advanced

This run continued Phase 21 entitlement work without marking unproven release requirements DONE.

### Central access guard

- Added `FeatureAccessGuard` as the single UI / route / service policy boundary.
- All three surfaces delegate to the same `EntitlementService`.
- Unknown feature IDs fail closed through the canonical `RuhFeatureCatalog`.
- Locked service actions are rejected before the protected action executes.
- Tests cover identical UI/route/service decisions, no execution when locked, exactly-once execution when allowed, and invented-ID rejection.

### Google Play lifetime ownership restore source contract

- Added official Flutter `in_app_purchase` + Android platform-addition dependencies.
- Added `GooglePlayLifetimeOwnershipQuery` using Android `queryPastPurchases()` for the lifetime non-consumable product ID `ruh_code_lifetime_pro`.
- Successful ownership requires purchase/restored status and non-empty server verification material.
- Raw verification material is not persisted; a SHA-256 fingerprint is cached.
- Added dedicated local store table `system_google_play_ownership`.
- Store-query `unavailable` is a strict cache no-op so an outage cannot revoke previously confirmed lifetime ownership.
- A successful empty/not-owned query updates only Google Play ownership state and cannot erase independent local entitlement state.
- `CompositeEntitlementSnapshotProvider` combines cached Play ownership with local entitlement/temporary-grant state, keeping confirmed lifetime PRO usable offline.
- Tests cover owned restore, offline/outage preservation, successful not-owned isolation, and strict ownership-cache validation.

### Rewarded temporary unlock safety

- Added `RewardedTemporaryUnlockCoordinator`.
- `cancelled` and `failed` outcomes are strict no-ops: no entitlement write/clear occurs.
- Only `rewarded` can create/update a temporary grant.
- Central feature policy still decides eligibility; professional-only non-temporary features remain blocked.
- A new reward cannot shorten an already longer active grant.
- Tests cover cancellation, failure, verified reward, non-shortening behavior and professional feature rejection.

### Evidence / CI contract

- Extended `evidence/entitlements/feature_policy_contract.json` with shared-guard, Play ownership and rewarded safety invariants.
- Extended `tools/entitlements/validate_feature_policy_contract.py` to require the new source/test/dependency tokens.
- Extended `.github/workflows/entitlement-contract.yml` to trigger for `pubspec.yaml`/`pubspec.lock` and run the full entitlement test directory.

## Important validation status

- Latest workflow-target commit: `56afd3d7d5d4bd9ed106eea19a403f0e29c5724b`.
- GitHub combined-status connector returned `statuses=[]`; no CI SUCCESS was inferred or fabricated.
- `pubspec.lock` remains absent intentionally; it must come only from a real `flutter pub get` resolution.
- Real Play-distributed reinstall/device-change proof and real-device rewarded-ad SDK event proof remain required before DONE.

## Next work

1. Bind concrete production route/UI/service entry points through `FeatureAccessGuard` as screens/services become real rather than placeholders.
2. Add production rewarded-ad adapter only when the project monetization/ad SDK contract is chosen; keep failure/cancel no-op semantics.
3. Verify Google Play restore on a Play-distributed test build and prove reinstall/device change.
4. Continue PDF work that does not require missing approved font/UI assets: 5/25/50+ page fixture and structural page-count/parser gates.
5. Continue independent non-blocked requirements while physical astronomy datasets, 8,036 editorial messages, approved UI PNGs and production font assets remain open.

**FINAL: NO.**
