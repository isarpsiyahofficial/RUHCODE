enum MonetizationOperation {
  rewardedAd,
  purchase,
  restore,
}

enum MonetizationOutcome {
  success,
  cancelled,
  unavailable,
  failed,
}

final class MonetizationAttempt {
  const MonetizationAttempt({
    required this.operation,
    required this.outcome,
    required this.entitlementStateChanged,
  });

  final MonetizationOperation operation;
  final MonetizationOutcome outcome;
  final bool entitlementStateChanged;

  bool get failedOrUnavailable =>
      outcome == MonetizationOutcome.failed ||
      outcome == MonetizationOutcome.unavailable;
}

/// Monetization is a side concern. Failure/cancellation must not mutate user
/// records or change the mathematical output of an otherwise available Free or
/// offline-PRO calculation.
final class MonetizationResiliencePolicy {
  const MonetizationResiliencePolicy();

  void validateAttempt(MonetizationAttempt attempt) {
    if (attempt.outcome != MonetizationOutcome.success &&
        attempt.entitlementStateChanged) {
      throw StateError(
        'failed/cancelled monetization cannot change entitlement state',
      );
    }
  }

  T preserveCalculation<T>({
    required T calculatedValue,
    required MonetizationAttempt attempt,
  }) {
    validateAttempt(attempt);
    return calculatedValue;
  }

  Map<String, Object?> preserveUserData({
    required Map<String, Object?> before,
    required MonetizationAttempt attempt,
  }) {
    validateAttempt(attempt);
    return Map<String, Object?>.unmodifiable(before);
  }
}

/// Core/offline entitlement capability is explicit. Network availability is
/// not consulted for features that are declared local and already entitled.
final class OfflineCapabilityDecision {
  const OfflineCapabilityDecision({
    required this.featureId,
    required this.isLocalFeature,
    required this.isEntitled,
  });

  final String featureId;
  final bool isLocalFeature;
  final bool isEntitled;

  bool get usableOffline => isLocalFeature && isEntitled;
}
