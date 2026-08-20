import 'entitlement_service.dart';
import 'feature_catalog.dart';
import 'local_entitlement_snapshot_store.dart';

enum RewardedAdOutcome { rewarded, cancelled, failed }

final class RewardedUnlockResult {
  const RewardedUnlockResult({
    required this.outcome,
    required this.stateChanged,
    this.validUntilUtc,
  });

  final RewardedAdOutcome outcome;
  final bool stateChanged;
  final DateTime? validUntilUtc;
}

/// Applies a temporary entitlement only after a verified rewarded-ad outcome.
/// Cancellation and failure are strict no-ops; they do not rewrite or clear
/// existing entitlement state. The central feature policy remains authoritative
/// about which features may be temporarily unlocked.
final class RewardedTemporaryUnlockCoordinator {
  const RewardedTemporaryUnlockCoordinator({
    required this.store,
    required this.clock,
  });

  final LocalEntitlementSnapshotStore store;
  final EntitlementClock clock;

  Future<RewardedUnlockResult> apply({
    required String featureId,
    required RewardedAdOutcome outcome,
    required Duration duration,
  }) async {
    final policy = RuhFeatureCatalog.policyFor(featureId);
    if (!policy.temporaryUnlockAllowed) {
      throw ArgumentError.value(
        featureId,
        'featureId',
        'Feature policy does not allow temporary rewarded access.',
      );
    }
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'Reward duration must be positive.');
    }

    if (outcome != RewardedAdOutcome.rewarded) {
      return RewardedUnlockResult(outcome: outcome, stateChanged: false);
    }

    final now = await clock.nowUtc();
    if (!now.isUtc) {
      throw const StateError('Rewarded entitlement clock must return UTC.');
    }
    final requestedExpiry = now.add(duration);
    final current = await store.load();
    final grants = <TemporaryFeatureGrant>[];
    DateTime? existingExpiry;

    for (final grant in current.temporaryGrants) {
      if (grant.featureId != featureId) {
        grants.add(grant);
        continue;
      }
      if (grant.validUntilUtc.isAfter(now) &&
          (existingExpiry == null || grant.validUntilUtc.isAfter(existingExpiry))) {
        existingExpiry = grant.validUntilUtc;
      }
    }

    final effectiveExpiry = existingExpiry != null && existingExpiry.isAfter(requestedExpiry)
        ? existingExpiry
        : requestedExpiry;
    grants.add(
      TemporaryFeatureGrant(featureId: featureId, validUntilUtc: effectiveExpiry),
    );

    await store.save(
      EntitlementSnapshot(
        hasPro: current.hasPro,
        temporaryGrants: List<TemporaryFeatureGrant>.unmodifiable(grants),
      ),
    );
    return RewardedUnlockResult(
      outcome: outcome,
      stateChanged: true,
      validUntilUtc: effectiveExpiry,
    );
  }
}
